part of com.app_track_ota_labs.app.widgets;

/// Navegación lateral para web/tablet; reemplaza a [BlueprintBottomNavBar]
/// cuando la ventana deja de ser [WindowSize.compact].
///
/// Con [extended] es el sidebar de escritorio de 240px: logo + wordmark
/// arriba, destinos con label, "Nueva aplicación" separado con borde de
/// acento y Ajustes al pie. Sin [extended] es un riel compacto (ícono + label
/// chico) para tablet, que convive con [BlueprintTopAppBar] (logo y ajustes
/// siguen allá).
class BlueprintSideNav extends StatelessWidget {
  const BlueprintSideNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onNewApplicationTap,
    super.key,
    this.extended = false,
    this.headline = 'APP_TRACK',
    this.onSettingsTap,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onNewApplicationTap;
  final bool extended;
  final String headline;
  final VoidCallback? onSettingsTap;

  static const double extendedWidth = 240;
  static const double compactWidth = 88;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: BlueprintColors.background,
      border: Border(right: BorderSide(color: BlueprintColors.outlineVariant)),
    ),
    child: SizedBox(
      width: extended ? extendedWidth : compactWidth,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (extended) _buildHeader(),
            const SizedBox(height: 12),
            for (int i = 0; i < _kNavDestinations.length; i++)
              _SideNavItem(
                icon: _kNavDestinations[i].icon,
                label: _kNavDestinations[i].label,
                extended: extended,
                selected: i == currentIndex,
                onTap: () => onDestinationSelected(i),
              ),
            const SizedBox(height: 12),
            _SideNavItem(
              icon: Icons.add,
              label: extended ? 'Nueva aplicación' : 'Nueva',
              extended: extended,
              selected: false,
              outlined: true,
              onTap: onNewApplicationTap,
            ),
            const Spacer(),
            if (extended && onSettingsTap != null) ...<Widget>[
              const Divider(height: 1, color: BlueprintColors.outlineVariant),
              _SideNavItem(
                icon: Icons.settings,
                label: 'Ajustes',
                extended: true,
                selected: false,
                onTap: onSettingsTap!,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _buildHeader() => DecoratedBox(
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: BlueprintColors.outlineVariant)),
    ),
    child: SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
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
                color: BlueprintColors.accentOrange,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.label,
    required this.extended,
    required this.selected,
    required this.onTap,
    this.outlined = false,
  });

  final IconData icon;
  final String label;
  final bool extended;
  final bool selected;

  /// Borde de acento cuando no está seleccionado (Nueva aplicación).
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color foreground = selected
        ? BlueprintColors.background
        : outlined
        ? BlueprintColors.accentOrange
        : BlueprintColors.textMuted;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: extended ? 12 : 8, vertical: 4),
      child: Material(
        color: selected ? BlueprintColors.accentOrange : Colors.transparent,
        shape: outlined && !selected
            ? const RoundedRectangleBorder(
                side: BorderSide(color: BlueprintColors.accentOrange),
              )
            : kSharpShape,
        child: InkWell(
          onTap: onTap,
          child: extended
              ? SizedBox(
                  height: 44,
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 16),
                      Icon(icon, color: foreground, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label.toUpperCase(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(icon, color: foreground, size: 22),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: foreground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
