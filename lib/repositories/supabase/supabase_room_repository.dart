import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/room.dart';
import '../../models/room_seat.dart';
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

  @override
  Future<NimzoRoom> createRoom({required String name, String subtitle = '', String category = 'Chat', String description = ''}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    final row = await _client.from('rooms').insert({'name': name, 'subtitle': subtitle, 'category': category, 'description': description, 'created_by': userId, 'host_id': userId}).select().single();
    await _client.rpc('ensure_room_seats', params: {'target_room': row['id']});
    return NimzoRoom.fromMap(row);
  }

  @override
  Future<List<RoomSeat>> getSeats(String roomId) async {
    final rows = await _client.from('room_seats').select().eq('room_id', roomId).order('position');
    return rows.map(RoomSeat.fromMap).toList();
  }

  @override
  Future<RoomSeat> joinSeat(String roomId, int position) async {
    final row = await _client.rpc('join_room_seat', params: {'target_room': roomId, 'target_position': position});
    return RoomSeat.fromMap(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<void> leaveRoom(String roomId) => _client.rpc('leave_room_seat', params: {'target_room': roomId});
}
