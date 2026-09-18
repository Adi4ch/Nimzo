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

  @override
  Future<Map<String, dynamic>?> getAgency(String userId) async {
    final host = await _client.from('host_profiles').select('agency_name').eq('user_id', userId).maybeSingle();
    final name = host?['agency_name'];
    if (name == null || name.toString().isEmpty) return null;
    final row = await _client.from('agencies').select().eq('name', name).maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  @override
  Future<List<Map<String, dynamic>>> getAgencyHosts(String agencyId) async {
    final rows = await _client.from('agency_hosts').select('*, host_profiles(*)').eq('agency_id', agencyId);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<Map<String, dynamic>> createAgency(String name, String description) async => Map<String, dynamic>.from(await _client.rpc('create_agency', params: {'agency_name': name, 'agency_description': description}) as Map);

  @override
  Future<void> addAgencyHost(String agencyId, String hostId) async { await _client.rpc('add_agency_host', params: {'target_agency': agencyId, 'target_host': hostId}); }

  @override
  Future<void> removeAgencyHost(String agencyId, String hostId) async { await _client.rpc('remove_agency_host', params: {'target_agency': agencyId, 'target_host': hostId}); }

  @override
  Future<Map<String, dynamic>> getStatistics(String userId) async {
    final gifts = await _client.from('gift_events').select('total_cost').eq('receiver_id', userId);
    final rooms = await _client.from('rooms').select('id').eq('host_id', userId);
    return {'gifts_received': gifts.fold<int>(0, (sum, row) => sum + (row['total_cost'] as num? ?? 0).toInt()), 'rooms_hosted': rooms.length};
  }
}
