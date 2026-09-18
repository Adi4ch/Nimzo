import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client =>
      SupabaseBootstrap.client ??
      (throw StateError('Supabase is not configured.'));

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUp(
          {required String email,
          required String password,
          String? displayName}) =>
      _client.auth.signUp(
          email: email,
          password: password,
          data: {'display_name': displayName});

  @override
  Future<AuthResponse> signIn(
      {required String email, required String password}) async {
    final response =
        await _client.auth.signInWithPassword(email: email, password: password);
    await _client.rpc('record_user_activity', params: {'event_code': 'login'});
    return response;
  }

    @override
    Future<bool> signInWithGoogle() => _client.auth.signInWithOAuth(
                OAuthProvider.google,
                redirectTo: 'io.supabase.nimzo://login-callback',
                authScreenLaunchMode: LaunchMode.externalApplication,
            );

  @override
  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  @override
  Future<void> signOut() => _client.auth.signOut();

    @override
    Future<void> deleteAccount() => _client.rpc('delete_my_account');
}
