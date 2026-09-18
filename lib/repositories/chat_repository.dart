import '../models/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 30, DateTime? before});
  Future<ChatMessage> sendMessage(String roomId, String text, {String? replyToId});
  Future<void> recallMessage(String messageId);
  Stream<ChatMessage> watchMessages(String roomId);
  Future<void> disposeRoom(String roomId);
}