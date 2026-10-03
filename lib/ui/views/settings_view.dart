part of com.app_track_ota_labs.app.views;

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});
  static const String route = '/settings';

  @override
  Widget build(BuildContext context) {
    User? user = prov.Provider.of<AppProvider>(context).user;

    return BlueprintScaffold(
      appBar: const BlueprintFormAppBar(title: 'Configuración'),
      body: BlueprintFormBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (user?.email != null) ...<Widget>[
              Text(user!.email!, style: AppTextStyles.titleMedium),
              const SizedBox(height: 24),
            ],
            const SectionHeader(label: 'SYSTEM_CONFIG'),
            const SizedBox(height: 12),
            const VersionWidget(),
            const SizedBox(height: 32),
            const SectionHeader(label: 'BUILD_INFO'),
            const SizedBox(height: 4),
            _buildInfoRow('ENVIRONMENT', kReleaseModeLabel),
            const Divider(height: 1, color: BlueprintColors.outlineVariant),
            _buildInfoRow('PLATFORM', 'FLUTTER'),
            const Divider(height: 1, color: BlueprintColors.outlineVariant),
            _buildInfoRow('THEME', 'ENGINEERING_BLUEPRINT'),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }

  static const String kReleaseModeLabel = kReleaseMode
      ? 'PRODUCTION'
      : 'DEVELOPMENT';

  /// Cierra sesión y vuelve a la raíz: `AuthWrapper` muestra el login, pero
  /// esta pantalla está pusheada encima y no se quita sola.
  Future<void> _logout(BuildContext context) async {
    NavigatorState navigator = Navigator.of(context);
    await prov.Provider.of<AppProvider>(context, listen: false).logout(context);
    navigator.popUntil((Route<dynamic> route) => route.isFirst);
  }

  Widget _buildInfoRow(String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(key, style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1)),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: BlueprintColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
