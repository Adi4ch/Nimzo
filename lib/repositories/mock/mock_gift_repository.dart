import 'dart:async';

import '../../models/gift.dart';
import '../../models/gift_event.dart';
import '../gift_repository.dart';
import 'demo_data.dart';

class MockGiftRepository implements GiftRepository {
  final StreamController<GiftEvent> _events =
      StreamController<GiftEvent>.broadcast();
  final Map<String, int> inventory = {'gift-1': 12};
  final Set<String> favorites = {'gift-1'};
  final List<GiftEvent> recent = [];
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
  Future<Map<String, int>> getInventory() async =>
      Map<String, int>.from(inventory);

  @override
  Future<Set<String>> getFavorites() async => Set<String>.from(favorites);

  @override
  Future<List<GiftEvent>> getRecent({int limit = 20}) async =>
      recent.take(limit).toList();

  @override
  Future<void> setFavorite(String giftId, bool favorite) async {
    favorite ? favorites.add(giftId) : favorites.remove(giftId);
  }

  @override
  Future<GiftEvent> sendGift(
      {required String roomId,
      required String giftId,
      String? receiverId,
      required int quantity,
      required String idempotencyKey}) async {
    final gift = await getById(giftId);
    if (gift == null) throw StateError('Gift not found.');
    final event = GiftEvent(
        id: idempotencyKey,
        roomId: roomId,
        giftId: giftId,
        senderId: 'demo-user',
        receiverId: receiverId,
        quantity: quantity,
        totalCost: gift.coinCost * quantity);
    recent.insert(0, event);
    _events.add(event);
    return event;
  }

  @override
  Stream<GiftEvent> watchRoomGifts(String roomId) =>
      _events.stream.where((event) => event.roomId == roomId);

  @override
  Future<void> disposeRoom(String roomId) async {}
}
