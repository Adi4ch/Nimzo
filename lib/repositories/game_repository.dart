import '../models/game.dart';
import '../models/game_result.dart';

abstract class GameRepository {
  Future<List<NimzoGame>> getGames({String category = 'All'});
  Future<NimzoGame?> getById(String id);
  Future<GameResult> playGame({required String gameId, required int stake, required String idempotencyKey});
  Future<List<GameResult>> getHistory(String gameId);
}
