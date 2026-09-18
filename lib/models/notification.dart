class NimzoNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? actorId;
  final String? targetId;
  final DateTime createdAt;
  final bool read;

  const NimzoNotification({required this.id, required this.type, required this.title, required this.body, this.actorId, this.targetId, required this.createdAt, this.read = false});

  factory NimzoNotification.fromMap(Map<String, dynamic> map) => NimzoNotification(id: map['id'] as String, type: map['type'] as String, title: map['title'] as String, body: map['body'] as String? ?? '', actorId: map['actor_id'] as String?, targetId: map['target_id'] as String?, createdAt: DateTime.parse(map['created_at'] as String), read: map['read_at'] != null);
}