part of com.app_track_ota_labs.app.ui.theme;

/// Clase de tamaño de ventana para el layout adaptativo (web/tablet/móvil).
enum WindowSize {
  /// Móvil: bottom nav bar + contenido a una columna.
  compact,

  /// Tablet / ventana angosta: riel lateral compacto + top app bar.
  medium,

  /// Escritorio: sidebar completo (logo, labels, ajustes) sin top app bar.
  expanded,
}

/// Breakpoints y anchos máximos del layout adaptativo (mismos valores que
/// auto_log_mi_nave_ota_labs).
class Breakpoints {
  Breakpoints._();

  /// Ancho desde el cual se usa [WindowSize.medium].
  static const double medium = 600;

  /// Ancho desde el cual se usa [WindowSize.expanded].
  static const double expanded = 1024;

  /// Ancho máximo de los inputs/columna de los formularios.
  static const double formMaxWidth = 500;

  /// Ancho máximo del área de contenido de los tabs en web.
  static const double contentMaxWidth = 1280;

  static WindowSize windowSizeOf(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width >= expanded) return WindowSize.expanded;
    if (width >= medium) return WindowSize.medium;
    return WindowSize.compact;
  }
}
