part of com.app_track_ota_labs.app.views;

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});
  static const String route = '/dashboard';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<AppModel>> apps = ref.watch(appsProvider);
    List<AppModel> list = apps.value ?? <AppModel>[];
    List<AppModel> recent = _byNewest(list);
    int live = list.where((AppModel a) => a.status == 'Live').length;
    int draft = list.where((AppModel a) => a.status == 'Draft').length;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(appsProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: <Widget>[
          const _DashboardHeader().animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          StatsCard(
                title: 'TOTAL_APPLICATIONS',
                total: apps.hasValue ? list.length : null,
                live: live,
                inReview: list.length - live - draft,
                draft: draft,
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .slideY(
                begin: -0.1,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: PlatformBreakdownCard(
                    counts: <String, int>{
                      for (String p in _AddApplicationScreenState._platforms)
                        p: list
                            .where((AppModel a) => a.platform.contains(p))
                            .length,
                    },
                    total: list.length,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: LatestEntryCard(
                    app: recent.firstOrNull,
                    onTap: () => _openDetail(context, recent.first),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 150.ms),
          const SizedBox(height: 32),
          SectionHeader(
            label: 'RECENT_APPLICATIONS',
            actionLabel: 'VIEW_ALL',
            onActionTap: () =>
                ref.read(selectedTabIndexProvider.notifier).current = 1,
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
          const SizedBox(height: 16),
          _AppList(
            apps: apps,
            recent: recent.take(_recentLimit).toList(),
          ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
        ],
      ),
    );
  }
}

/// Apps que muestra la lista resumida del dashboard.
const int _recentLimit = 5;

/// [apps] de la más reciente a la más antigua según `createdAt`; las que no
/// tienen fecha van al final.
List<AppModel> _byNewest(List<AppModel> apps) => <AppModel>[...apps]
  ..sort((AppModel a, AppModel b) {
    DateTime? da = a.createdAt;
    DateTime? db = b.createdAt;
    if (da == null || db == null) return da == null ? (db == null ? 0 : 1) : -1;
    return db.compareTo(da);
  });

/// Encabezado del dashboard: ruta "de sistema", título y fecha actual.
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: BlueprintColors.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    text: 'SYS://DASHBOARD ',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: BlueprintColors.accentOrange,
                      letterSpacing: 2,
                    ),
                    children: const <InlineSpan>[
                      TextSpan(
                        text: 'REV.A1',
                        style: TextStyle(color: BlueprintColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text('OVERVIEW', style: AppTextStyles.headlineLarge),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'SYS_DATE',
                style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 2),
              Text(
                '${now.year}-${two(now.month)}-${two(now.day)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: BlueprintColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lista resumida de las apps más recientes del dashboard.
class _AppList extends StatelessWidget {
  const _AppList({required this.apps, required this.recent});

  final AsyncValue<List<AppModel>> apps;
  final List<AppModel> recent;

  @override
  Widget build(BuildContext context) {
    Widget? status = _appsStatus(apps);
    if (status != null) return status;
    List<AppModel> list = recent;
    return Column(
      children: <Widget>[
        for (int i = 0; i < list.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          DashboardCard(
            app: list[i],
            onTap: () => _openDetail(context, list[i]),
          ),
        ],
      ],
    );
  }
}

/// Abre el detalle de [app]; lo usan el dashboard y el tab "Apps".
void _openDetail(BuildContext context, AppModel app) => CustomNavigator().push(
  context,
  AppDetailScreen(app: app),
  route: AppDetailScreen.route,
);

/// Estado de carga, error o lista vacía para [appsProvider]; `null` cuando
/// hay apps que mostrar. Lo comparten el dashboard y el tab "Apps".
Widget? _appsStatus(AsyncValue<List<AppModel>> apps) => switch (apps) {
  AsyncData<List<AppModel>>(:List<AppModel> value) when value.isNotEmpty =>
    null,
  AsyncData<List<AppModel>>() => const _EmptyState(
    icon: Icons.inbox_outlined,
    label: 'NO_APPLICATIONS_REGISTERED',
  ),
  AsyncError<List<AppModel>>(:Object error) => _EmptyState(
    icon: Icons.error_outline,
    label: 'ERR: $error',
    color: BlueprintColors.danger,
  ),
  _ => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
  ),
};

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.label,
    this.color = BlueprintColors.textMuted,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}
