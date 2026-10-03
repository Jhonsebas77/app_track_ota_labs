part of com.app_track_ota_labs.app.widgets;

/// Panel con el número de apps por plataforma como barras horizontales,
/// relativas al total de apps.
class PlatformBreakdownCard extends StatelessWidget {
  const PlatformBreakdownCard({
    required this.counts,
    required this.total,
    super.key,
  });

  /// Plataforma (`iOS`, `Android`, `Web`) → número de apps que la incluyen.
  final Map<String, int> counts;
  final int total;

  @override
  Widget build(BuildContext context) => _Panel(
    label: 'PLATFORMS',
    trailing: 'N=${counts.values.fold(0, (int a, int b) => a + b)}',
    child: Column(
      children: <Widget>[
        for (MapEntry<String, int> entry in counts.entries) ...<Widget>[
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  entry.key.toUpperCase(),
                  style: AppTextStyles.labelSmall,
                ),
              ),
              Text(
                entry.value.toString().padLeft(2, '0'),
                style: AppTextStyles.labelSmall.copyWith(
                  color: BlueprintColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 6,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: BlueprintColors.background,
              border: Border.all(color: BlueprintColors.outlineVariant),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: total == 0 ? 0 : entry.value / total,
              child: const ColoredBox(color: BlueprintColors.accentOrange),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Panel con la app registrada más recientemente: nombre, versión y fecha.
class LatestEntryCard extends StatelessWidget {
  const LatestEntryCard({required this.app, super.key, this.onTap});

  /// `null` cuando todavía no hay apps.
  final AppModel? app;
  final VoidCallback? onTap;

  static String _formatDate(DateTime date) {
    DateTime local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  @override
  Widget build(BuildContext context) {
    AppModel? app = this.app;
    return GestureDetector(
      onTap: app == null ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: _Panel(
        label: 'LATEST_ENTRY',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            Text(
              app?.name ?? '--',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            if (app != null)
              CustomBadge(
                label: 'v${app.version}',
                color: BlueprintColors.successGreen,
                filled: true,
              ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: BlueprintColors.outlineVariant),
            const SizedBox(height: 8),
            Text(
              'CREATED_AT',
              style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
            ),
            const SizedBox(height: 2),
            Text(
              app?.createdAt != null ? _formatDate(app!.createdAt!) : '--',
              style: AppTextStyles.labelSmall.copyWith(
                color: BlueprintColors.accentOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenedor común de los paneles secundarios del dashboard.
class _Panel extends StatelessWidget {
  const _Panel({required this.label, required this.child, this.trailing});

  final String label;
  final String? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: BlueprintColors.surfaceContainerLow,
      border: kIndustrialBorder,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 9,
                  color: BlueprintColors.accentOrange,
                ),
              ),
          ],
        ),
        child,
      ],
    ),
  );
}
