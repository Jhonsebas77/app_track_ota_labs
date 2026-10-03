part of com.app_track_ota_labs.app.views;

/// Shell persistente: TopAppBar + BottomNavBar + IndexedStack de los tabs
/// (Inicio / Apps). "Nueva aplicación" no es un tab: se abre como pantalla
/// pusheada desde el botón circular separado (ver [BlueprintBottomNavBar]) y
/// Ajustes desde el ícono del TopAppBar.
///
/// Layout adaptativo según [Breakpoints.windowSizeOf]: en móvil usa el
/// bottom nav; en tablet un riel lateral compacto junto al TopAppBar; en
/// escritorio el sidebar completo (sin TopAppBar, el logo y Ajustes viven en
/// el sidebar). En tablet/escritorio el contenido de los tabs se centra con
/// un ancho máximo de [Breakpoints.contentMaxWidth].
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const List<Widget> _tabs = <Widget>[
    DashboardView(),
    MyApplicationsView(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int tabIndex = ref.watch(selectedTabIndexProvider);
    WindowSize windowSize = Breakpoints.windowSizeOf(context);
    void openSettings() => CustomNavigator().push(
      context,
      const SettingsView(),
      route: SettingsView.route,
    );
    void openNewApplication() => CustomNavigator().push(
      context,
      const AddApplicationScreen(),
      route: AddApplicationScreen.route,
      animation: CustomNavigationAnimation.slideBottom,
    );
    void selectTab(int index) =>
        ref.read(selectedTabIndexProvider.notifier).current = index;
    Widget tabs = IndexedStack(
      index: tabIndex,
      children: <Widget>[
        for (int i = 0; i < _tabs.length; i++)
          TickerMode(enabled: i == tabIndex, child: _tabs[i]),
      ],
    );

    if (windowSize == WindowSize.compact) {
      return BlueprintScaffold(
        appBar: BlueprintTopAppBar(onSettingsTap: openSettings),
        body: tabs,
        bottomNavigationBar: BlueprintBottomNavBar(
          currentIndex: tabIndex,
          onDestinationSelected: selectTab,
          onNewApplicationTap: openNewApplication,
        ),
      );
    }

    bool expanded = windowSize == WindowSize.expanded;
    return BlueprintScaffold(
      appBar: expanded ? null : BlueprintTopAppBar(onSettingsTap: openSettings),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlueprintSideNav(
            extended: expanded,
            currentIndex: tabIndex,
            onDestinationSelected: selectTab,
            onNewApplicationTap: openNewApplication,
            onSettingsTap: openSettings,
          ),
          Expanded(
            // Sin TopAppBar (escritorio) nadie más reserva el área segura
            // superior para el contenido.
            child: SafeArea(
              left: false,
              top: expanded,
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Breakpoints.contentMaxWidth,
                  ),
                  // Constraints tight (ancho y alto completos) para los tabs,
                  // igual que en móvil — Align solo pasa constraints sueltas.
                  child: SizedBox.expand(child: tabs),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
