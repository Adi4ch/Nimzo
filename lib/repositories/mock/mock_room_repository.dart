import '../../models/room.dart';
import '../room_repository.dart';
import 'demo_data.dart';

class MockRoomRepository implements RoomRepository {
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
}
