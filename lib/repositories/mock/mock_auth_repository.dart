import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthState>.broadcast();
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  Future<AuthResponse> signUp({required String email, required String password, String? displayName}) => throw UnsupportedError('Mock auth does not create accounts.');

  @override
  Future<AuthResponse> signIn({required String email, required String password}) => throw UnsupportedError('Mock auth is not connected.');

  @override
  Future<void> resetPassword(String email) => throw UnsupportedError('Mock auth is not connected.');

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(AuthState(AuthChangeEvent.signedOut, null));
  }
}
