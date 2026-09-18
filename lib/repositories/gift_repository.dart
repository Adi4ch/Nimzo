import '../models/gift.dart';
import '../models/gift_event.dart';

abstract class GiftRepository {
  Future<List<NimzoGift>> getGifts();
  Future<NimzoGift?> getById(String id);
  Future<Map<String, int>> getInventory();
  Future<Set<String>> getFavorites();
  Future<List<GiftEvent>> getRecent({int limit = 20});
  Future<void> setFavorite(String giftId, bool favorite);
  Future<GiftEvent> sendGift({required String roomId, required String giftId, String? receiverId, required int quantity, required String idempotencyKey});
  Stream<GiftEvent> watchRoomGifts(String roomId);
  Future<void> disposeRoom(String roomId);
}
