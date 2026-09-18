import 'package:flutter/material.dart';

import '../../models/game.dart';
import '../../repositories/mock/demo_data.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/game_card.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  int category = 0;
  final categories = const ['All', 'Arcade', 'Board', 'Classic'];
  late Future<List<NimzoGame>> games;

  @override
  void initState() { super.initState(); games = _loadGames(); }

  Future<List<NimzoGame>> _loadGames() async {
    try {
      final loaded = await RepositoryFactory.games().getGames(category: categories[category]);
      return RepositoryFactory.usesSupabase ? loaded : (loaded.isEmpty ? _demoGames() : loaded);
    } catch (_) { if (RepositoryFactory.usesSupabase) rethrow; return _demoGames(); }
  }

  List<NimzoGame> _demoGames() => category == 0 ? DemoData.games : DemoData.games.where((game) => game.category == categories[category]).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Game List')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Pick a game', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 8),
          const Text('Play with room friends using virtual coins.', style: TextStyle(color: muted)),
          const SizedBox(height: 20),
          Wrap(spacing: 8, children: [for (var index = 0; index < categories.length; index++) ChoiceChip(label: Text(categories[index]), selected: category == index, selectedColor: mint, labelStyle: TextStyle(color: category == index ? Colors.white : ink, fontWeight: FontWeight.w700), onSelected: (_) => setState(() { category = index; games = _loadGames(); }))]),
          const SizedBox(height: 12),
          FutureBuilder<List<NimzoGame>>(future: games, builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator(color: mint)));
            if (snapshot.hasError) return Center(child: TextButton.icon(onPressed: () => setState(() => games = _loadGames()), icon: const Icon(Icons.refresh), label: const Text('Retry')));
            final items = snapshot.data ?? const <NimzoGame>[];
            if (items.isEmpty) return const Padding(padding: EdgeInsets.all(28), child: Text('No games available.'));
            return Column(children: [for (final game in items) GameCard(game: game)]);
          }),
        ]),
      );
}