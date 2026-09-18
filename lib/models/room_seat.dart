class RoomSeat {
  final String id;
  final int position;
  final bool active;
  final String? userId;

  const RoomSeat({required this.id, required this.position, required this.active, this.userId});

  RoomSeat copyWith({String? id, int? position, bool? active, String? userId}) => RoomSeat(id: id ?? this.id, position: position ?? this.position, active: active ?? this.active, userId: userId ?? this.userId);

  factory RoomSeat.fromMap(Map<String, dynamic> map) => RoomSeat(id: map['id'] as String, position: map['position'] as int? ?? 0, active: map['active'] as bool? ?? false, userId: map['user_id'] as String?);

  Map<String, dynamic> toMap() => {'id': id, 'position': position, 'active': active, 'user_id': userId};
}
