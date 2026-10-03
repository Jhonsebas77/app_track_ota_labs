part of com.app_track_ota_labs.app.widgets;

class _BlueprintNavDestination {
  const _BlueprintNavDestination(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Destinos de los tabs, compartidos por [BlueprintBottomNavBar] (móvil) y
/// [BlueprintSideNav] (tablet/escritorio).
const List<_BlueprintNavDestination> _kNavDestinations =
    <_BlueprintNavDestination>[
      _BlueprintNavDestination('Inicio', Icons.dashboard),
      _BlueprintNavDestination('Apps', Icons.apps),
    ];

/// BottomNavBar tipo "pill": los destinos en una cápsula, más un botón
/// circular separado a la derecha para registrar una nueva aplicación.
class BlueprintBottomNavBar extends StatelessWidget {
  const BlueprintBottomNavBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onNewApplicationTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onNewApplicationTap;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(color: BlueprintColors.background),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          height: 64,
          child: Row(
            children: <Widget>[
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: BlueprintColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: BlueprintColors.outlineVariant),
                  ),
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < _kNavDestinations.length; i++)
                        Expanded(
                          child: _NavItem(
                            destination: _kNavDestinations[i],
                            selected: i == currentIndex,
                            onTap: () => onDestinationSelected(i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _NewApplicationButton(onTap: onNewApplicationTap),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _BlueprintNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color foreground = selected
        ? BlueprintColors.background
        : BlueprintColors.textMuted;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: selected ? BlueprintColors.accentOrange : Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(destination.icon, color: foreground, size: 20),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: AppTextStyles.labelMedium.copyWith(color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón circular separado de la cápsula de tabs, para registrar una app.
class _NewApplicationButton extends StatelessWidget {
  const _NewApplicationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 64,
    height: 64,
    child: Material(
      color: BlueprintColors.surfaceContainerLow,
      shape: const CircleBorder(
        side: BorderSide(color: BlueprintColors.accentOrange),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Tooltip(
          message: 'Nueva aplicación',
          child: Icon(Icons.add, color: BlueprintColors.accentOrange, size: 26),
        ),
      ),
    ),
  );
}
