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
  static const List<String> _platforms = <String>['iOS', 'Android', 'Web'];
  static const List<String> _statuses = <String>['Draft', 'In Review', 'Live'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bundleIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deployUrlController = TextEditingController();
  final TextEditingController _versionController = TextEditingController();
  Set<String> _selectedPlatforms = <String>{'iOS'};
  String _status = 'Draft';
  bool _isSaving = false;

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

  @override
  void initState() {
    super.initState();
    _iconPicker = ref.read(appIconPickerServiceProvider);
    AppModel? app = widget.initial;
    // Versión inicial de una app nueva (antes se guardaba fija al insertar).
    _versionController.text = app?.version ?? '1.0.0';
    if (app != null) {
      _nameController.text = app.name;
      _bundleIdController.text = app.bundleId;
      _descriptionController.text = app.description;
      _deployUrlController.text = app.deployUrl ?? '';
      _selectedPlatforms = app.platform.where(_platforms.contains).toSet();
      if (_selectedPlatforms.isEmpty) _selectedPlatforms = <String>{'iOS'};
      _status = _statuses.contains(app.status) ? app.status : 'Draft';
      if (app.hasRemoteIcon) _iconUrl = app.icon;
    }
  }

  bool get _isEditing => widget.initial != null;

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
    if (previous != null) unawaited(_discardIcon(previous));
  }

  void _removeIcon() {
    String? previous = _iconUrl;
    setState(() {
      _iconUrl = null;
      _iconChanged = true;
    });
    if (previous != null) unawaited(_discardIcon(previous));
  }

  /// Borra un icono subido en este formulario que ya no se va a usar; si
  /// falla solo queda un archivo huérfano en el bucket, así que no se le
  /// muestra nada al usuario. El icono original de la app nunca se borra
  /// aquí: si se cancela la edición, la app lo sigue usando.
  Future<void> _discardIcon(String url) => url == _originalIconUrl
      ? Future<void>.value()
      : _iconPicker.delete(url).catchError((_) {});

  Future<void> _saveApp() async {
    if (_isSaving || _isPickingIcon) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      showErrorSnackBar(
        context,
        'ERR: check NAME, BUNDLE_ID, DEPLOY_URL and VERSION',
      );
      return;
    }

    setState(() => _isSaving = true);
    String deployUrl = _deployUrlController.text.trim();
    String? error;
    try {
      AppModel? app = widget.initial;
      if (app == null) {
        await insertApp(
          name: _nameController.text.trim(),
          bundleId: _bundleIdController.text.trim(),
          description: _descriptionController.text.trim(),
          platforms: _selectedPlatforms.toList(),
          version: _versionController.text.trim(),
          status: _status,
          deployUrl: deployUrl.isEmpty ? null : deployUrl,
          iconUrl: _iconUrl,
        );
      } else {
        await updateApp(app.id, <String, dynamic>{
          'app_name': _nameController.text.trim(),
          'bundle_id': _bundleIdController.text.trim(),
          'app_description': _descriptionController.text.trim(),
          'platform': _selectedPlatforms.toList(),
          'deploy_url': deployUrl.isEmpty ? null : deployUrl,
          'version': _versionController.text.trim(),
          'status': _status,
          if (_iconChanged) 'icon': _iconUrl,
        });
      }
    } on PostgrestException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'ERR: UNEXPECTED_FAILURE';
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

  @override
  void dispose() {
    _nameController.dispose();
    _bundleIdController.dispose();
    _descriptionController.dispose();
    _deployUrlController.dispose();
    _versionController.dispose();
    // Se salió del formulario sin guardar: el icono ya estaba subido.
    if (!_saved && _iconUrl != null) unawaited(_discardIcon(_iconUrl!));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlueprintScaffold(
    appBar: BlueprintFormAppBar(
      title: _isEditing ? 'Editar aplicación' : 'Nueva aplicación',
      actions: <Widget>[
        TextButton(
          onPressed: _isSaving ? null : _saveApp,
          child: const Text('GUARDAR'),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: BlueprintFormBody(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SectionHeader(label: 'APP_ICON'),
            const SizedBox(height: 12),
            _buildIconUpload(),
            const SizedBox(height: 32),
            const SectionHeader(label: 'APP_DATA'),
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
              label: 'Bundle ID',
              controller: _bundleIdController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              validator: _required,
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
              textInputAction: TextInputAction.done,
              validator: _optionalUrl,
              suffixIcon: const Icon(Icons.link),
            ),
            const SizedBox(height: 16),
            BlueprintTextField(
              label: 'Versión',
              controller: _versionController,
              keyboardType: TextInputType.text,
              validator: _required,
              suffixIcon: const Icon(Icons.tag),
            ),
            const SizedBox(height: 32),
            const SectionHeader(label: 'STATUS'),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: <ButtonSegment<String>>[
                for (String status in _statuses)
                  ButtonSegment<String>(
                    value: status,
                    label: Text(status.toUpperCase()),
                  ),
              ],
              selected: <String>{_status},
              onSelectionChanged: (Set<String> selection) =>
                  setState(() => _status = selection.single),
            ),
            const SizedBox(height: 32),
            const SectionHeader(label: 'TARGET_PLATFORM'),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              multiSelectionEnabled: true,
              segments: <ButtonSegment<String>>[
                for (String platform in _platforms)
                  ButtonSegment<String>(
                    value: platform,
                    label: Text(platform.toUpperCase()),
                  ),
              ],
              selected: _selectedPlatforms,
              onSelectionChanged: (Set<String> selection) =>
                  setState(() => _selectedPlatforms = selection),
            ),
            const SizedBox(height: 40),
            BlueprintPrimaryButton(
              label: _isEditing ? 'SAVE_CHANGES' : 'REGISTER_APPLICATION',
              icon: _isEditing ? Icons.save_outlined : Icons.bolt,
              loading: _isSaving,
              onPressed: _saveApp,
            ),
          ],
        ),
      ),
    ),
  );

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
                                  'UPLOAD_ICON',
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
