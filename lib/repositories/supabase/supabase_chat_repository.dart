import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/chat_message.dart';
import '../chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<ChatMessage>> _controllers = {};

  @override
  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 30, DateTime? before}) async {
    var query = _client.from('room_messages').select().eq('room_id', roomId).order('created_at', ascending: false).limit(limit);
    if (before != null) query = query.lt('created_at', before.toIso8601String());
    final rows = await query;
    return rows.map((row) => ChatMessage.fromMap(Map<String, dynamic>.from(row))).toList();
  }

  @override
  Future<ChatMessage> sendMessage(String roomId, String text, {String? replyToId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    final row = await _client.from('room_messages').insert({'room_id': roomId, 'user_id': userId, 'text': text, 'message_type': 'text', 'reply_to_id': replyToId}).select().single();
    return ChatMessage.fromMap(row);
  }

  @override
  Future<void> recallMessage(String messageId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client.from('room_messages').update({'recalled': true, 'text': ''}).eq('id', messageId).eq('user_id', userId);
  }

  @override
  Stream<ChatMessage> watchMessages(String roomId) {
    final controller = _controllers.putIfAbsent(roomId, () => StreamController<ChatMessage>.broadcast());
    if (!_channels.containsKey(roomId)) {
      final channel = _client.channel('room-messages:$roomId').onPostgresChanges(event: PostgresChangeEvent.insert, schema: 'public', table: 'room_messages', filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'room_id', value: roomId), callback: (payload) => controller.add(ChatMessage.fromMap(payload.newRecord))).subscribe();
      _channels[roomId] = channel;
    }
    return controller.stream;
  }

  @override
  Future<void> disposeRoom(String roomId) async {
    final channel = _channels.remove(roomId);
    if (channel != null) await _client.removeChannel(channel);
    await _controllers.remove(roomId)?.close();
  }
}