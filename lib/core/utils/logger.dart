part of com.app_track_ota_labs.app.core.utils;

class Logger {
  const Logger(this.name);

  final String? name;

  String get formattedName => ReCase(name ?? '').titleCase;

  String get formattedDate => DateFormat.yMd().add_jm().format(DateTime.now());

  // `debugPrint` no se elimina en modo release (a diferencia de `assert` o
  // los `kDebugMode`-gated de Flutter), así que sin este guard los logs de
  // error de auth, etc. terminarían en la consola del navegador/dispositivo
  // en producción. No hay backend de crash reporting hoy a donde mandarlos,
  // así que en release simplemente no se emiten.
  void info(String msg) {
    if (kReleaseMode) return;
    debugPrint('\x1B[32m$formattedDate [$formattedName]: $msg\x1B[0m');
  }

  void error(String msg) {
    if (kReleaseMode) return;
    debugPrint('\x1B[31m$formattedDate [$formattedName]: $msg\x1B[0m');
  }

  void warning(String msg) {
    if (kReleaseMode) return;
    debugPrint('\x1B[33m$formattedDate [$formattedName]: $msg\x1B[0m');
  }
}
