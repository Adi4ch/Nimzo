import '../models/notification.dart';

abstract class NotificationRepository {
  Future<List<NimzoNotification>> getNotifications({int limit = 30});
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Stream<NimzoNotification> watch();
  Future<void> dispose();
}