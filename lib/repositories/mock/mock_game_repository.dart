import '../../models/game.dart';
import '../game_repository.dart';
import 'demo_data.dart';

class MockGameRepository implements GameRepository {
  @override
  Future<List<NimzoGame>> getGames({String category = 'All'}) async => category == 'All' ? DemoData.games : DemoData.games.where((game) => game.category == category).toList();

  @override
  Future<NimzoGame?> getById(String id) async {
    for (final game in DemoData.games) {
      if (game.id == id) return game;
    }
    return null;
  }
}
