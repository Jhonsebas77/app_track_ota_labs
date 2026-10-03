part of com.app_track_ota_labs.app.core.providers;

class AppProvider with ChangeNotifier {
  AppProvider() {
    Supabase.instance.client.auth.onAuthStateChange.listen((AuthState data) {
      notifyListeners();
    });
  }
  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;
  User? get user => Supabase.instance.client.auth.currentUser;

  Future<void> login(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout(BuildContext context) async {
    if (context.mounted) {
      showSuccessSnackBar(context, 'Logout successfully');
    }
    await Supabase.instance.client.auth.signOut();
  }
}
