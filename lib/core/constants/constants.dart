library com.app_track_ota_labs.app.core.constants;

/// Credenciales y configuración inyectadas en build time con `--dart-define`
/// (o `--dart-define-from-file=config/dart_defines.local.json`). Ver README.
const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);

/// Usuario con el que inicia sesión el login: la pantalla solo pide la
/// contraseña de este usuario.
const String hardcodedEmail = String.fromEnvironment('AUTH_EMAIL');
