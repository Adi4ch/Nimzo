class SocialPost {
  final String id;
  final String userId;
  final String text;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;

  const SocialPost({required this.id, required this.userId, required this.text, this.imageUrl, this.likes = 0, this.comments = 0, this.shares = 0});

  SocialPost copyWith({String? id, String? userId, String? text, String? imageUrl, int? likes, int? comments, int? shares}) => SocialPost(id: id ?? this.id, userId: userId ?? this.userId, text: text ?? this.text, imageUrl: imageUrl ?? this.imageUrl, likes: likes ?? this.likes, comments: comments ?? this.comments, shares: shares ?? this.shares);

  factory SocialPost.fromMap(Map<String, dynamic> map) => SocialPost(id: map['id'] as String, userId: map['user_id'] as String? ?? '', text: map['text'] as String? ?? '', imageUrl: map['image_url'] as String?, likes: map['likes'] as int? ?? 0, comments: map['comments'] as int? ?? 0, shares: map['shares'] as int? ?? 0);

  Map<String, dynamic> toMap() => {'id': id, 'user_id': userId, 'text': text, 'image_url': imageUrl, 'likes': likes, 'comments': comments, 'shares': shares};
}
