import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/chat_message.dart';
import '../chat_repository.dart';

class SupabaseChatRepository implements ChatRepository {
  SupabaseClient get _client =>
      SupabaseBootstrap.client ??
      (throw StateError('Supabase is not configured.'));
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<ChatMessage>> _controllers = {};

  @override
  Future<List<ChatMessage>> getMessages(String roomId,
      {int limit = 30, DateTime? before}) async {
    final blocked = await _blockedUsers();
    var query = _client
        .from('room_messages')
        .select('*, profiles(display_name, avatar_url)')
        .eq('room_id', roomId);
    if (before != null)
      query = query.lt('created_at', before.toIso8601String());
    final rows = await query.order('created_at', ascending: false).limit(limit);
    return rows
        .where((row) => !blocked.contains(row['user_id']))
        .map((row) => ChatMessage.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<ChatMessage> sendMessage(String roomId, String text,
      {String? replyToId,
      ChatMessageType type = ChatMessageType.text,
      String? giftId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    final row = await _client
        .from('room_messages')
        .insert({
          'room_id': roomId,
          'user_id': userId,
          'text': text,
          'message_type': type.name,
          'gift_id': giftId,
          'reply_to_id': replyToId
        })
        .select('*, profiles(display_name, avatar_url)')
        .single();
    return ChatMessage.fromMap(row);
  }

  @override
  Future<void> recallMessage(String messageId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client
        .from('room_messages')
        .update({'recalled': true, 'text': ''})
        .eq('id', messageId)
        .eq('user_id', userId);
  }

  @override
  Stream<ChatMessage> watchMessages(String roomId) {
    final controller = _controllers.putIfAbsent(
        roomId, () => StreamController<ChatMessage>.broadcast());
    if (!_channels.containsKey(roomId)) {
      final channel = _client
          .channel('room-messages:$roomId')
          .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'room_messages',
              filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'room_id',
                  value: roomId),
              callback: (payload) async {
                if ((await _blockedUsers())
                    .contains(payload.newRecord['user_id'])) return;
                final sender = await _client
                    .from('profiles')
                    .select('display_name, avatar_url')
                    .eq('id', payload.newRecord['user_id'])
                    .maybeSingle();
                final record = Map<String, dynamic>.from(payload.newRecord)
                  ..['profiles'] = sender;
                controller.add(ChatMessage.fromMap(record));
              })
          .subscribe();
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

  Future<Set<String>> _blockedUsers() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const {};
    final rows = await _client
        .from('blocks')
        .select('blocked_id')
        .eq('blocker_id', userId);
    return rows.map((row) => row['blocked_id'].toString()).toSet();
  }
}
