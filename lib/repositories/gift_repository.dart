import '../models/gift.dart';
import '../models/gift_event.dart';

abstract class GiftRepository {
  Future<List<NimzoGift>> getGifts();
  Future<NimzoGift?> getById(String id);
  Future<GiftEvent> sendGift({required String roomId, required String giftId, String? receiverId, required int quantity, required String idempotencyKey});
  Stream<GiftEvent> watchRoomGifts(String roomId);
  Future<void> disposeRoom(String roomId);
}
