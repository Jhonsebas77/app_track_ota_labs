part of com.app_track_ota_labs.app.widgets;

/// Scaffold compartido: pinta el grid overlay del design system detrás del
/// contenido. Usar en vez de [Scaffold] en cada pantalla para heredar el
/// fondo/grid de forma consistente.
class BlueprintScaffold extends StatelessWidget {
  const BlueprintScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: BlueprintColors.background,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    appBar: appBar,
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: bottomNavigationBar,
    // `expand`: sin esto el Stack toma el tamaño de [body], y un body que se
    // encoge a su contenido (ej. `SingleChildScrollView` con poco contenido)
    // dejaba el grid cortado donde terminaba el contenido.
    body: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const Positioned.fill(
          child: CustomPaint(painter: GridOverlayPainter()),
        ),
        body,
      ],
    ),
  );
}
