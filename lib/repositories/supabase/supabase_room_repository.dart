import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../../config/supabase_bootstrap.dart';
import '../../models/room.dart';
import '../../models/room_seat.dart';
import '../room_repository.dart';

class SupabaseRoomRepository implements RoomRepository {
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<List<RoomSeat>>> _seatControllers = {};
  final Map<String, StreamController<NimzoRoom>> _roomControllers = {};
  SupabaseClient get _client =>
      SupabaseBootstrap.client ??
      (throw StateError('Supabase is not configured.'));

  @override
  Future<List<NimzoRoom>> getFeaturedRooms() async {
    final rows = await _client
        .from('rooms')
        .select()
        .eq('is_featured', true)
        .order('created_at');
    return rows.map(NimzoRoom.fromMap).toList();
  }

  @override
  Future<List<NimzoRoom>> getRooms({String category = 'All'}) async {
    final rows = category == 'All'
        ? await _client.from('rooms').select().order('created_at')
        : await _client
            .from('rooms')
            .select()
            .eq('category', category)
            .order('created_at');
    return rows.map(NimzoRoom.fromMap).toList();
  }

  @override
  Future<NimzoRoom?> getById(String id) async {
    final row = await _client
        .from('rooms')
        .select('*, room_seats(*)')
        .eq('id', id)
        .maybeSingle();
    return row == null ? null : NimzoRoom.fromMap(row);
  }

  @override
  Future<NimzoRoom> createRoom(
      {required String name,
      String subtitle = '',
      String category = 'Chat',
      String description = '',
      String? avatarUrl,
      String? backgroundUrl,
      String privacy = 'public',
      String? password,
      String announcement = '',
      String theme = 'mint'}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    final row = await _client.rpc('create_room', params: {
      'room_name': name,
      'room_subtitle': subtitle,
      'room_category': category,
      'room_description': description,
      'room_avatar': avatarUrl,
      'room_background': backgroundUrl,
      'room_privacy': privacy,
      'room_password': password,
      'room_announcement': announcement,
      'room_theme': theme
    });
    return NimzoRoom.fromMap(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<List<RoomSeat>> getSeats(String roomId) async {
    final rows = await _client
        .from('room_seats')
        .select()
        .eq('room_id', roomId)
        .order('position');
    return rows.map(RoomSeat.fromMap).toList();
  }

  @override
  Future<RoomSeat> joinSeat(String roomId, int position) async {
    final row = await _client.rpc('join_room_seat',
        params: {'target_room': roomId, 'target_position': position});
    return RoomSeat.fromMap(Map<String, dynamic>.from(row as Map));
  }

  @override
  Future<void> leaveRoom(String roomId) =>
      _client.rpc('leave_room_seat', params: {'target_room': roomId});

  @override
  Stream<List<RoomSeat>> watchSeats(String roomId) {
    final controller = _seatControllers.putIfAbsent(
        roomId, () => StreamController<List<RoomSeat>>.broadcast());
    if (!_channels.containsKey(roomId)) {
      _channels[roomId] = _client
          .channel('room-seats:$roomId')
          .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'room_seats',
              filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'room_id',
                  value: roomId),
              callback: (_) async {
                controller.add(await getSeats(roomId));
              })
          .subscribe();
    }
    return controller.stream;
  }

  @override
  Future<void> disposeRoom(String roomId) async {
    final seatChannel = _channels.remove(roomId);
    if (seatChannel != null) await _client.removeChannel(seatChannel);
    final roomChannel = _channels.remove('room-state:$roomId');
    if (roomChannel != null) await _client.removeChannel(roomChannel);
    await _seatControllers.remove(roomId)?.close();
    await _roomControllers.remove(roomId)?.close();
  }

  @override
  Stream<NimzoRoom> watchRoom(String roomId) {
    final controller = _roomControllers.putIfAbsent(
        roomId, () => StreamController<NimzoRoom>.broadcast());
    if (!_channels.containsKey('room-state:$roomId')) {
      _channels['room-state:$roomId'] = _client
          .channel('room-state:$roomId')
          .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'rooms',
              filter: PostgresChangeFilter(
                  type: PostgresChangeFilterType.eq,
                  column: 'id',
                  value: roomId),
              callback: (payload) =>
                  controller.add(NimzoRoom.fromMap(payload.newRecord)))
          .subscribe();
    }
    return controller.stream;
  }

  @override
  Future<NimzoRoom> updateRoomSettings(
      {required String roomId,
      required String name,
      required String subtitle,
      required String description,
      String? avatarUrl,
      String? backgroundUrl,
      String privacy = 'public',
      String? password,
      String announcement = '',
      String theme = 'mint'}) async {
    final row = await _client.rpc('update_room_settings', params: {
      'target_room': roomId,
      'room_name': name,
      'room_subtitle': subtitle,
      'room_description': description,
      'room_avatar': avatarUrl,
      'room_background': backgroundUrl,
      'room_privacy': privacy,
      'room_password': password,
      'room_announcement': announcement,
      'room_theme': theme
    });
    return NimzoRoom.fromMap(row);
  }

  @override
  Future<List<Map<String, dynamic>>> getActivities(String roomId) async {
    final rows = await _client
        .from('room_activities')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getRanking(String roomId,
      {String period = 'weekly'}) async {
    final rows = await _client
        .from('rankings')
        .select()
        .eq('period', period)
        .eq('kind', 'rooms')
        .eq('subject_id', roomId)
        .order('rank');
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<List<String>> getModerators(String roomId) async {
    final rows = await _client
        .from('room_moderators')
        .select('user_id')
        .eq('room_id', roomId);
    return rows.map((row) => row['user_id'].toString()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMembers(String roomId) async {
    final rows = await _client
        .from('room_seats')
        .select('user_id, position, profiles(id, display_name, avatar_url)')
        .eq('room_id', roomId)
        .not('user_id', 'is', null)
        .order('position');
    return rows.map((row) {
      final profile = row['profiles'] as Map<String, dynamic>?;
      return {
        'user_id': row['user_id'],
        'display_name': profile?['display_name'] ?? row['user_id'],
        'avatar_url': profile?['avatar_url'],
        'position': row['position']
      };
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSanctions(String roomId) async {
    final rows = await _client
        .from('room_sanctions')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(50);
    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }

  @override
  Future<void> assignModerator(
      String roomId, String userId, bool assign) async {
    await _client.rpc('assign_room_moderator', params: {
      'target_room': roomId,
      'target_user': userId,
      'should_assign': assign
    });
  }

  @override
  Future<void> manageMember(
      {required String roomId,
      required String userId,
      required String action,
      int? durationMinutes}) async {
    await _client.rpc('manage_room_member', params: {
      'target_room': roomId,
      'target_user': userId,
      'action_name': action,
      'duration_minutes': durationMinutes
    });
  }

  @override
  Future<void> unbanMember(
      {required String roomId, required String userId}) async {
    await _client.rpc('unban_room_member',
        params: {'target_room': roomId, 'target_member': userId});
  }
}
