class GameResult {
  final String id;
  final String gameId;
  final int stake;
  final int reward;
  final Map<String, dynamic> result;

  const GameResult({required this.id, required this.gameId, required this.stake, required this.reward, required this.result});

  factory GameResult.fromMap(Map<String, dynamic> map) => GameResult(id: map['id'] as String, gameId: map['game_id'] as String? ?? '', stake: map['stake'] as int? ?? 0, reward: map['reward'] as int? ?? 0, result: Map<String, dynamic>.from((map['result'] as Map?) ?? {}));
}