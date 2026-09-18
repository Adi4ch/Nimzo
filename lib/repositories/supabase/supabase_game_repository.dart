import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/game.dart';
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
}
