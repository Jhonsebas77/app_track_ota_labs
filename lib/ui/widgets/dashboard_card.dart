part of com.app_track_ota_labs.app.widgets;

/// Tarjeta compacta de app del dashboard: ícono, nombre, descripción,
/// plataformas + versión y badge de estado.
class DashboardCard extends StatelessWidget {
  const DashboardCard({required this.app, super.key, this.onTap});

  final AppModel app;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: BlueprintColors.surfaceContainerLow,
    shape: kIndustrialBorder,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppIconBox(app: app, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    app.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (app.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      app.description,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      for (String platform in app.platform)
                        CustomBadge(
                          label: '[${platform.toUpperCase()}]',
                          color: BlueprintColors.textMuted,
                        ),
                      Text('v${app.version}', style: AppTextStyles.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(status: app.status),
          ],
        ),
      ),
    ),
  );
}
