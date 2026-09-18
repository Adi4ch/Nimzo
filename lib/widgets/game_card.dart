import 'package:flutter/material.dart';

import '../models/game.dart';
import '../screens/games/game_detail_screen.dart';
import '../theme/nimzo_theme.dart';

class GameCard extends StatelessWidget {
  final NimzoGame game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: lightMint,
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.sports_esports, color: mint)),
          title: Text(game.name, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('Play now  |  Demo coins'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetailScreen(name: game.name))),
        ),
      );
}
