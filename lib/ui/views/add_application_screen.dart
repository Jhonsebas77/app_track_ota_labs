part of com.app_track_ota_labs.app.views;

/// Formulario de aplicación. Sin [initial] registra una app nueva; con
/// [initial] edita esa app (abierto desde [AppDetailScreen]).
class AddApplicationScreen extends ConsumerStatefulWidget {
  const AddApplicationScreen({super.key, this.initial});
  static const String route = '/add-application';
  static const String editRoute = '/edit-application';

  final AppModel? initial;

  @override
  ConsumerState<AddApplicationScreen> createState() =>
      _AddApplicationScreenState();
}

class _AddApplicationScreenState extends ConsumerState<AddApplicationScreen> {
  /// Dominio invertido: `com.empresa.app` (al menos dos segmentos).
  static final RegExp _bundleIdPattern = RegExp(
    r'^[A-Za-z][A-Za-z0-9_-]*(\.[A-Za-z0-9_-]+)+$',
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bundleIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deployUrlController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _buildController = TextEditingController();
  Set<AppPlatform> _platforms = <AppPlatform>{AppPlatform.ios};

  /// Plataformas guardadas que no son un [AppPlatform] (datos anteriores a
  /// la normalización): se conservan al guardar salvo que el usuario las
  /// quite.
  List<String> _otherPlatforms = <String>[];
  AppStatus _status = AppStatus.draft;
  bool _isSaving = false;

  /// Tras el primer intento fallido de guardar, los campos se revalidan
  /// mientras el usuario escribe.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  /// Estado del formulario al abrirlo, para saber si hay cambios sin guardar.
  late final String _initialSnapshot;
  bool _isDirty = false;

  /// URL pública del icono a mostrar/guardar; `null` si no hay icono subido.
  /// Al editar arranca con el icono actual de la app si es remoto.
  String? _iconUrl;

  /// `true` si el usuario eligió o quitó un icono: solo entonces se envía la
  /// columna `icon` al editar (un icono de asset local se conserva intacto).
  bool _iconChanged = false;
  bool _isPickingIcon = false;
  bool _saved = false;

  /// Se lee en `initState` porque `ref` no se puede usar en `dispose` ni
  /// después de un `await` si la pantalla ya se cerró, y ahí también hay que
  /// poder borrar el icono subido.
  late final AppIconPickerService _iconPicker;

  List<TextEditingController> get _controllers => <TextEditingController>[
    _nameController,
    _bundleIdController,
    _descriptionController,
    _deployUrlController,
    _versionController,
    _buildController,
  ];

  @override
  void initState() {
    super.initState();
    _iconPicker = ref.read(appIconPickerServiceProvider);
    AppModel? app = widget.initial;
    AppVersion? version = app == null
        ? AppVersion.initial
        : AppVersion.tryParse(app.version);
    // Una versión que no se puede interpretar se muestra tal cual para que
    // el validador le pida al usuario corregirla.
    _versionController.text = version?.name ?? app!.version;
    _buildController.text = version?.build.toString() ?? '';
    if (app != null) {
      _nameController.text = app.name;
      _bundleIdController.text = app.bundleId;
      _descriptionController.text = app.description;
      _deployUrlController.text = app.deployUrl ?? '';
      Set<AppPlatform> platforms = <AppPlatform>{};
      for (String raw in app.platform) {
        AppPlatform? platform = AppPlatform.tryParse(raw);
        if (platform != null) {
          platforms.add(platform);
        } else if (raw.trim().isNotEmpty) {
          _otherPlatforms.add(raw);
        }
      }
      if (platforms.isNotEmpty) _platforms = platforms;
      _status = AppStatus.tryParse(app.status) ?? AppStatus.draft;
      if (app.hasRemoteIcon) _iconUrl = app.icon;
    }
    _initialSnapshot = _snapshot();
    for (TextEditingController controller in _controllers) {
      controller.addListener(_updateDirty);
    }
  }

  bool get _isEditing => widget.initial != null;

  /// Plataformas en el orden de [AppPlatform], seguidas de las desconocidas.
  List<String> get _platformValues => <String>[
    for (AppPlatform platform in AppPlatform.values)
      if (_platforms.contains(platform)) platform.value,
    ..._otherPlatforms,
  ];

  /// Una app solo web no tiene bundle ID de tienda: ahí es opcional.
  bool get _isBundleIdOptional =>
      _platforms.length == 1 && _platforms.contains(AppPlatform.web);

  String _snapshot() => <String?>[
    for (TextEditingController controller in _controllers) controller.text,
    _platformValues.join(','),
    _status.value,
    _iconUrl,
    _iconChanged.toString(),
  ].join('\u0000');

  void _updateDirty() {
    bool dirty = _snapshot() != _initialSnapshot;
    if (dirty != _isDirty) setState(() => _isDirty = dirty);
  }

  /// Icono remoto con el que llegó la app al editar. No se borra del bucket
  /// al reemplazarlo/quitarlo en el formulario, solo después de guardar.
  String? get _originalIconUrl =>
      widget.initial?.hasRemoteIcon ?? false ? widget.initial!.icon : null;

  /// Icono de asset local (`assets/apps/`) que se sigue mostrando mientras el
  /// usuario no elija ni quite otro.
  String? get _assetIcon {
    AppModel? app = widget.initial;
    if (_iconChanged || app == null || app.hasRemoteIcon) return null;
    return (app.icon?.isEmpty ?? true) ? null : app.icon;
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Campo requerido' : null;

  String? _validateBundleId(String? value) {
    String text = value?.trim() ?? '';
    if (text.isEmpty) return _isBundleIdOptional ? null : 'Campo requerido';
    return _bundleIdPattern.hasMatch(text)
        ? null
        : 'Formato inválido (ej. com.empresa.app)';
  }

  String? _optionalUrl(String? value) {
    String text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    Uri? uri = Uri.tryParse(text);
    bool isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isValid ? null : 'URL inválida (http:// o https://)';
  }

  String? _validateVersion(String? value) {
    String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Campo requerido';
    return AppVersion.namePattern.hasMatch(text)
        ? null
        : 'Formato inválido (ej. 1.0.0)';
  }

  String? _validateBuild(String? value) {
    String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Campo requerido';
    int? build = int.tryParse(text);
    return build != null && build > 0 ? null : 'Entero mayor a 0';
  }

  void _togglePlatform(AppPlatform platform, bool selected) {
    // Siempre queda al menos una plataforma conocida seleccionada.
    if (!selected && _platforms.length == 1) return;
    setState(() {
      _platforms = <AppPlatform>{..._platforms};
      selected ? _platforms.add(platform) : _platforms.remove(platform);
    });
    _updateDirty();
  }

  void _removeOtherPlatform(String platform) {
    setState(
      () => _otherPlatforms = <String>[..._otherPlatforms]..remove(platform),
    );
    _updateDirty();
  }

  Future<void> _pickIcon() async {
    String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || _isPickingIcon) return;
    Future<String?> Function({required String userId})? pick = kIsWeb
        ? _iconPicker.pickImageFromDevice
        : await showModalBottomSheet<
            Future<String?> Function({required String userId})
          >(
            context: context,
            builder: (BuildContext context) => SafeArea(
              child: Wrap(
                children: <Widget>[
                  if (_iconPicker.supportsCamera)
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Tomar foto'),
                      onTap: () => Navigator.pop(
                        context,
                        _iconPicker.pickImageFromCamera,
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Elegir de galería'),
                    onTap: () =>
                        Navigator.pop(context, _iconPicker.pickImageFromDevice),
                  ),
                ],
              ),
            ),
          );
    if (pick == null) return;

    setState(() => _isPickingIcon = true);
    String? url;
    String? error;
    try {
      url = await pick(userId: userId);
    } on FormatException catch (e) {
      error = e.message;
    } on StorageException catch (e) {
      error = 'ERR: icono no subido (${e.message})';
    } catch (_) {
      error = 'ERR: no se pudo cargar la imagen';
    }
    if (!mounted) {
      if (url != null) unawaited(_discardIcon(url));
      return;
    }
    setState(() => _isPickingIcon = false);
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    if (url == null) return;
    String? previous = _iconUrl;
    setState(() {
      _iconUrl = url;
      _iconChanged = true;
    });
    _updateDirty();
    if (previous != null) unawaited(_discardIcon(previous));
  }

  void _removeIcon() {
    String? previous = _iconUrl;
    setState(() {
      _iconUrl = null;
      _iconChanged = true;
    });
    _updateDirty();
    if (previous != null) unawaited(_discardIcon(previous));
  }

  /// Borra un icono subido en este formulario que ya no se va a usar; si
  /// falla solo queda un archivo huérfano en el bucket, así que no se le
  /// muestra nada al usuario. El icono original de la app nunca se borra
  /// aquí: si se cancela la edición, la app lo sigue usando.
  Future<void> _discardIcon(String url) => url == _originalIconUrl
      ? Future<void>.value()
      : _iconPicker.delete(url).catchError((_) {});

  /// Valida todos los campos; si alguno falla activa la validación en vivo y
  /// lleva el scroll al primero con error.
  bool _validate() {
    Set<FormFieldState<Object?>> invalid =
        _formKey.currentState?.validateGranularly() ??
        <FormFieldState<Object?>>{};
    if (invalid.isEmpty) return true;
    setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    unawaited(
      Scrollable.ensureVisible(
        invalid.first.context,
        duration: const Duration(milliseconds: 250),
        alignment: 0.2,
      ),
    );
    showErrorSnackBar(context, 'Revisa los campos marcados');
    return false;
  }

  Future<void> _saveApp() async {
    if (_isSaving || _isPickingIcon || !_validate()) return;

    setState(() => _isSaving = true);
    String deployUrl = _deployUrlController.text.trim();
    String version = AppVersion(
      _versionController.text.trim(),
      int.parse(_buildController.text.trim()),
    ).toString();
    String? error;
    try {
      AppModel? app = widget.initial;
      if (app == null) {
        await insertApp(
          name: _nameController.text.trim(),
          bundleId: _bundleIdController.text.trim(),
          description: _descriptionController.text.trim(),
          platforms: _platformValues,
          version: version,
          status: _status.value,
          deployUrl: deployUrl.isEmpty ? null : deployUrl,
          iconUrl: _iconUrl,
        );
      } else {
        await updateApp(app.id, <String, dynamic>{
          'app_name': _nameController.text.trim(),
          'bundle_id': _bundleIdController.text.trim(),
          'app_description': _descriptionController.text.trim(),
          'platform': _platformValues,
          'deploy_url': deployUrl.isEmpty ? null : deployUrl,
          'version': version,
          'status': _status.value,
          if (_iconChanged) 'icon': _iconUrl,
        });
      }
    } on PostgrestException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'ERR: no se pudo guardar la aplicación';
    }
    if (!mounted) return;
    if (error != null) {
      setState(() => _isSaving = false);
      showErrorSnackBar(context, error);
      return;
    }
    _saved = true;
    // El icono original fue reemplazado o quitado y la app ya no lo usa.
    String? original = _originalIconUrl;
    if (_iconChanged && original != null && original != _iconUrl) {
      unawaited(_iconPicker.delete(original).catchError((_) {}));
    }
    ref.invalidate(appsProvider);
    showSuccessSnackBar(
      context,
      _isEditing ? 'Aplicación actualizada' : 'Aplicación registrada',
    );
    Navigator.pop(context);
  }

