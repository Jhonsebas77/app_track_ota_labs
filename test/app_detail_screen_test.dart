import 'package:app_track_ota_labs/core/models/models.dart';
import 'package:app_track_ota_labs/core/providers/providers.dart';
import 'package:app_track_ota_labs/ui/theme/theme.dart';
import 'package:app_track_ota_labs/ui/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

AppModel _app({String? deployUrl}) => AppModel(
  id: '1',
  name: 'Test App',
  description: 'Una app de prueba',
  bundleId: 'com.test.app',
  color: Colors.red,
  platform: <String>['iOS', 'Web'],
  version: '1.2.0',
  status: 'Draft',
  deployUrl: deployUrl,
  createdAt: DateTime(2026, 10, 2, 9, 5),
);

Future<void> _pump(WidgetTester tester, AppModel app) => tester.pumpWidget(
  ProviderScope(
    // Sin Supabase en los tests: la lista es solo la app del detalle.
    overrides: <Override>[
      appsProvider.overrideWith((Ref ref) async => <AppModel>[app]),
    ],
    child: MaterialApp(
      theme: appTheme,
      home: AppDetailScreen(app: app),
    ),
  ),
);

void main() {
  testWidgets('Muestra los datos de la app', (WidgetTester tester) async {
    await _pump(tester, _app(deployUrl: 'https://test.app'));

    expect(find.text('Test App'), findsWidgets);
    expect(find.text('Una app de prueba'), findsOneWidget);
    expect(find.text('IOS'), findsOneWidget);
    expect(find.text('WEB'), findsOneWidget);
    expect(find.text('DRAFT'), findsWidgets);
    expect(find.text('com.test.app'), findsOneWidget);
    expect(find.text('2026-10-02 09:05'), findsOneWidget);
    expect(find.text('DEPLOYMENT'), findsOneWidget);
    expect(find.text('https://test.app'), findsOneWidget);
  });

  testWidgets('Oculta DEPLOYMENT sin URL', (WidgetTester tester) async {
    await _pump(tester, _app());

    expect(find.text('DEPLOYMENT'), findsNothing);
  });

  testWidgets('Pide confirmación antes de eliminar', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _app());

    Finder deleteButton = find.text('Eliminar aplicación');
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    expect(
      find.text('¿Eliminar "Test App"? Esta acción no se puede deshacer.'),
      findsOneWidget,
    );

    await tester.tap(find.text('CANCELAR'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(AppDetailScreen), findsOneWidget);
  });

  testWidgets('Editar abre el formulario con los datos de la app', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _app(deployUrl: 'https://test.app'));

    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar aplicación'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Test App'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'com.test.app'), findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'https://test.app'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextFormField, '1.2.0'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    expect(find.text('IN REVIEW'), findsOneWidget);
    expect(find.text('SAVE_CHANGES'), findsOneWidget);
  });

  testWidgets('Crear muestra versión 1.0.0 y status DRAFT por defecto', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: appTheme, home: const AddApplicationScreen()),
      ),
    );

    expect(find.text('Nueva aplicación'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '1.0.0'), findsOneWidget);
    expect(find.text('STATUS'), findsOneWidget);
    SegmentedButton<String> status = tester.widget<SegmentedButton<String>>(
      find.byWidgetPredicate(
        (Widget w) => w is SegmentedButton<String> && !w.multiSelectionEnabled,
      ),
    );
    expect(status.selected, <String>{'Draft'});
  });
}
