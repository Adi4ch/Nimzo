import '../platform_repository.dart';

class MockPlatformRepository implements PlatformRepository {
  @override
  Future<List<Map<String, dynamic>>> getVipLevels() async => const [
        {'level': 1, 'name': 'Silver', 'cost': 5000, 'benefits': ['VIP badge', 'Profile frame']},
        {'level': 2, 'name': 'Gold', 'cost': 15000, 'benefits': ['Gold badge', 'Room entrance effect', 'Priority support']},
        {'level': 3, 'name': 'Diamond', 'cost': 50000, 'benefits': ['Diamond badge', 'Exclusive frame', 'Gift discount']},
      ];

  @override
  Future<Map<String, dynamic>> getCurrentVip() async => const {'level': 1, 'name': 'Silver', 'progress': 0.64, 'nextCost': 15000};

  @override
  Future<List<Map<String, dynamic>>> getMallItems() async => const [
        {'id': 'frame-emerald', 'category': 'Frames', 'name': 'Emerald Halo', 'description': 'A crisp mint frame for your profile.', 'price_coins': 800, 'icon': 'crop_square'},
        {'id': 'theme-garden', 'category': 'Room themes', 'name': 'Glass Garden', 'description': 'A bright, leafy room atmosphere.', 'price_coins': 1200, 'icon': 'park'},
        {'id': 'entry-spark', 'category': 'Entry effects', 'name': 'Spark Arrival', 'description': 'Make an entrance with a little light.', 'price_coins': 1600, 'icon': 'auto_awesome'},
        {'id': 'bubble-mint', 'category': 'Chat bubbles', 'name': 'Mint Pop', 'description': 'A fresh bubble style for every message.', 'price_coins': 600, 'icon': 'chat_bubble'},
        {'id': 'seat-cloud', 'category': 'Mic-seat props', 'name': 'Cloud Seat', 'description': 'A soft prop for your next room session.', 'price_coins': 1000, 'icon': 'cloud'},
      ];

  @override
  Future<List<Map<String, dynamic>>> getInventory() async => const [
        {'item_id': 'frame-emerald', 'name': 'Emerald Halo', 'category': 'Frames', 'equipped': true},
      ];

  @override
  Future<List<Map<String, dynamic>>> getDailyTasks() async => const [
        {'id': 'task-login', 'title': 'Check in today', 'description': 'Open Nimzo and keep your streak alive.', 'reward_coins': 100, 'progress': 1, 'target': 1, 'claimed': false},
        {'id': 'task-room', 'title': 'Visit a room', 'description': 'Spend time with the community.', 'reward_coins': 250, 'progress': 2, 'target': 3, 'claimed': false},
        {'id': 'task-social', 'title': 'Share a moment', 'description': 'Like or comment on a post.', 'reward_coins': 150, 'progress': 1, 'target': 1, 'claimed': true},
      ];

  @override
  Future<List<Map<String, dynamic>>> getAchievements() async => const [
        {'title': 'First hello', 'description': 'Join your first room', 'progress': 1, 'target': 1, 'reward_coins': 300, 'complete': true},
        {'title': 'Community builder', 'description': 'Follow 10 people', 'progress': 6, 'target': 10, 'reward_coins': 800, 'complete': false},
      ];

  @override
  Future<List<Map<String, dynamic>>> getRankings({required String period, required String kind}) async => const [
        {'rank': 1, 'name': 'Mina', 'score': 98200},
        {'rank': 2, 'name': 'Aarav', 'score': 84500},
        {'rank': 3, 'name': 'Nimzo User', 'score': 72100, 'current': true},
        {'rank': 4, 'name': 'Sana', 'score': 60800},
      ];

  @override
  Future<Map<String, dynamic>> getSettings() async => const {'language': 'en', 'notifications_enabled': true};

  @override
  Future<Map<String, dynamic>> purchaseMallItem(String itemId) async => {'item_id': itemId};

  @override
  Future<void> updateSettings({required String language, required bool notificationsEnabled}) async {}
}