import 'package:flutter/material.dart';

import '../../theme/nimzo_theme.dart';
import '../../widgets/notice.dart';

class GameDetailScreen extends StatelessWidget {
  final String name;

  const GameDetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(name)),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.sports_esports, size: 90, color: mint),
          const SizedBox(height: 18),
          Text('$name table', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 8),
          const Text('Game placeholder ready for integration', style: TextStyle(color: muted)),
          const SizedBox(height: 24),
          FilledButton.icon(onPressed: () => showNimzoNotice(context, 'Demo game started.'), icon: const Icon(Icons.play_arrow), label: const Text('Start demo')),
        ])),
      );
}
