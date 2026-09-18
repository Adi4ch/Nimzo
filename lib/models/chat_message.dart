enum ChatMessageType { text, gift, system }

class ChatMessage {
  final String id;
  final String roomId;
  final String userId;
  final String text;
  final ChatMessageType type;
  final String? replyToId;
  final String? giftId;
  final DateTime createdAt;
  final bool recalled;

  const ChatMessage({required this.id, required this.roomId, required this.userId, required this.text, this.type = ChatMessageType.text, this.replyToId, this.giftId, required this.createdAt, this.recalled = false});

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        roomId: map['room_id'] as String,
        userId: map['user_id'] as String,
        text: map['text'] as String? ?? '',
        type: ChatMessageType.values.firstWhere((value) => value.name == map['message_type'], orElse: () => ChatMessageType.text),
        replyToId: map['reply_to_id'] as String?,
        giftId: map['gift_id'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
        recalled: map['recalled'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {'room_id': roomId, 'user_id': userId, 'text': text, 'message_type': type.name, 'reply_to_id': replyToId, 'gift_id': giftId};
}