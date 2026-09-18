import 'package:flutter/material.dart';

import '../../theme/nimzo_theme.dart';

class GameDetailScreen extends StatefulWidget {
  final String name;

  const GameDetailScreen({super.key, required this.name});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  int diceResult = 0;
  int ludoPosition = 0;
  String card = '';

  void play() {
    final name = widget.name.toLowerCase();
    setState(() {
      if (name.contains('dice'))
        diceResult = 1 + DateTime.now().millisecond % 6;
      if (name.contains('ludo'))
        ludoPosition =
            (ludoPosition + 1 + DateTime.now().millisecond % 6).clamp(0, 56);
      if (name.contains('card'))
        card = [
          'Ace',
          'King',
          'Queen',
          'Jack',
          '10'
        ][DateTime.now().millisecond % 5];
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.sports_esports, size: 90, color: mint),
          const SizedBox(height: 18),
          Text('${widget.name} table',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 8),
          Text(
              widget.name.toLowerCase().contains('dice')
                  ? 'Roll a virtual die'
                  : widget.name.toLowerCase().contains('ludo')
                      ? 'Move your demo token'
                      : widget.name.toLowerCase().contains('card')
                          ? 'Draw an original card'
                          : 'Virtual demo game',
              style: const TextStyle(color: muted)),
          const SizedBox(height: 18),
          if (diceResult > 0)
            Text('Rolled $diceResult',
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900, color: mint)),
          if (ludoPosition > 0)
            Text('Token position $ludoPosition / 56',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: mint)),
          if (card.isNotEmpty)
            Text(card,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900, color: mint)),
          const SizedBox(height: 24),
          FilledButton.icon(
              onPressed: play,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play demo')),
        ])),
      );
}
