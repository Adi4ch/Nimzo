class NimzoComment {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final String? createdAt;

  const NimzoComment({required this.id, required this.postId, required this.userId, required this.text, this.createdAt});

  NimzoComment copyWith({String? id, String? postId, String? userId, String? text, String? createdAt}) => NimzoComment(id: id ?? this.id, postId: postId ?? this.postId, userId: userId ?? this.userId, text: text ?? this.text, createdAt: createdAt ?? this.createdAt);

  factory NimzoComment.fromMap(Map<String, dynamic> map) => NimzoComment(id: map['id'] as String, postId: map['post_id'] as String? ?? '', userId: map['user_id'] as String? ?? '', text: map['text'] as String? ?? '', createdAt: map['created_at'] as String?);

  Map<String, dynamic> toMap() => {'id': id, 'post_id': postId, 'user_id': userId, 'text': text, 'created_at': createdAt};
}
