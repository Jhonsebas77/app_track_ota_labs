part of com.app_track_ota_labs.app.core.models;

/// Versión de una app con el formato que se guarda en
/// `app_track.all_apps.version`: `v<major>.<minor>.<patch>(<build>)`, por
/// ejemplo `v1.2.0(15)`.
class AppVersion {
  const AppVersion(this.name, this.build);

  /// Versión semántica sin prefijo: `1.2.0`.
  final String name;

  /// Build number, entero positivo.
  final int build;

  static const AppVersion initial = AppVersion('1.0.0', 1);

  static final RegExp namePattern = RegExp(r'^\d+\.\d+\.\d+$');

  /// Acepta el formato canónico y los anteriores (`1.2.0`, `1.2`,
  /// `1.2.0+15`), con el mismo criterio que la migración 0007. Sin build
  /// number se asume `1`.
  static AppVersion? tryParse(String raw) {
    RegExpMatch? match = RegExp(
      r'^v?(\d+)\.(\d+)(?:\.(\d+))?(?:\s*[(+]\s*(\d+)\s*\)?)?$',
    ).firstMatch(raw.trim());
    if (match == null) return null;
    return AppVersion(
      '${match[1]}.${match[2]}.${match[3] ?? '0'}',
      int.parse(match[4] ?? '1'),
    );
  }

  @override
  String toString() => 'v$name($build)';
}