  Future<bool> _confirmDiscard() async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Descartar cambios'),
          content: const Text(
            'Tienes cambios sin guardar. ¿Salir y descartarlos?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('SEGUIR EDITANDO'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: BlueprintColors.danger,
              ),
              child: const Text('DESCARTAR'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  void dispose() {
    for (TextEditingController controller in _controllers) {
      controller.dispose();
    }
    // Se salió del formulario sin guardar: el icono ya estaba subido.
    if (!_saved && _iconUrl != null) unawaited(_discardIcon(_iconUrl!));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    // `Navigator.pop` tras guardar no pasa por aquí; solo el botón atrás y
    // los gestos del sistema.
    canPop: !_isDirty,
    onPopInvokedWithResult: (bool didPop, Object? _) async {
      if (didPop || !await _confirmDiscard() || !context.mounted) return;
      Navigator.pop(context);
    },
    child: BlueprintScaffold(
      appBar: BlueprintFormAppBar(
        title: _isEditing ? 'Editar aplicación' : 'Nueva aplicación',
      ),
      body: BlueprintFormBody(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SectionHeader(label: 'ICONO'),
              const SizedBox(height: 12),
              _buildIconUpload(),
              const SizedBox(height: 32),
              const SectionHeader(label: 'DATOS_APP'),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: 'Nombre de la aplicación',
                controller: _nameController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: _required,
                suffixIcon: const Icon(Icons.label_outline),
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: _isBundleIdOptional
                    ? 'Bundle ID (opcional)'
                    : 'Bundle ID',
                controller: _bundleIdController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: _validateBundleId,
                suffixIcon: const Icon(Icons.fingerprint),
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: 'Descripción',
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              BlueprintTextField(
                label: 'URL de despliegue (opcional)',
                controller: _deployUrlController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                validator: _optionalUrl,
                suffixIcon: const Icon(Icons.link),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: BlueprintTextField(
                      label: 'Versión',
                      controller: _versionController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _validateVersion,
                      suffixIcon: const Icon(Icons.tag),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: BlueprintTextField(
                      label: 'Build',
                      controller: _buildController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: _validateBuild,
                      onFieldSubmitted: (_) => _saveApp(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const SectionHeader(label: 'ESTADO'),
              const SizedBox(height: 12),
              SegmentedButton<AppStatus>(
                showSelectedIcon: false,
                segments: <ButtonSegment<AppStatus>>[
                  for (AppStatus status in AppStatus.values)
                    ButtonSegment<AppStatus>(
                      value: status,
                      label: Text(status.label.toUpperCase()),
                    ),
                ],
                selected: <AppStatus>{_status},
                onSelectionChanged: (Set<AppStatus> selection) {
                  setState(() => _status = selection.single);
                  _updateDirty();
                },
              ),
              const SizedBox(height: 32),
              const SectionHeader(label: 'PLATAFORMAS'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (AppPlatform platform in AppPlatform.values)
                    _buildPlatformChip(platform),
                  for (String platform in _otherPlatforms)
                    Chip(
                      label: Text(platform.toUpperCase()),
                      deleteButtonTooltipMessage: 'Quitar',
                      onDeleted: _isSaving
                          ? null
                          : () => _removeOtherPlatform(platform),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              BlueprintPrimaryButton(
                label: _isEditing ? 'GUARDAR_CAMBIOS' : 'REGISTRAR_APP',
                icon: _isEditing ? Icons.save_outlined : Icons.bolt,
                loading: _isSaving,
                onPressed: _isPickingIcon ? null : _saveApp,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildPlatformChip(AppPlatform platform) {
    bool selected = _platforms.contains(platform);
    Color foreground = selected
        ? BlueprintColors.onAccent
        : BlueprintColors.textPrimary;
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      avatar: Icon(platform.icon, size: 18, color: foreground),
      label: Text(platform.value.toUpperCase()),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: foreground,
        letterSpacing: 1,
      ),
      selectedColor: BlueprintColors.accentOrange,
      side: BorderSide(
        color: selected
            ? BlueprintColors.accentOrange
            : BlueprintColors.outline,
      ),
      onSelected: _isSaving
          ? null
          : (bool value) => _togglePlatform(platform, value),
    );
  }

  Widget _buildIconUpload() => Column(
    children: <Widget>[
      Center(
        child: SizedBox(
          width: 128,
          height: 128,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: BlueprintColors.surfaceContainerLow,
                    border: Border.all(color: BlueprintColors.outline),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: _isSaving ? null : _pickIcon,
                      child: _isPickingIcon
                          ? const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            )
                          : _iconUrl != null
                          ? Image.network(
                              _iconUrl!,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (
                                    _,
                                    Widget child,
                                    ImageChunkEvent? progress,
                                  ) => progress == null
                                  ? child
                                  : const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                      ),
                                    ),
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                color: BlueprintColors.textMuted,
                              ),
                            )
                          : _assetIcon != null
                          ? Image.asset(
                              'assets/apps/$_assetIcon.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.apps,
                                color: BlueprintColors.textMuted,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.cloud_upload_outlined,
                                  color: BlueprintColors.accentOrange,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'SUBIR_ICONO',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: BlueprintColors.accentOrange,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: IgnorePointer(
                  child: CornerBrackets(
                    size: 10,
                    inset: 0,
                    color: BlueprintColors.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_iconUrl != null || _assetIcon != null)
        TextButton(
          onPressed: _isSaving || _isPickingIcon ? null : _removeIcon,
          child: const Text('QUITAR ICONO'),
        ),
    ],
  );
}
