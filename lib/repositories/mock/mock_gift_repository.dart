import '../../models/gift.dart';
import '../gift_repository.dart';
import 'demo_data.dart';

class MockGiftRepository implements GiftRepository {
  @override
  Future<List<NimzoGift>> getGifts() async => DemoData.gifts;

  @override
  Future<NimzoGift?> getById(String id) async {
    for (final gift in DemoData.gifts) {
      if (gift.id == id) return gift;
    }
    return null;
  }
}
