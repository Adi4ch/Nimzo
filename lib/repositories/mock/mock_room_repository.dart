import '../../models/room.dart';
import '../../models/room_seat.dart';
import 'dart:async';
import '../room_repository.dart';
import 'demo_data.dart';

class MockRoomRepository implements RoomRepository {
  final Map<String, List<RoomSeat>> _seats = {};
  final Map<String, StreamController<List<RoomSeat>>> _seatControllers = {};
  final Map<String, Map<String, dynamic>> _settings = {};
  final List<NimzoRoom> _createdRooms = [];
  @override
  Future<List<NimzoRoom>> getFeaturedRooms() async => DemoData.featuredRooms;

  @override
  Future<List<NimzoRoom>> getRooms({String category = 'All'}) async {
    final rooms = [...DemoData.rooms, ..._createdRooms];
    return category == 'All'
        ? rooms
        : rooms.where((room) => room.category == category).toList();
  }

  @override
  Future<NimzoRoom?> getById(String id) async {
    for (final room in DemoData.rooms) {
      if (room.id == id) return room.copyWith(seats: DemoData.seatsForRoom(id));
    }
    for (final room in _createdRooms) {
      if (room.id == id)
        return room.copyWith(seats: _seats[id] ?? DemoData.seatsForRoom(id));
    }
    return null;
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
    final room = NimzoRoom(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        subtitle: subtitle,
        category: category,
        description: description,
        avatarUrl: avatarUrl,
        backgroundUrl: backgroundUrl,
        privacy: privacy,
        passwordProtected: password?.isNotEmpty == true,
        announcement: announcement,
        theme: theme,
        createdBy: DemoData.currentUser.id,
        hostId: DemoData.currentUser.id);
    _createdRooms.add(room);
    _seats[room.id] = DemoData.seatsForRoom(room.id);
    return room;
  }

  @override
  Future<List<RoomSeat>> getSeats(String roomId) async =>
      _seats[roomId] ?? DemoData.seatsForRoom(roomId);

  @override
  Future<RoomSeat> joinSeat(String roomId, int position) async {
    final seats = [...await getSeats(roomId)];
    final seat = seats[position];
    final joined = seat.copyWith(active: true, userId: DemoData.currentUser.id);
    seats[position] = joined;
    _seats[roomId] = seats;
    _seatControllers[roomId]?.add(seats);
    return joined;
  }

  @override
  Future<void> leaveRoom(String roomId) async => _seats.remove(roomId);

  @override
  Stream<List<RoomSeat>> watchSeats(String roomId) =>
      (_seatControllers[roomId] ??=
              StreamController<List<RoomSeat>>.broadcast())
          .stream;

  @override
  Future<void> disposeRoom(String roomId) async {
    await _seatControllers.remove(roomId)?.close();
  }

  @override
  Stream<NimzoRoom> watchRoom(String roomId) async* {
    final room = await getById(roomId);
    if (room != null) yield room;
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
    _settings[roomId] = {
      'name': name,
      'subtitle': subtitle,
      'description': description,
      'avatar_url': avatarUrl,
      'background_url': backgroundUrl,
      'privacy': privacy,
      'password_protected': password?.isNotEmpty == true,
      'announcement': announcement,
      'theme': theme
    };
    final current = await getById(roomId);
    final updated = current!.copyWith(
        name: name,
        subtitle: subtitle,
        description: description,
        avatarUrl: avatarUrl,
        backgroundUrl: backgroundUrl,
        privacy: privacy,
        passwordProtected:
            password?.isNotEmpty == true || current.passwordProtected,
        announcement: announcement,
        theme: theme);
    final index = _createdRooms.indexWhere((room) => room.id == roomId);
    if (index >= 0) _createdRooms[index] = updated;
    return updated;
  }

  @override
  Future<List<Map<String, dynamic>>> getActivities(String roomId) async =>
      const [];

  @override
  Future<List<Map<String, dynamic>>> getRanking(String roomId,
          {String period = 'weekly'}) async =>
      const [];

  @override
  Future<List<String>> getModerators(String roomId) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getMembers(String roomId) async =>
      (await getSeats(roomId))
          .where((seat) => seat.userId != null)
          .map((seat) => {
                'user_id': seat.userId,
                'display_name': seat.userId,
                'avatar_url': null,
                'position': seat.position
              })
          .toList();

  @override
  Future<List<Map<String, dynamic>>> getSanctions(String roomId) async =>
      const [];

  @override
  Future<void> assignModerator(
      String roomId, String userId, bool assign) async {}

  @override
  Future<void> manageMember(
      {required String roomId,
      required String userId,
      required String action,
      int? durationMinutes}) async {}

  @override
  Future<void> unbanMember(
      {required String roomId, required String userId}) async {}
}
