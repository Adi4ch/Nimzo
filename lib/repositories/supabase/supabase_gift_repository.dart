import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/gift.dart';
import '../../models/gift_event.dart';
import '../gift_repository.dart';

class SupabaseGiftRepository implements GiftRepository {
    final Map<String, RealtimeChannel> _channels = {};
    final Map<String, StreamController<GiftEvent>> _controllers = {};
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<List<NimzoGift>> getGifts() async {
    final rows = await _client.from('gifts').select().order('coin_cost');
    return rows.map(NimzoGift.fromMap).toList();
  }

  @override
  Future<NimzoGift?> getById(String id) async {
    final row = await _client.from('gifts').select().eq('id', id).maybeSingle();
    return row == null ? null : NimzoGift.fromMap(row);
  }

  @override
  Future<GiftEvent> sendGift({required String roomId, required String giftId, String? receiverId, required int quantity, required String idempotencyKey}) async {
    final row = await _client.rpc('send_virtual_gift', params: {'target_room': roomId, 'target_gift': giftId, 'target_receiver': receiverId, 'target_quantity': quantity, 'request_key': idempotencyKey});
    return GiftEvent.fromMap(Map<String, dynamic>.from(row as Map));
  }

  @override
  Stream<GiftEvent> watchRoomGifts(String roomId) {
    final controller = _controllers.putIfAbsent(roomId, () => StreamController<GiftEvent>.broadcast());
    if (!_channels.containsKey(roomId)) {
      _channels[roomId] = _client.channel('room-gifts:$roomId').onPostgresChanges(event: PostgresChangeEvent.insert, schema: 'public', table: 'gift_events', filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'room_id', value: roomId), callback: (payload) => controller.add(GiftEvent.fromMap(payload.newRecord))).subscribe();
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
