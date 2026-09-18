class NimzoGame {
  final String id;
  final String name;
  final String category;

  const NimzoGame({required this.id, required this.name, required this.category});

  NimzoGame copyWith({String? id, String? name, String? category}) => NimzoGame(id: id ?? this.id, name: name ?? this.name, category: category ?? this.category);

  factory NimzoGame.fromMap(Map<String, dynamic> map) => NimzoGame(id: map['id'] as String, name: map['name'] as String? ?? '', category: map['category'] as String? ?? 'Classic');

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'category': category};
}
