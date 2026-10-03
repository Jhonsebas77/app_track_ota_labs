part of com.app_track_ota_labs.app.views;

/// Detalle de una aplicación: se abre al tocar una tarjeta del dashboard o
/// del tab "Apps". Muestra los datos que ya trae [app] del listado, sin
/// volver a consultar Supabase, y permite editar o eliminar la aplicación.
class AppDetailScreen extends ConsumerStatefulWidget {
  const AppDetailScreen({required this.app, super.key});
  static const String route = '/app-detail';

  final AppModel app;

  @override
  ConsumerState<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends ConsumerState<AppDetailScreen> {
  bool _isDeleting = false;

  /// Versión más reciente de la app en [appsProvider] (se recarga tras
  /// editarla); mientras tanto, o si ya no está en la lista, la que se pasó
  /// al abrir el detalle. Usa `read` porque también se llama desde
  /// callbacks; la suscripción la hace `build`.
  AppModel get app =>
      ref
          .read(appsProvider)
          .value
          ?.where((AppModel a) => a.id == widget.app.id)
          .firstOrNull ??
      widget.app;

  void _editApp() => CustomNavigator().push(
    context,
    AddApplicationScreen(initial: app),
    route: AddApplicationScreen.editRoute,
    animation: CustomNavigationAnimation.slideBottom,
  );

  Future<bool> _confirmDelete() async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Eliminar aplicación'),
          content: Text(
            '¿Eliminar "${app.name}"? Esta acción no se puede deshacer.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: BlueprintColors.danger,
              ),
              child: const Text('ELIMINAR'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _deleteApp() async {
    if (_isDeleting || !await _confirmDelete() || !mounted) return;
    AppIconPickerService iconPicker = ref.read(appIconPickerServiceProvider);
    setState(() => _isDeleting = true);
    String? error;
    try {
      await deleteApp(app.id);
    } on PostgrestException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'ERR: UNEXPECTED_FAILURE';
    }
    if (error == null && app.hasRemoteIcon) {
      // Si falla solo queda un archivo huérfano en el bucket; la app ya se
      // eliminó, así que no se le muestra error al usuario.
      unawaited(iconPicker.delete(app.icon!).catchError((Object _) {}));
    }
    if (!mounted) return;
    if (error != null) {
      setState(() => _isDeleting = false);
      showErrorSnackBar(context, error);
      return;
    }
    ref.invalidate(appsProvider);
    showSuccessSnackBar(context, 'Aplicación eliminada');
    Navigator.pop(context);
  }

  Future<void> _copy(BuildContext context, String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) showSuccessSnackBar(context, '$label copiado');
  }

  Future<void> _openDeployUrl(BuildContext context) async {
    Uri? uri = Uri.tryParse(app.deployUrl ?? '');
    bool opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      showErrorSnackBar(context, 'ERR: no se pudo abrir la URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appsProvider);
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) => BlueprintScaffold(
    appBar: BlueprintFormAppBar(
      title: app.name,
      actions: <Widget>[
        IconButton(
          tooltip: 'Editar',
          onPressed: _isDeleting ? null : _editApp,
          icon: const Icon(Icons.edit_outlined),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: BlueprintFormBody(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 32),
          const SectionHeader(label: 'DESCRIPTION'),
          const SizedBox(height: 12),
          Text(
            app.description.isEmpty ? 'SIN_DESCRIPCIÓN' : app.description,
            style: app.description.isEmpty
                ? AppTextStyles.bodySmall.copyWith(
                    color: BlueprintColors.textMuted,
                    letterSpacing: 1,
                  )
                : AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 32),
          const SectionHeader(label: 'TARGET_PLATFORM'),
          const SizedBox(height: 12),
          if (app.platform.isEmpty)
            Text(
              'SIN_PLATAFORMAS',
              style: AppTextStyles.bodySmall.copyWith(
                color: BlueprintColors.textMuted,
                letterSpacing: 1,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (String platform in app.platform)
                  CustomBadge(
                    label: platform.toUpperCase(),
                    color: BlueprintColors.infoBlue,
                  ),
              ],
            ),
          if (app.deployUrl case String url when url.isNotEmpty) ...<Widget>[
            const SizedBox(height: 32),
            const SectionHeader(label: 'DEPLOYMENT'),
            const SizedBox(height: 12),
            _buildDeployUrl(context, url),
          ],
          const SizedBox(height: 32),
          const SectionHeader(label: 'APP_DATA'),
          const SizedBox(height: 4),
          _buildInfoRow(
            'BUNDLE_ID',
            app.bundleId,
            onCopy: () => _copy(context, 'Bundle ID', app.bundleId),
          ),
          const Divider(height: 1, color: BlueprintColors.outlineVariant),
          _buildInfoRow('VERSION', app.version),
          const Divider(height: 1, color: BlueprintColors.outlineVariant),
          _buildInfoRow('STATUS', app.status.toUpperCase()),
          if (app.developPlatform.isNotEmpty) ...<Widget>[
            const Divider(height: 1, color: BlueprintColors.outlineVariant),
            _buildInfoRow('DEVELOP_PLATFORM', app.developPlatform),
          ],
          if (app.createdAt case DateTime createdAt) ...<Widget>[
            const Divider(height: 1, color: BlueprintColors.outlineVariant),
            _buildInfoRow('REGISTERED', _formatDate(createdAt.toLocal())),
          ],
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: _isDeleting ? null : _deleteApp,
            style: OutlinedButton.styleFrom(
              foregroundColor: BlueprintColors.danger,
              side: const BorderSide(color: BlueprintColors.danger),
            ),
            icon: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                : const Icon(Icons.delete_outline, size: 18),
            label: const Text('Eliminar aplicación'),
          ),
        ],
      ),
    ),
  );

  Widget _buildHeader() => Row(
    children: <Widget>[
      AppIconBox(app: app, size: 88),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(app.name, style: AppTextStyles.titleLarge),
            const SizedBox(height: 6),
            Text(
              '${app.bundleId}  //  v${app.version}',
              style: AppTextStyles.bodySmall.copyWith(
                color: BlueprintColors.accentOrange,
              ),
            ),
            const SizedBox(height: 10),
            AppStatusBadge(status: app.status),
          ],
        ),
      ),
    ],
  );

  Widget _buildDeployUrl(BuildContext context, String url) => DecoratedBox(
    decoration: BoxDecoration(
      color: BlueprintColors.surfaceContainerLow,
      border: kIndustrialBorder,
    ),
    child: ListTile(
      onTap: () => _openDeployUrl(context),
      leading: const Icon(Icons.link, color: BlueprintColors.accentOrange),
      title: Text(
        url,
        style: AppTextStyles.bodySmall.copyWith(
          color: BlueprintColors.textPrimary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: 'Copiar URL',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () => _copy(context, 'URL', url),
          ),
          const Icon(Icons.open_in_new, size: 18),
        ],
      ),
    ),
  );

  Widget _buildInfoRow(String key, String value, {VoidCallback? onCopy}) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: onCopy == null ? 12 : 4),
        child: Row(
          children: <Widget>[
            Text(
              key,
              style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: BlueprintColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onCopy != null)
              IconButton(
                tooltip: 'Copiar',
                icon: const Icon(Icons.copy, size: 16),
                onPressed: onCopy,
              ),
          ],
        ),
      );

  static String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}
