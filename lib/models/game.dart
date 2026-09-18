class NimzoGame {
  final String id;
  final String name;
  final String category;
  final bool playable;

  const NimzoGame({required this.id, required this.name, required this.category, this.playable = false});

  NimzoGame copyWith({String? id, String? name, String? category, bool? playable}) => NimzoGame(id: id ?? this.id, name: name ?? this.name, category: category ?? this.category, playable: playable ?? this.playable);

  factory NimzoGame.fromMap(Map<String, dynamic> map) => NimzoGame(id: map['id'] as String, name: map['name'] as String? ?? '', category: map['category'] as String? ?? 'Classic', playable: map['name'] == 'Fruit Rush');

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'category': category};
}
