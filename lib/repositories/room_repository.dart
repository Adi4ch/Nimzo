import '../models/room.dart';

abstract class RoomRepository {
  Future<List<NimzoRoom>> getFeaturedRooms();
  Future<List<NimzoRoom>> getRooms({String category = 'All'});
  Future<NimzoRoom?> getById(String id);
}
