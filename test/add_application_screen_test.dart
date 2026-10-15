import 'package:app_track_ota_labs/core/enums/enums.dart';
import 'package:app_track_ota_labs/core/models/models.dart';
import 'package:app_track_ota_labs/ui/theme/theme.dart';
import 'package:app_track_ota_labs/ui/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

AppModel _app({List<String> platform = const <String>['iOS']}) => AppModel(
  id: '1',
  name: 'Test App',
  description: '',
  bundleId: 'com.test.app',
  color: Colors.red,
  platform: platform,
  version: 'v1.2.0(15)',
  status: 'Live',
);

/// Abre el formulario desde una pantalla base para poder probar el "atrás".
Future<void> _pump(WidgetTester tester, {AppModel? initial}) async {
  tester.view.physicalSize = const Size(400, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: appTheme,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AddApplicationScreen(initial: initial),
                ),
              ),
              child: const Text('ABRIR'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('ABRIR'));
  await tester.pumpAndSettle();
}

FilterChip _chip(WidgetTester tester, AppPlatform platform) =>
    tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, platform.value.toUpperCase()),
    );

void main() {
  group('AppVersion', () {
    test('Interpreta el formato canónico y los anteriores', () {
      expect(AppVersion.tryParse('v1.2.0(15)').toString(), 'v1.2.0(15)');
      expect(AppVersion.tryParse('1.2.0').toString(), 'v1.2.0(1)');
      expect(AppVersion.tryParse('1.2').toString(), 'v1.2.0(1)');
      expect(AppVersion.tryParse('1.2.0+7').toString(), 'v1.2.0(7)');
      expect(AppVersion.tryParse('beta'), isNull);
    });
  });

  group('AppPlatform', () {
    test('Reconoce plataformas sin distinguir mayúsculas', () {
      expect(AppPlatform.tryParse('MacOs'), AppPlatform.macos);
      expect(AppPlatform.tryParse(' windows '), AppPlatform.windows);
      expect(AppPlatform.tryParse('Tizen'), isNull);
    });
  });

  testWidgets('Muestra las 5 plataformas con iOS seleccionado', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    for (AppPlatform platform in AppPlatform.values) {
      expect(_chip(tester, platform).selected, platform == AppPlatform.ios);
    }

    await tester.tap(find.text('MACOS'));
    await tester.tap(find.text('WINDOWS'));
    await tester.pump();
    expect(_chip(tester, AppPlatform.macos).selected, isTrue);
    expect(_chip(tester, AppPlatform.windows).selected, isTrue);
  });

  testWidgets('No permite quitar la última plataforma', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('IOS'));
    await tester.pump();
    expect(_chip(tester, AppPlatform.ios).selected, isTrue);
  });

  testWidgets('Al editar normaliza plataformas y conserva las desconocidas', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      initial: _app(platform: <String>['ios', 'MacOs', 'Tizen']),
    );

    expect(_chip(tester, AppPlatform.ios).selected, isTrue);
    expect(_chip(tester, AppPlatform.macos).selected, isTrue);
    expect(_chip(tester, AppPlatform.android).selected, isFalse);
    expect(find.widgetWithText(Chip, 'TIZEN'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '1.2.0'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '15'), findsOneWidget);
    expect(find.text('PUBLICADA'), findsOneWidget);
  });

  testWidgets('Valida bundle ID, versión y build', (WidgetTester tester) async {
    await _pump(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre de la aplicación'),
      'Mi App',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Bundle ID'),
      'mi app',
    );
    await tester.enterText(find.widgetWithText(TextFormField, '1.0.0'), '1.0');
    await tester.enterText(find.widgetWithText(TextFormField, '1'), '0');
    await tester.tap(find.text('REGISTRAR_APP'));
    await tester.pump();

    expect(find.text('Formato inválido (ej. com.empresa.app)'), findsOneWidget);
    expect(find.text('Formato inválido (ej. 1.0.0)'), findsOneWidget);
    expect(find.text('Entero mayor a 0'), findsOneWidget);
  });

  testWidgets('Bundle ID es opcional si la única plataforma es web', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('WEB'));
    await tester.tap(find.text('IOS'));
    await tester.pump();
    expect(find.text('Bundle ID (opcional)'), findsOneWidget);

    await tester.tap(find.text('REGISTRAR_APP'));
    await tester.pump();
    // Solo falla el nombre: el bundle ID vacío ya no es un error.
    expect(find.text('Campo requerido'), findsOneWidget);
  });

  testWidgets('Pide confirmación al salir con cambios sin guardar', (
    WidgetTester tester,
  ) async {
    await _pump(tester);

    // Sin cambios sale directo.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(AddApplicationScreen), findsNothing);

    await tester.tap(find.text('ABRIR'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre de la aplicación'),
      'Mi App',
    );
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Descartar cambios'), findsOneWidget);

    await tester.tap(find.text('SEGUIR EDITANDO'));
    await tester.pumpAndSettle();
    expect(find.byType(AddApplicationScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('DESCARTAR'));
    await tester.pumpAndSettle();
    expect(find.byType(AddApplicationScreen), findsNothing);
  });
}
