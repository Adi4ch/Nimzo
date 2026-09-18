import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/room.dart';
import '../room_repository.dart';

class SupabaseRoomRepository implements RoomRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<List<NimzoRoom>> getFeaturedRooms() async {
    final rows = await _client.from('rooms').select().eq('is_featured', true).order('created_at');
    return rows.map(NimzoRoom.fromMap).toList();
  }

  @override
  Future<List<NimzoRoom>> getRooms({String category = 'All'}) async {
    final rows = category == 'All'
        ? await _client.from('rooms').select().order('created_at')
        : await _client.from('rooms').select().eq('category', category).order('created_at');
    return rows.map(NimzoRoom.fromMap).toList();
  }

  @override
  Future<NimzoRoom?> getById(String id) async {
    final row = await _client.from('rooms').select('*, room_seats(*)').eq('id', id).maybeSingle();
    return row == null ? null : NimzoRoom.fromMap(row);
  }
}
