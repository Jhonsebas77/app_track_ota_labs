library com.app_track_ota_labs.app.navigator;

import 'package:flutter/material.dart';

import '../core/enums/enums.dart';
import '../core/utils/utils.dart';
import 'widgets/widgets.dart';

class CustomNavigator {
  static const Logger _log = Logger('CustomNavigator');

  /// Navega a [view]. [route] es el `static const String route` de la view
  /// (ej. `SettingsView.route`): se guarda como nombre de la ruta y, en web,
  /// el Navigator raíz lo reporta al navegador, así que aparece en la barra
  /// de direcciones (`/#/settings`) y el botón "atrás" del navegador vuelve a
  /// la pantalla anterior.
  void push(
    BuildContext context,
    Widget view, {
    required String route,
    CustomNavigationAnimation animation = CustomNavigationAnimation.slideRight,
  }) {
    Navigator.of(context).push(
      AnimationRoute(page: view, routeName: route, animationType: animation),
    );
  }

  void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      _log.error('pop: no hay más páginas para hacer pop.');
      if (context.mounted) {
        showErrorSnackBar(context, 'No hay mas páginas');
      }
    }
  }

  bool canPop(BuildContext context) => Navigator.canPop(context);
}

class AnimationRoute extends PageRouteBuilder<Widget> {
  AnimationRoute({
    required this.page,
    required String routeName,
    CustomNavigationAnimation animationType =
        CustomNavigationAnimation.slideRight,
  }) : super(
         settings: RouteSettings(name: routeName),
         transitionDuration: const Duration(milliseconds: 300),
         pageBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
             ) => page,
         transitionsBuilder:
             (
               BuildContext context,
               Animation<double> animation,
               Animation<double> secondaryAnimation,
               Widget child,
             ) => switch (animationType) {
               CustomNavigationAnimation.fade => FadeTransition(
                 opacity: animation,
                 child: child,
               ),
               CustomNavigationAnimation.slideRight => SlideTransition(
                 position: animation.drive(_slideFromRight),
                 child: child,
               ),
               CustomNavigationAnimation.scale => ScaleTransition(
                 scale: animation.drive(_scaleUp),
                 child: child,
               ),
               CustomNavigationAnimation.scaleFade => ScaleTransition(
                 scale: animation.drive(_scaleUp),
                 child: FadeTransition(opacity: animation, child: child),
               ),
               CustomNavigationAnimation.slideBottom => SlideTransition(
                 position: animation.drive(_slideFromBottom),
                 child: child,
               ),
             },
       );
  final Widget page;

  static final Tween<Offset> _slideFromRight = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  );
  static final Tween<Offset> _slideFromBottom = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );
  static final Tween<double> _scaleUp = Tween<double>(begin: 0.5, end: 1);
}
