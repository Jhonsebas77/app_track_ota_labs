part of com.app_track_ota_labs.app.core.providers;

final SupabaseClient supabase = Supabase.instance.client;

/// Lista de aplicaciones compartida por el dashboard y el tab "Apps". Tras
/// insertar una app se invalida para que ambas pantallas se recarguen.
final FutureProvider<List<AppModel>> appsProvider =
    FutureProvider.autoDispose<List<AppModel>>((Ref ref) => fetchAllApps());

Future<List<AppModel>> fetchAllApps() async {
  PostgrestList response = await supabase
      .schema('app_track')
      .from('all_apps')
      .select()
      .order('created_at', ascending: false);
  return response.map(AppModel.fromMap).toList();
}

/// Inserta una aplicación nueva en `app_track.all_apps` a nombre del usuario
/// autenticado. A diferencia de [fetchAllApps], propaga los errores para que la
/// pantalla que guarda pueda mostrarlos.
Future<void> insertApp({
  required String name,
  required String bundleId,
  required List<String> platforms,
  required String version,
  required String status,
  String description = '',
  String? deployUrl,
  String? iconUrl,
}) async {
  await supabase.schema('app_track').from('all_apps').insert(<String, dynamic>{
    'app_name': name,
    'app_description': description,
    'bundle_id': bundleId,
    'platform': platforms,
    'status': status,
    'develop_platform': 'Flutter',
    'version': version,
    'deploy_url': deployUrl,
    'icon': iconUrl,
    'user_id': supabase.auth.currentUser?.id,
  });
}

/// Elimina la aplicación [appId] de `app_track.all_apps`.
///
/// Sin una policy de DELETE, RLS no da error: el DELETE simplemente no borra
/// ninguna fila. Por eso se piden las filas borradas (`select`) y se lanza un
/// error si no hay ninguna, para que la pantalla no muestre "eliminada" en
/// falso.
Future<void> deleteApp(String appId) async {
  PostgrestList deleted = await supabase
      .schema('app_track')
      .from('all_apps')
      .delete()
      .eq('app_id', appId)
      .select('app_id');
  if (deleted.isEmpty) {
    throw const PostgrestException(
      message: 'ERR: la app no se eliminó (sin permiso o ya no existe)',
    );
  }
}

/// Actualiza la aplicación [appId] con [changes] (columnas de
/// `app_track.all_apps` → valor nuevo).
///
/// Igual que en [deleteApp]: sin una policy de UPDATE, RLS no da error y
/// simplemente no actualiza nada, así que se verifica que haya filas
/// actualizadas.
Future<void> updateApp(String appId, Map<String, dynamic> changes) async {
  PostgrestList updated = await supabase
      .schema('app_track')
      .from('all_apps')
      .update(changes)
      .eq('app_id', appId)
      .select('app_id');
  if (updated.isEmpty) {
    throw const PostgrestException(
      message: 'ERR: la app no se actualizó (sin permiso o ya no existe)',
    );
  }
}
