import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signUp({required String email, required String password}) => _client.auth.signUp(email: email, password: password);

  @override
  Future<AuthResponse> signIn({required String email, required String password}) => _client.auth.signInWithPassword(email: email, password: password);

  @override
  Future<void> signOut() => _client.auth.signOut();
}
