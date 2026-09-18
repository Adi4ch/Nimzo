import 'room_seat.dart';

class NimzoRoom {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final int listenerCount;
  final bool featured;
  final List<RoomSeat> seats;

  const NimzoRoom({required this.id, required this.name, this.subtitle = '', this.category = 'All', this.listenerCount = 0, this.featured = false, this.seats = const []});

  NimzoRoom copyWith({String? id, String? name, String? subtitle, String? category, int? listenerCount, bool? featured, List<RoomSeat>? seats}) => NimzoRoom(id: id ?? this.id, name: name ?? this.name, subtitle: subtitle ?? this.subtitle, category: category ?? this.category, listenerCount: listenerCount ?? this.listenerCount, featured: featured ?? this.featured, seats: seats ?? this.seats);

  factory NimzoRoom.fromMap(Map<String, dynamic> map) => NimzoRoom(id: map['id'] as String, name: map['name'] as String? ?? '', subtitle: map['subtitle'] as String? ?? '', category: map['category'] as String? ?? 'All', listenerCount: map['listener_count'] as int? ?? 0, featured: map['featured'] as bool? ?? false, seats: (map['seats'] as List<dynamic>? ?? []).map((item) => RoomSeat.fromMap(Map<String, dynamic>.from(item as Map))).toList());

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'subtitle': subtitle, 'category': category, 'listener_count': listenerCount, 'featured': featured, 'seats': seats.map((item) => item.toMap()).toList()};
}
