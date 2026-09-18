import '../models/room.dart';
import '../models/room_seat.dart';

abstract class RoomRepository {
  Future<List<NimzoRoom>> getFeaturedRooms();
  Future<List<NimzoRoom>> getRooms({String category = 'All'});
  Future<NimzoRoom?> getById(String id);
  Future<NimzoRoom> createRoom({required String name, String subtitle = '', String category = 'Chat', String description = ''});
  Future<List<RoomSeat>> getSeats(String roomId);
  Future<RoomSeat> joinSeat(String roomId, int position);
  Future<void> leaveRoom(String roomId);
  Stream<List<RoomSeat>> watchSeats(String roomId);
  Future<void> disposeRoom(String roomId);
  Stream<NimzoRoom> watchRoom(String roomId);
}
