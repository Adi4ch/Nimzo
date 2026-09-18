class GameSession {
  final String id;
  final String gameId;
  final String roomId;
  final String userId;
  final DateTime startedAt;
  final bool finished;

  const GameSession({required this.id, required this.gameId, required this.roomId, required this.userId, required this.startedAt, this.finished = false});
}