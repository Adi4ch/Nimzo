import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/notification.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../profile/user_profile_screen.dart';
import '../rooms/room_manager_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final repository = RepositoryFactory.notifications();
  late Future<List<NimzoNotification>> notifications;
  StreamSubscription<NimzoNotification>? subscription;

  @override
  void initState() {
    super.initState();
    notifications = repository.getNotifications();
    subscription = repository.watch().listen((_) {
      if (mounted)
        setState(() => notifications = repository.getNotifications());
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Notifications'), actions: [
          IconButton(
              onPressed: () async {
                await repository.markAllRead();
                if (mounted)
                  setState(() => notifications = repository.getNotifications());
              },
              icon: const Icon(Icons.done_all))
        ]),
        body: FutureBuilder<List<NimzoNotification>>(
          future: notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(
                  child: CircularProgressIndicator(color: mint));
            if (snapshot.hasError)
              return Center(
                  child: TextButton.icon(
                      onPressed: () => setState(
                          () => notifications = repository.getNotifications()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry')));
            final items = snapshot.data ?? const <NimzoNotification>[];
            if (items.isEmpty)
              return const Center(child: Text('No notifications yet.'));
            return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                      leading: CircleAvatar(
                          backgroundColor: lightMint,
                          child: Icon(
                              item.read
                                  ? Icons.notifications_none
                                  : Icons.notifications,
                              color: mint)),
                      title: Text(item.title,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(item.body),
                      onTap: () => _open(item));
                });
          },
        ),
      );

  Future<void> _open(NimzoNotification item) async {
    if (!item.read) await repository.markRead(item.id);
    if (mounted) setState(() => notifications = repository.getNotifications());
    if (!mounted || item.targetId == null) return;
    if (item.type == 'follow' || item.type == 'comment') {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  UserProfileScreen(userId: item.actorId ?? item.targetId!)));
    } else if (item.type == 'room') {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RoomManagerScreen(roomId: item.targetId!)));
    }
  }
}
