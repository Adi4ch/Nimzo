import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../platform_repository.dart';

class SupabasePlatformRepository implements PlatformRepository {
  SupabaseClient get _client =>
      SupabaseBootstrap.client ??
      (throw StateError('Supabase is not configured.'));

  Future<List<Map<String, dynamic>>> _rows(String table,
      {String? order}) async {
    final query = _client.from(table).select();
    final rows = order == null ? await query : await query.order(order);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getVipLevels() =>
      _rows('vip_levels', order: 'level');

  @override
  Future<Map<String, dynamic>?> getCurrentVip() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('user_vip')
        .select('*, vip_levels(*)')
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    final result = Map<String, dynamic>.from(row);
    final level = result['vip_levels'] as Map<String, dynamic>?;
    if (level != null) {
      result['name'] = level['name'];
      result['level'] = level['level'];
    }
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getMallItems() =>
      _rows('mall_items', order: 'category');

  @override
  Future<List<Map<String, dynamic>>> getInventory() async {
    final rows = await _client
        .from('user_inventory')
        .select('*, mall_items(*)')
        .eq('user_id', _client.auth.currentUser!.id);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyTasks() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final tasks = await _client
        .from('daily_tasks')
        .select()
        .eq('active', true)
        .order('title');
    final progress = await _client
        .from('daily_task_progress')
        .select()
        .eq('user_id', userId)
        .eq('task_date', DateTime.now().toIso8601String().substring(0, 10));
    final byTask = {
      for (final row in progress)
        row['task_id'].toString(): Map<String, dynamic>.from(row)
    };
    return tasks.map((row) {
      final task = Map<String, dynamic>.from(row);
      final current = byTask[task['id'].toString()];
      task['progress'] = current?['progress'] ?? 0;
      task['claimed'] = current?['claimed_at'] != null;
      return task;
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAchievements() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final achievements =
        await _client.from('achievements').select().order('title');
    final earned =
        await _client.from('user_achievements').select().eq('user_id', userId);
    final byAchievement = {
      for (final row in earned)
        row['achievement_id'].toString(): Map<String, dynamic>.from(row)
    };
    return achievements.map((row) {
      final achievement = Map<String, dynamic>.from(row);
      final current = byAchievement[achievement['id'].toString()];
      achievement['progress'] = current?['progress'] ?? 0;
      achievement['complete'] =
          (current?['progress'] ?? 0) >= (achievement['target'] ?? 1);
      achievement['claimed'] = current?['claimed_at'] != null;
      return achievement;
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getRankings(
      {required String period, required String kind}) async {
    final rows = await _client
        .from('rankings')
        .select()
        .eq('period', period)
        .eq('kind', kind)
        .order('rank');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    final row = await _client
        .from('user_settings')
        .select()
        .eq('user_id', _client.auth.currentUser!.id)
        .maybeSingle();
    return row == null
        ? {'language': 'en', 'notifications_enabled': true}
        : Map<String, dynamic>.from(row);
  }

  @override
  Future<Map<String, dynamic>> purchaseMallItem(String itemId) async {
    final row = await _client.rpc('purchase_mall_item', params: {
      'target_item': itemId,
      'request_key':
          '${_client.auth.currentUser?.id}:${itemId}:${DateTime.now().microsecondsSinceEpoch}'
    });
    return Map<String, dynamic>.from(row as Map);
  }

  @override
  Future<Map<String, dynamic>> purchaseVip(String levelId) async {
    final row = await _client.rpc('purchase_vip', params: {
      'target_level': levelId,
      'request_key':
          '${_client.auth.currentUser?.id}:vip:$levelId:${DateTime.now().microsecondsSinceEpoch}'
    });
    return Map<String, dynamic>.from(row as Map);
  }

  @override
  Future<Map<String, dynamic>> equipMallItem(String inventoryId) async =>
      Map<String, dynamic>.from(await _client.rpc('equip_mall_item',
          params: {'target_inventory': inventoryId}) as Map);

  @override
  Future<Map<String, dynamic>> unequipMallItem(String inventoryId) async =>
      Map<String, dynamic>.from(await _client.rpc('unequip_mall_item',
          params: {'target_inventory': inventoryId}) as Map);

  @override
  Future<void> claimDailyTask(String taskId) async {
    await _client.rpc('claim_daily_task', params: {'target_task': taskId});
  }

  @override
  Future<void> claimAchievement(String achievementId) async {
    await _client.rpc('claim_achievement_reward',
        params: {'target_achievement': achievementId});
  }

  @override
  Future<void> updateSettings(
      {required String language, required bool notificationsEnabled}) async {
    await _client.from('user_settings').upsert({
      'user_id': _client.auth.currentUser!.id,
      'language': language,
      'notifications_enabled': notificationsEnabled,
      'updated_at': DateTime.now().toIso8601String()
    });
  }
}
