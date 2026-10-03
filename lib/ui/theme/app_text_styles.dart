part of com.app_track_ota_labs.app.ui.theme;

/// Estilos de texto estáticos, accesibles sin `Theme.of(context)` (ej.
/// `AppTextStyles.bodySmall`). Son la fuente única de verdad para
/// `appTheme`/`appDarkTheme`.textTheme (ver app_theme.dart). Fijan su color
/// desde `BlueprintColors` (no desde el `ColorScheme` claro/oscuro): casi
/// toda la app pinta su fondo con `BlueprintColors.background` a través de
/// `BlueprintScaffold`, sin importar el tema del sistema, así que el texto
/// necesita un color fijo con buen contraste sobre ese fondo oscuro en vez
/// de heredar un `onSurface` que se vuelve casi negro en tema claro.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'JetBrainsMono';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.bold,
    color: BlueprintColors.textPrimary,
  );

  /// Wordmark de marca.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: BlueprintColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: BlueprintColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: BlueprintColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: BlueprintColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    color: BlueprintColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    color: BlueprintColors.textPrimary,
  );

  /// Labels, subtítulos y metadatos.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.3,
    color: BlueprintColors.textMuted,
  );

  /// Usado por el bottom nav bar / side nav.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: BlueprintColors.textMuted,
  );

  /// Usado por badges/etiquetas chicas.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    color: BlueprintColors.textMuted,
  );
}
