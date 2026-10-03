part of com.app_track_ota_labs.app.widgets;

/// TopAppBar del design system: avatar leading, headline, ícono de settings
/// trailing y borde inferior de separación.
class BlueprintTopAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BlueprintTopAppBar({
    super.key,
    this.headline = 'APP_TRACK',
    this.onSettingsTap,
  });

  final String headline;
  final VoidCallback? onSettingsTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: BlueprintColors.background,
      border: Border(bottom: BorderSide(color: BlueprintColors.outlineVariant)),
    ),
    child: SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: BlueprintColors.surfaceContainerLow,
              child: Image.asset('assets/logo_ota.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                headline,
                style: AppTextStyles.titleLarge.copyWith(
                  color: BlueprintColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: onSettingsTap,
              icon: const Icon(
                Icons.settings,
                color: BlueprintColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
