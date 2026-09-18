import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
  Future<AuthResponse> signUp({required String email, required String password});
  Future<AuthResponse> signIn({required String email, required String password});
  Future<void> signOut();
}
