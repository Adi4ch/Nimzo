import '../../models/room.dart';
import '../../models/room_seat.dart';
import 'dart:async';
import '../room_repository.dart';
import 'demo_data.dart';

class MockRoomRepository implements RoomRepository {
  final Map<String, List<RoomSeat>> _seats = {};
  final Map<String, StreamController<List<RoomSeat>>> _seatControllers = {};
  final Map<String, Map<String, dynamic>> _settings = {};
  @override
  Future<List<NimzoRoom>> getFeaturedRooms() async => DemoData.featuredRooms;

  @override
  Future<List<NimzoRoom>> getRooms({String category = 'All'}) async => category == 'All' ? DemoData.rooms : DemoData.rooms.where((room) => room.category == category).toList();

  @override
  Future<NimzoRoom?> getById(String id) async {
    for (final room in DemoData.rooms) {
      if (room.id == id) return room.copyWith(seats: DemoData.seatsForRoom(id));
    }
    return null;
  }

  @override
  Future<NimzoRoom> createRoom({required String name, String subtitle = '', String category = 'Chat', String description = ''}) async => NimzoRoom(id: 'demo-${DateTime.now().millisecondsSinceEpoch}', name: name, subtitle: subtitle, category: category, description: description);

  @override
  Future<List<RoomSeat>> getSeats(String roomId) async => _seats[roomId] ?? DemoData.seatsForRoom(roomId);

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
  Stream<List<RoomSeat>> watchSeats(String roomId) => (_seatControllers[roomId] ??= StreamController<List<RoomSeat>>.broadcast()).stream;

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
  Future<NimzoRoom> updateRoomSettings({required String roomId, required String name, required String subtitle, required String description, String? backgroundUrl}) async {
    _settings[roomId] = {'name': name, 'subtitle': subtitle, 'description': description, 'background_url': backgroundUrl};
    return (await getById(roomId))!.copyWith(name: name, subtitle: subtitle, description: description, backgroundUrl: backgroundUrl);
  }

  @override
  Future<List<Map<String, dynamic>>> getActivities(String roomId) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getRanking(String roomId, {String period = 'weekly'}) async => const [];

  @override
  Future<List<String>> getModerators(String roomId) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getSanctions(String roomId) async => const [];

  @override
  Future<void> assignModerator(String roomId, String userId, bool assign) async {}

  @override
  Future<void> manageMember({required String roomId, required String userId, required String action, int? durationMinutes}) async {}
}
