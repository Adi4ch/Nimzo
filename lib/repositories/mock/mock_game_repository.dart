import '../../models/game.dart';
import '../../models/game_result.dart';
import '../game_repository.dart';
import 'demo_data.dart';

class MockGameRepository implements GameRepository {
  final List<GameResult> history = [];
  @override
  Future<List<NimzoGame>> getGames({String category = 'All'}) async => category == 'All' ? DemoData.games : DemoData.games.where((game) => game.category == category).toList();

  @override
  Future<NimzoGame?> getById(String id) async {
    for (final game in DemoData.games) {
      if (game.id == id) return game;
    }
    return null;
  }

  @override
  Future<GameResult> playGame({required String gameId, required int stake, required String idempotencyKey}) async {
    final reward = DateTime.now().microsecond % 4 == 0 ? stake * 5 : 0;
    final result = GameResult(id: idempotencyKey, gameId: gameId, stake: stake, reward: reward, result: {'symbols': ['apple', 'orange', 'berry']});
    history.insert(0, result);
    return result;
  }

  @override
  Future<List<GameResult>> getHistory(String gameId) async => history.where((result) => result.gameId == gameId).toList();
}
