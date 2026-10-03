part of com.app_track_ota_labs.app.widgets;

/// KPI principal del dashboard: total de apps en grande + barra segmentada
/// con el desglose por estado (LIVE / REVIEW / DRAFT) y su leyenda, dentro de
/// un panel con corchetes de esquina tipo telemetría CAD.
class StatsCard extends StatelessWidget {
  const StatsCard({
    required this.title,
    required this.total,
    required this.live,
    required this.inReview,
    required this.draft,
    super.key,
  });

  final String title;

  /// `null` mientras carga: muestra `--` y la barra vacía.
  final int? total;
  final int live;
  final int inReview;
  final int draft;

  @override
  Widget build(BuildContext context) {
    int count = total ?? 0;
    int liveRatio = count == 0 ? 0 : (live * 100 / count).round();
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BlueprintColors.surfaceContainerLow,
            border: kIndustrialBorder,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    '┌─ ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: BlueprintColors.accentOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(letterSpacing: 2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const CustomBadge(
                    label: 'METRIC://FLEET',
                    color: BlueprintColors.accentOrange,
                    filled: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    total?.toString() ?? '--',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: BlueprintColors.accentOrange,
                      height: 1,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'UNITS_MANAGED',
                      style: AppTextStyles.bodySmall.copyWith(letterSpacing: 2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (count > 0)
                    Text(
                      '↑ $liveRatio% LIVE',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: BlueprintColors.successGreen,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _StatusBar(live: live, inReview: inReview, draft: draft),
              const SizedBox(height: 10),
              const Divider(height: 1, color: BlueprintColors.outlineVariant),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _LegendItem(
                      label: 'LIVE',
                      value: live,
                      color: BlueprintColors.successGreen,
                    ),
                  ),
                  Expanded(
                    child: _LegendItem(
                      label: 'REVIEW',
                      value: inReview,
                      color: BlueprintColors.warning,
                    ),
                  ),
                  Expanded(
                    child: _LegendItem(
                      label: 'DRAFT',
                      value: draft,
                      color: BlueprintColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: CornerBrackets(
              size: 10,
              inset: 0,
              strokeWidth: 2,
              color: BlueprintColors.accentOrange,
            ),
          ),
        ),
      ],
    );
  }
}

/// Barra horizontal segmentada proporcional a cada estado.
class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.live,
    required this.inReview,
    required this.draft,
  });

  final int live;
  final int inReview;
  final int draft;

  @override
  Widget build(BuildContext context) {
    List<(int, Color)> segments = <(int, Color)>[
      (live, BlueprintColors.successGreen),
      (inReview, BlueprintColors.warning),
      (draft, BlueprintColors.textMuted),
    ].where(((int, Color) s) => s.$1 > 0).toList();
    return Container(
      height: 10,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: BlueprintColors.background,
        border: kIndustrialBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < segments.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              flex: segments[i].$1,
              child: ColoredBox(color: segments[i].$2),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(width: 8, height: 8, color: color),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          label,
          style: AppTextStyles.labelSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        '[${value.toString().padLeft(2, '0')}]',
        style: AppTextStyles.labelSmall.copyWith(
          color: color == BlueprintColors.textMuted
              ? BlueprintColors.textPrimary
              : color,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
