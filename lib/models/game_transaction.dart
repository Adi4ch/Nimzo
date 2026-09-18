class GameTransaction {
  final String id;
  final String gameId;
  final int amount;
  final String type;
  final DateTime createdAt;

  const GameTransaction({required this.id, required this.gameId, required this.amount, required this.type, required this.createdAt});
}