abstract class PlatformRepository {
  Future<List<Map<String, dynamic>>> getVipLevels();
  Future<Map<String, dynamic>?> getCurrentVip();
  Future<List<Map<String, dynamic>>> getMallItems();
  Future<List<Map<String, dynamic>>> getInventory();
  Future<List<Map<String, dynamic>>> getDailyTasks();
  Future<List<Map<String, dynamic>>> getAchievements();
  Future<List<Map<String, dynamic>>> getRankings({required String period, required String kind});
  Future<Map<String, dynamic>> getSettings();
  Future<Map<String, dynamic>> purchaseMallItem(String itemId);
  Future<void> updateSettings({required String language, required bool notificationsEnabled});
}