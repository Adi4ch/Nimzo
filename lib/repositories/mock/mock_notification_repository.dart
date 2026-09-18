import 'dart:async';

import '../../models/notification.dart';
import '../notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  final List<NimzoNotification> _items = [];
  final _events = StreamController<NimzoNotification>.broadcast();

  @override
  Future<List<NimzoNotification>> getNotifications({int limit = 30}) async => _items.take(limit).toList();
  @override
  Future<void> markRead(String id) async {}
  @override
  Future<void> markAllRead() async {}
  @override
  Stream<NimzoNotification> watch() => _events.stream;
  @override
  Future<void> dispose() => _events.close();
}