import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../platform_repository.dart';

class SupabasePlatformRepository implements PlatformRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  Future<List<Map<String, dynamic>>> _rows(String table, {String? order}) async {
    final query = _client.from(table).select();
    final rows = order == null ? await query : await query.order(order);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getVipLevels() => _rows('vip_levels', order: 'level');

  @override
  Future<Map<String, dynamic>?> getCurrentVip() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client.from('user_vip').select('*, vip_levels(*)').eq('user_id', userId).maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  @override
  Future<List<Map<String, dynamic>>> getMallItems() => _rows('mall_items', order: 'category');

  @override
  Future<List<Map<String, dynamic>>> getInventory() async {
    final rows = await _client.from('user_inventory').select('*, mall_items(*)').eq('user_id', _client.auth.currentUser!.id);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyTasks() => _rows('daily_tasks', order: 'title');

  @override
  Future<List<Map<String, dynamic>>> getAchievements() => _rows('achievements', order: 'title');

  @override
  Future<List<Map<String, dynamic>>> getRankings({required String period, required String kind}) async {
    final rows = await _client.from('rankings').select().eq('period', period).eq('kind', kind).order('rank');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final row = await _client.from('user_settings').select().eq('user_id', _client.auth.currentUser!.id).maybeSingle();
    return row == null ? {'language': 'en', 'notifications_enabled': true} : Map<String, dynamic>.from(row);
  }

  @override
  Future<Map<String, dynamic>> purchaseMallItem(String itemId) async {
    final row = await _client.rpc('purchase_mall_item', params: {'target_item': itemId, 'request_key': '${DateTime.now().microsecondsSinceEpoch}'});
    return Map<String, dynamic>.from(row as Map);
  }

  @override
  Future<void> updateSettings({required String language, required bool notificationsEnabled}) async {
    await _client.from('user_settings').upsert({'user_id': _client.auth.currentUser!.id, 'language': language, 'notifications_enabled': notificationsEnabled, 'updated_at': DateTime.now().toIso8601String()});
  }
}