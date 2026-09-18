import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';
import '../screens/notifications/notifications_screen.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool back;

  const AppHeader(this.title, {super.key, this.back = false});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Row(children: [
          if (back) IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: ink))),
          const Icon(Icons.search, color: ink),
          const SizedBox(width: 16),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none, color: ink)),
        ]),
      );
}
