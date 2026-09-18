import '../models/game.dart';

abstract class GameRepository {
  Future<List<NimzoGame>> getGames({String category = 'All'});
  Future<NimzoGame?> getById(String id);
}
