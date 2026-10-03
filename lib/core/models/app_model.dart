part of com.app_track_ota_labs.app.core.models;

class AppModel {
  AppModel({
    required this.id,
    required this.name,
    required this.description,
    required this.bundleId,
    required this.color,
    required this.platform,
    required this.version,
    this.icon,
    this.status = 'Live',
    this.developPlatform = 'Flutter',
    this.deployUrl,
    this.createdAt,
  });

  factory AppModel.fromMap(Map<String, dynamic> map) {
    dynamic platformsRaw = map['platform'];
    List<String> platformsList =
        (platformsRaw as List<dynamic>?)
            ?.map((dynamic item) => item.toString())
            .toList() ??
        <String>[];
    int colorValue = _parseColor(map['color']);
    return AppModel(
      id: map['app_id']?.toString() ?? '',
      name: map['app_name'] as String? ?? 'Unnamed App',
      description: map['app_description'] as String? ?? '',
      bundleId: map['bundle_id'] as String? ?? '',
      icon: map['icon'] as String? ?? '',
      color: Color(colorValue),
      platform: platformsList,
      status: map['status'] as String? ?? 'Live',
      developPlatform: map['develop_platform'] as String? ?? '',
      version: map['version'] as String? ?? '0.0.1',
      deployUrl: map['deploy_url'] as String?,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }

  static int _parseColor(dynamic colorData) {
    if (colorData is int) return colorData;
    if (colorData is String) {
      String hexString = colorData.replaceAll('#', '');
      return int.tryParse('FF$hexString', radix: 16) ?? 0xFF000000;
    }
    return 0xFF000000;
  }

  String? get iconApp => icon != null && icon!.isEmpty ? 'default' : icon;

  /// `true` cuando [icon] es una URL (icono subido a Supabase Storage) en vez
  /// del nombre de un asset local en `assets/apps/`.
  bool get hasRemoteIcon => icon?.startsWith('http') ?? false;

  final String id;
  final String name;
  final String description;
  final String bundleId;
  final String? icon;
  final Color color;
  final List<String> platform;
  final String status;
  final String developPlatform;
  final String version;
  final String? deployUrl;
  final DateTime? createdAt;
}
