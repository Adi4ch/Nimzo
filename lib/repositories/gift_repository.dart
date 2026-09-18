import '../models/gift.dart';

abstract class GiftRepository {
  Future<List<NimzoGift>> getGifts();
  Future<NimzoGift?> getById(String id);
}
