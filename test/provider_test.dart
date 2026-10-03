import 'dart:convert';

import 'package:app_track_ota_labs/core/models/models.dart';
import 'package:app_track_ota_labs/core/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _email = 'test@yopmail.com';
const String _password = 'password123';

/// Respuesta de GoTrue a `POST /auth/v1/token?grant_type=password`: sesión
/// válida solo para [_email] / [_password]; cualquier otra cosa es 400, igual
/// que el servidor real con credenciales erróneas.
Future<http.Response> _fakeSupabase(http.Request request) async {
  if (!request.url.path.endsWith('/auth/v1/token')) {
    return http.Response('{}', 200);
  }
  Map<String, dynamic> body = jsonDecode(request.body) as Map<String, dynamic>;
  if (body['email'] != _email || body['password'] != _password) {
    return http.Response(
      jsonEncode(<String, String>{
        'error': 'invalid_grant',
        'error_description': 'Invalid login credentials',
      }),
      400,
    );
  }
  int expiresAt = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
  String jwtPart(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  String accessToken =
      '${jwtPart(<String, dynamic>{'alg': 'HS256', 'typ': 'JWT'})}.'
      '${jwtPart(<String, dynamic>{'sub': 'user-1', 'exp': expiresAt})}.'
      'signature';
  return http.Response(
    jsonEncode(<String, dynamic>{
      'access_token': accessToken,
      'token_type': 'bearer',
      'expires_in': 3600,
      'expires_at': expiresAt,
      'refresh_token': 'refresh-token',
      'user': <String, dynamic>{
        'id': 'user-1',
        'aud': 'authenticated',
        'role': 'authenticated',
        'email': _email,
        'app_metadata': <String, dynamic>{},
        'user_metadata': <String, dynamic>{},
        'created_at': DateTime.now().toIso8601String(),
      },
    }),
    200,
    headers: <String, String>{'content-type': 'application/json'},
  );
}

/// Almacenamiento PKCE en memoria: el de por defecto usa SharedPreferences,
/// que no tiene plugin en los tests.
class _MemoryAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> removeItem({required String key}) async => _values.remove(key);

  @override
  Future<void> setItem({required String key, required String value}) async =>
      _values[key] = value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-publishable-key',
      httpClient: MockClient(_fakeSupabase),
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: _MemoryAsyncStorage(),
      ),
    );
  });

  tearDown(() async {
    await Supabase.instance.client.auth.signOut();
  });

  group('AppProvider', () {
    test('Initial state is logged out', () {
      AppProvider provider = AppProvider();
      expect(provider.isLoggedIn, false);
      expect(provider.user, isNull);
    });

    test('Login with correct password works', () async {
      AppProvider provider = AppProvider();
      await provider.login(_email, _password);
      expect(provider.isLoggedIn, true);
      expect(provider.user?.email, _email);
    });

    test('Login with incorrect password fails', () async {
      AppProvider provider = AppProvider();
      await expectLater(
        provider.login(_email, 'wrongPassword'),
        throwsA(isA<AuthException>()),
      );
      expect(provider.isLoggedIn, false);
    });
  });

  group('AppModel.fromMap', () {
    test('Maps the all_apps columns', () {
      AppModel app = AppModel.fromMap(<String, dynamic>{
        'app_id': 7,
        'app_name': 'Test App',
        'app_description': 'Test',
        'bundle_id': 'com.test',
        'icon':
            'https://test.supabase.co/storage/v1/object/public/app-icons/u/1.png',
        'color': '#FF0000',
        'platform': <String>['iOS', 'Web'],
        'status': 'Draft',
        'develop_platform': 'Flutter',
        'version': '1.0.0',
        'deploy_url': 'https://test.app',
      });
      expect(app.id, '7');
      expect(app.name, 'Test App');
      expect(app.bundleId, 'com.test');
      expect(app.color, const Color(0xFFFF0000));
      expect(app.platform, <String>['iOS', 'Web']);
      expect(app.deployUrl, 'https://test.app');
      expect(app.hasRemoteIcon, true);
    });

    test('Uses defaults for missing columns', () {
      AppModel app = AppModel.fromMap(<String, dynamic>{});
      expect(app.name, 'Unnamed App');
      expect(app.platform, isEmpty);
      expect(app.deployUrl, isNull);
      expect(app.iconApp, 'default');
      expect(app.hasRemoteIcon, false);
    });

    test('Local asset icon is not remote', () {
      AppModel app = AppModel.fromMap(<String, dynamic>{
        'icon': 'pogo_checklist',
      });
      expect(app.iconApp, 'pogo_checklist');
      expect(app.hasRemoteIcon, false);
    });
  });
}
