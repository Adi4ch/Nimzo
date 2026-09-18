import 'package:flutter/material.dart';

import '../../theme/nimzo_theme.dart';
import '../../widgets/game_card.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  int category = 0;
  final categories = const ['All', 'Board', 'Classic'];
  final games = const ['Ludo', 'Carrom', '8'];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Game List')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Pick a game', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 8),
          const Text('Play with room friends using demo coins.', style: TextStyle(color: muted)),
          const SizedBox(height: 20),
          Wrap(spacing: 8, children: [
            for (var index = 0; index < categories.length; index++)
              ChoiceChip(label: Text(categories[index]), selected: category == index, selectedColor: mint, labelStyle: TextStyle(color: category == index ? Colors.white : ink, fontWeight: FontWeight.w700), onSelected: (_) => setState(() => category = index)),
          ]),
          const SizedBox(height: 12),
          for (final game in games) GameCard(name: game),
        ]),
      );
}
