import 'package:app_track_ota_labs/ui/theme/theme.dart';
import 'package:app_track_ota_labs/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('El grid cubre todo el body aunque el contenido sea corto', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme,
        home: const BlueprintScaffold(
          appBar: BlueprintFormAppBar(title: 'Detalle'),
          body: BlueprintFormBody(child: Text('Contenido corto')),
        ),
      ),
    );

    Finder grid = find.byWidgetPredicate(
      (Widget widget) =>
          widget is CustomPaint && widget.painter is GridOverlayPainter,
    );
    Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(
      tester.getSize(grid),
      Size(screen.width, screen.height - kToolbarHeight),
    );
  });
}
