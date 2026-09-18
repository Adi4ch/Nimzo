import '../../models/chat_message.dart';
import '../chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final Map<String, List<ChatMessage>> _messages = {};

  @override
  Future<List<ChatMessage>> getMessages(String roomId,
          {int limit = 30, DateTime? before}) async =>
      (_messages[roomId] ?? [])
          .where(
              (message) => before == null || message.createdAt.isBefore(before))
          .take(limit)
          .toList();

  @override
  Future<ChatMessage> sendMessage(String roomId, String text,
      {String? replyToId,
      ChatMessageType type = ChatMessageType.text,
      String? giftId}) async {
    final message = ChatMessage(
        id: 'message-${DateTime.now().microsecondsSinceEpoch}',
        roomId: roomId,
        userId: 'demo-user',
        text: text,
        type: type,
        giftId: giftId,
        replyToId: replyToId,
        createdAt: DateTime.now(),
        senderName: 'Nimzo User');
    (_messages[roomId] ??= []).add(message);
    return message;
  }

  @override
  Future<void> recallMessage(String messageId) async {
    for (final messages in _messages.values) {
      final index = messages.indexWhere((message) =>
          message.id == messageId && message.userId == 'demo-user');
      if (index != -1)
        messages[index] = ChatMessage(
            id: messages[index].id,
            roomId: messages[index].roomId,
            userId: messages[index].userId,
            text: '',
            type: messages[index].type,
            createdAt: messages[index].createdAt,
            recalled: true);
    }
  }

  @override
  Stream<ChatMessage> watchMessages(String roomId) => const Stream.empty();

  @override
  Future<void> disposeRoom(String roomId) async {}
}
