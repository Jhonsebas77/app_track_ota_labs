part of com.app_track_ota_labs.app.views;

/// Tab "Apps" del [AppShell]: listado detallado de las aplicaciones.
class MyApplicationsView extends ConsumerWidget {
  const MyApplicationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<AppModel>> apps = ref.watch(appsProvider);
    Widget? status = _appsStatus(apps);
    List<AppModel> list = status == null ? apps.requireValue : <AppModel>[];

    return RefreshIndicator(
      onRefresh: () => ref.refresh(appsProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: <Widget>[
          const SectionHeader(label: 'MY_APPLICATIONS'),
          const SizedBox(height: 16),
          ?status,
          for (int i = 0; i < list.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: 12),
            DetailedCard(
                  app: list[i],
                  onTap: () => _openDetail(context, list[i]),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: (60 * i).ms)
                .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
          ],
        ],
      ),
    );
  }
}
