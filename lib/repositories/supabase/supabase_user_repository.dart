import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/user.dart';
import '../user_repository.dart';

class SupabaseUserRepository implements UserRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<NimzoUser?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    return user == null ? null : getById(user.id);
  }

  @override
  Future<NimzoUser?> getById(String id) async {
    final row = await _client.from('profiles').select().eq('id', id).maybeSingle();
    return row == null ? null : NimzoUser.fromMap(row);
  }
}
