import '../models/room.dart';

abstract class RoomRepository {
  Future<List<NimzoRoom>> getFeaturedRooms();
  Future<List<NimzoRoom>> getRooms({String category = 'All'});
  Future<NimzoRoom?> getById(String id);
  Future<NimzoRoom> createRoom({required String name, String subtitle = '', String category = 'Chat', String description = ''});
  Future<List<RoomSeat>> getSeats(String roomId);
  Future<RoomSeat> joinSeat(String roomId, int position);
  Future<void> leaveRoom(String roomId);
}
