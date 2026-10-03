part of com.app_track_ota_labs.app.core.providers;

/// Tab seleccionado del shell principal (`AppShell`): 0 = Inicio, 1 = Apps.
class SelectedTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  int get current => state;
  set current(int index) {
    state = index;
  }
}

final NotifierProvider<SelectedTabIndexNotifier, int> selectedTabIndexProvider =
    NotifierProvider<SelectedTabIndexNotifier, int>(
      SelectedTabIndexNotifier.new,
    );
