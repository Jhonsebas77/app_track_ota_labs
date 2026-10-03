part of com.app_track_ota_labs.app.core.providers;

/// Selección y subida del icono de una app, con el mismo flujo que
/// `AttachmentPickerService` de auto_log_mi_nave: se elige la imagen
/// (cámara o galería) y se sube de inmediato a Supabase Storage.
///
/// El bucket `app-icons` es público, así que se retorna la URL pública (no
/// el object path) y se guarda tal cual en la columna `icon`. Se lee como
/// bytes en vez de usar `dart:io`, así el mismo código funciona en mobile,
/// desktop y web. En web se usa `file_picker` en lugar de `image_picker`
/// porque este último no deja limitar el tipo de archivo (abre `image/*`).
class AppIconPickerService {
  final ImagePicker _imagePicker = ImagePicker();

  static const String _bucket = 'app-icons';

  /// Extensiones que acepta el bucket. `jpg` se normaliza a `jpeg` para que
  /// coincida con el content type `image/jpeg`.
  static const Set<String> _extensions = <String>{'png', 'jpeg', 'webp', 'gif'};

  StorageFileApi get _bucketApi =>
      Supabase.instance.client.storage.from(_bucket);

  /// En web solo se aceptan PNG/JPG elegidos desde el equipo.
  static const List<String> _webExtensions = <String>['png', 'jpg', 'jpeg'];

  /// Máximo que acepta el bucket (`file_size_limit`). En web no se
  /// redimensiona la imagen, así que se valida antes de subirla.
  static const int _maxBytes = 1024 * 1024;

  /// La cámara no existe en todas las plataformas (macOS) y en web se
  /// sube solo desde el equipo.
  bool get supportsCamera =>
      !kIsWeb && _imagePicker.supportsImageSource(ImageSource.camera);

  /// En web abre el explorador de archivos limitado a PNG/JPG; en el resto
  /// de plataformas, la galería.
  Future<String?> pickImageFromDevice({required String userId}) => kIsWeb
      ? _pickWebFile(userId: userId)
      : pickImageFromGallery(userId: userId);

  Future<String?> _pickWebFile({required String userId}) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _webExtensions,
      withData: true,
    );
    PlatformFile? file = result?.files.single;
    Uint8List? bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    // `accept` del input solo filtra el diálogo: el usuario puede cambiar a
    // "Todos los archivos", así que se vuelve a validar aquí.
    String extension = (file.extension ?? '').toLowerCase();
    if (!_webExtensions.contains(extension)) {
      throw const FormatException('ERR: solo se permiten imágenes PNG o JPG');
    }
    if (bytes.length > _maxBytes) {
      throw const FormatException('ERR: la imagen supera 1 MB');
    }
    return _upload(
      bytes: bytes,
      extension: extension == 'jpg' ? 'jpeg' : extension,
      userId: userId,
    );
  }

  Future<String?> pickImageFromCamera({required String userId}) =>
      _pickImage(ImageSource.camera, userId: userId);

  Future<String?> pickImageFromGallery({required String userId}) =>
      _pickImage(ImageSource.gallery, userId: userId);

  Future<String?> _pickImage(
    ImageSource source, {
    required String userId,
  }) async {
    XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 90,
      // Es un icono: 512 px alcanza de sobra y mantiene la subida liviana.
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked == null) return null;
    // Se usa el MIME type y, como respaldo, el nombre del archivo: `path`
    // no siempre trae la extensión.
    String extension =
        (picked.mimeType?.split('/').last ?? picked.name.split('.').last)
            .toLowerCase()
            .replaceFirst('jpg', 'jpeg');
    if (!_extensions.contains(extension)) {
      throw const FormatException('ERR: usa PNG, JPG, WEBP o GIF');
    }
    return _upload(
      bytes: await picked.readAsBytes(),
      extension: extension,
      userId: userId,
    );
  }

  Future<String> _upload({
    required Uint8List bytes,
    required String extension,
    required String userId,
  }) async {
    String objectPath =
        '$userId/${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _bucketApi.uploadBinary(
      objectPath,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$extension'),
    );
    return _bucketApi.getPublicUrl(objectPath);
  }

  /// Borra un icono subido por este servicio a partir de su URL pública.
  /// Se usa al reemplazarlo, quitarlo o salir del formulario sin guardar,
  /// para no dejar archivos huérfanos en el bucket.
  Future<void> delete(String publicUrl) async {
    String marker = '/$_bucket/';
    int index = publicUrl.indexOf(marker);
    if (index == -1) return;
    await _bucketApi.remove(<String>[
      publicUrl.substring(index + marker.length),
    ]);
  }
}

final Provider<AppIconPickerService> appIconPickerServiceProvider =
    Provider<AppIconPickerService>((Ref ref) => AppIconPickerService());
