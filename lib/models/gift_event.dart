class GiftEvent {
  final String id;
  final String roomId;
  final String giftId;
  final String senderId;
  final String? receiverId;
  final int quantity;
  final int totalCost;

  const GiftEvent({required this.id, required this.roomId, required this.giftId, required this.senderId, this.receiverId, required this.quantity, required this.totalCost});

  factory GiftEvent.fromMap(Map<String, dynamic> map) => GiftEvent(id: map['id'] as String, roomId: map['room_id'] as String, giftId: map['gift_id'] as String, senderId: map['sender_id'] as String, receiverId: map['receiver_id'] as String?, quantity: map['quantity'] as int? ?? 1, totalCost: map['total_cost'] as int? ?? 0);
}