import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/notification.dart';
import '../notification_repository.dart';

class SupabaseNotificationRepository implements NotificationRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));
  final _events = StreamController<NimzoNotification>.broadcast();
  RealtimeChannel? _channel;

  @override
  Future<List<NimzoNotification>> getNotifications({int limit = 30}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client.from('notifications').select().eq('user_id', userId).order('created_at', ascending: false).limit(limit);
    return rows.map((row) => NimzoNotification.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  @override
  Future<void> markRead(String id) async => _client.from('notifications').update({'read_at': DateTime.now().toIso8601String()}).eq('id', id).eq('user_id', _client.auth.currentUser!.id);

  @override
  Future<void> markAllRead() async => _client.from('notifications').update({'read_at': DateTime.now().toIso8601String()}).eq('user_id', _client.auth.currentUser!.id).isFilter('read_at', null);

  @override
  Stream<NimzoNotification> watch() {
    if (_channel == null) {
      _channel = _client.channel('notifications:${_client.auth.currentUser?.id}').onPostgresChanges(event: PostgresChangeEvent.insert, schema: 'public', table: 'notifications', filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: _client.auth.currentUser?.id), callback: (payload) => _events.add(NimzoNotification.fromMap(payload.newRecord))).subscribe();
    }
    return _events.stream;
  }

  @override
  Future<void> dispose() async { if (_channel != null) await _client.removeChannel(_channel!); await _events.close(); }
}