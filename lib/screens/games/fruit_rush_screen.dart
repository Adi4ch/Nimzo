import 'package:flutter/material.dart';

import '../../models/game_result.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class FruitRushScreen extends StatefulWidget {
  final String gameId;

  const FruitRushScreen({super.key, required this.gameId});

  @override
  State<FruitRushScreen> createState() => _FruitRushScreenState();
}

class _FruitRushScreenState extends State<FruitRushScreen> {
  static const symbols = ['apple', 'orange', 'berry', 'melon'];
  int stake = 10;
  bool spinning = false;
  GameResult? result;
  String? error;

  Future<void> spin() async {
    setState(() { spinning = true; error = null; result = null; });
    try {
      final gameResult = await RepositoryFactory.games().playGame(gameId: widget.gameId, stake: stake, idempotencyKey: 'fruit-rush-${DateTime.now().microsecondsSinceEpoch}');
      if (mounted) setState(() => result = gameResult);
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString());
    } finally {
      if (mounted) setState(() => spinning = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Fruit Rush')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: lightMint, borderRadius: BorderRadius.circular(24)), child: Column(children: [
            const Text('FRUIT RUSH', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 6),
            const Text('Virtual coins only', style: TextStyle(color: muted)),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [for (final symbol in (result?.result['symbols'] as List<dynamic>?)?.cast<String>() ?? symbols.take(3)) Text(_icon(symbol), style: const TextStyle(fontSize: 42))]),
          ])),
          const SizedBox(height: 20),
          const Text('Choose stake', style: TextStyle(fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [for (final amount in [10, 25, 50, 100]) ChoiceChip(label: Text('$amount coins'), selected: stake == amount, selectedColor: mint, labelStyle: TextStyle(color: stake == amount ? Colors.white : ink), onSelected: spinning ? null : (_) => setState(() => stake = amount))]),
          const SizedBox(height: 22),
          FilledButton.icon(onPressed: spinning ? null : spin, style: FilledButton.styleFrom(backgroundColor: mint, padding: const EdgeInsets.symmetric(vertical: 15)), icon: spinning ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.refresh), label: Text(spinning ? 'Spinning...' : 'Spin for $stake coins')),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(error!, style: const TextStyle(color: Colors.red))),
          if (result != null) Padding(padding: const EdgeInsets.only(top: 18), child: Text(result!.reward > 0 ? 'You won ${result!.reward} virtual coins!' : 'No win this round. Try again.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: result!.reward > 0 ? mint : muted))),
          const SizedBox(height: 22),
          const Text('Results are generated and settled by the server in Supabase mode.', style: TextStyle(color: muted), textAlign: TextAlign.center),
        ]),
      );

  String _icon(String symbol) => switch (symbol) { 'apple' => '🍎', 'orange' => '🍊', 'berry' => '🫐', 'melon' => '🍉', _ => '🍏' };
}