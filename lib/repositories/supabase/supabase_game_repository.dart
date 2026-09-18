import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/game.dart';
import '../../models/game_result.dart';
import '../game_repository.dart';

class SupabaseGameRepository implements GameRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<List<NimzoGame>> getGames({String category = 'All'}) async {
    final rows = category == 'All' ? await _client.from('games').select().order('name') : await _client.from('games').select().eq('category', category).order('name');
    return rows.map(NimzoGame.fromMap).toList();
  }

  @override
  Future<NimzoGame?> getById(String id) async {
    final row = await _client.from('games').select().eq('id', id).maybeSingle();
    return row == null ? null : NimzoGame.fromMap(row);
  }

  @override
  Future<GameResult> playGame({required String gameId, required int stake, required String idempotencyKey}) async {
    final row = await _client.rpc('play_fruit_rush', params: {'target_game': gameId, 'target_stake': stake, 'request_key': idempotencyKey});
    final payload = Map<String, dynamic>.from(row as Map);
    return GameResult(id: payload['id'] as String, gameId: gameId, stake: stake, reward: payload['reward'] as int? ?? 0, result: Map<String, dynamic>.from(payload['result'] as Map));
  }

  @override
  Future<List<GameResult>> getHistory(String gameId) async {
    final rows = await _client.from('game_results').select().eq('game_id', gameId).order('created_at', ascending: false).limit(20);
    return rows.map((row) => GameResult.fromMap(Map<String, dynamic>.from(row))).toList();
  }
}
