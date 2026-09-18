import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/gift.dart';
import '../gift_repository.dart';

class SupabaseGiftRepository implements GiftRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<List<NimzoGift>> getGifts() async {
    final rows = await _client.from('gifts').select().order('coin_cost');
    return rows.map(NimzoGift.fromMap).toList();
  }

  @override
  Future<NimzoGift?> getById(String id) async {
    final row = await _client.from('gifts').select().eq('id', id).maybeSingle();
    return row == null ? null : NimzoGift.fromMap(row);
  }
}
