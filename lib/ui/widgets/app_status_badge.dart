part of com.app_track_ota_labs.app.widgets;

/// Color de estado de una app: verde para `Live`, apagado para `Draft` y
/// naranja (warning) para cualquier estado intermedio (`In Review`...).
Color appStatusColor(String status) => switch (status) {
  'Live' => BlueprintColors.successGreen,
  'Draft' => BlueprintColors.textMuted,
  _ => BlueprintColors.warning,
};

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) => CustomBadge(
    label: status.toUpperCase(),
    color: appStatusColor(status),
    filled: true,
    bold: true,
  );
}

/// Ícono de la app sobre fondo oscuro con borde industrial.
class AppIconBox extends StatelessWidget {
  const AppIconBox({required this.app, super.key, this.size = 48});

  final AppModel app;
  final double size;

  static const Widget _fallback = Icon(
    Icons.apps,
    color: BlueprintColors.textMuted,
  );

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: BlueprintColors.background,
      border: Border.all(color: BlueprintColors.outlineVariant),
    ),
    child: app.hasRemoteIcon
        ? Image.network(
            app.icon!,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _fallback,
          )
        : Image.asset(
            'assets/apps/${app.iconApp}.png',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _fallback,
          ),
  );
}
