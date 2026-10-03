part of com.app_track_ota_labs.app.widgets;

/// Título de sección: barra de acento a la izquierda + label en mayúsculas,
/// con una acción opcional a la derecha (ej. "VIEW_ALL").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.label,
    super.key,
    this.actionLabel,
    this.onActionTap,
  });

  final String label;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(width: 2, height: 16, color: BlueprintColors.accentOrange),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (actionLabel != null)
        TextButton.icon(
          onPressed: onActionTap,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_ios, size: 12),
          label: Text(
            actionLabel!,
            style: AppTextStyles.labelMedium.copyWith(
              color: BlueprintColors.accentOrange,
              letterSpacing: 1.5,
            ),
          ),
        ),
    ],
  );
}
