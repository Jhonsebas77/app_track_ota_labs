part of com.app_track_ota_labs.app.ui.theme;

/// "Sharp 0px corners, industrial borders" del design system — una sola forma
/// compartida aplicada globalmente vía ThemeData en vez de overrides por
/// widget.
const RoundedRectangleBorder kSharpShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.zero,
);

final Border kIndustrialBorder = Border.all(
  color: BlueprintColors.outlineVariant,
  width: 1,
);

const OutlineInputBorder kSharpInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.zero,
  borderSide: BorderSide(color: BlueprintColors.outline),
);
