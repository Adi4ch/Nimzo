import 'dart:async';

import '../../models/gift.dart';
import '../../models/gift_event.dart';
import '../gift_repository.dart';
import 'demo_data.dart';

class MockGiftRepository implements GiftRepository {
  final StreamController<GiftEvent> _events = StreamController<GiftEvent>.broadcast();
  @override
  Future<List<NimzoGift>> getGifts() async => DemoData.gifts;

  @override
  Future<NimzoGift?> getById(String id) async {
    for (final gift in DemoData.gifts) {
      if (gift.id == id) return gift;
    }
    return null;
  }

  @override
  Future<GiftEvent> sendGift({required String roomId, required String giftId, String? receiverId, required int quantity, required String idempotencyKey}) async {
    final gift = await getById(giftId);
    if (gift == null) throw StateError('Gift not found.');
    final event = GiftEvent(id: idempotencyKey, roomId: roomId, giftId: giftId, senderId: 'demo-user', receiverId: receiverId, quantity: quantity, totalCost: gift.coinCost * quantity);
    _events.add(event);
    return event;
  }

  @override
  Stream<GiftEvent> watchRoomGifts(String roomId) => _events.stream.where((event) => event.roomId == roomId);

  @override
  Future<void> disposeRoom(String roomId) async {}
}
