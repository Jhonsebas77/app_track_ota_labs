part of com.app_track_ota_labs.app.widgets;

class VersionWidget extends StatefulWidget {
  const VersionWidget({super.key});

  @override
  State<VersionWidget> createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  String _appName = '...';
  String _version = '...';
  String _buildNumber = '...';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _appName = info.appName;
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: BlueprintColors.surfaceContainerLow,
      border: kIndustrialBorder,
    ),
    child: Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: BlueprintColors.background,
            border: kIndustrialBorder,
          ),
          child: Image.asset('assets/logo_ota.png', fit: BoxFit.contain),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SelectableText(
                _appName.toUpperCase(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                'By Ota_Labs  //  v$_version ($_buildNumber)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: BlueprintColors.accentOrange,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
