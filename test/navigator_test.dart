import 'package:app_track_ota_labs/core/enums/enums.dart';
import 'package:app_track_ota_labs/ui/navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('push reporta la ruta de la view al navegador (URL en web)', (
    WidgetTester tester,
  ) async {
    List<String> reportedUris = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.navigation,
      (MethodCall call) async {
        if (call.method == 'routeInformationUpdated') {
          Map<Object?, Object?> args = call.arguments as Map<Object?, Object?>;
          reportedUris.add(args['uri']! as String);
        }
        return null;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () => CustomNavigator().push(
              context,
              const Text('Detalle'),
              route: '/app-detail',
              animation: CustomNavigationAnimation.slideBottom,
            ),
            child: const Text('Abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(reportedUris.last, '/app-detail');

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();
    expect(reportedUris.last, '/');
  });
}
