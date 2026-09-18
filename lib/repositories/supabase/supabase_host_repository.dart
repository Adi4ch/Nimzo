import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/host_profile.dart';
import '../host_repository.dart';

class SupabaseHostRepository implements HostRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<HostProfile?> getHostProfile(String userId) async {
    final row = await _client.from('host_profiles').select().eq('user_id', userId).maybeSingle();
    return row == null ? null : HostProfile.fromMap(row);
  }
}
