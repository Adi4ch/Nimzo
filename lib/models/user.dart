class NimzoUser {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int level;
  final int friendsCount;
  final int followersCount;
  final int followingCount;

  const NimzoUser({required this.id, required this.displayName, this.avatarUrl, this.bio, this.level = 1, this.friendsCount = 0, this.followersCount = 0, this.followingCount = 0});

  NimzoUser copyWith({String? id, String? displayName, String? avatarUrl, String? bio, int? level, int? friendsCount, int? followersCount, int? followingCount}) => NimzoUser(id: id ?? this.id, displayName: displayName ?? this.displayName, avatarUrl: avatarUrl ?? this.avatarUrl, bio: bio ?? this.bio, level: level ?? this.level, friendsCount: friendsCount ?? this.friendsCount, followersCount: followersCount ?? this.followersCount, followingCount: followingCount ?? this.followingCount);

  factory NimzoUser.fromMap(Map<String, dynamic> map) => NimzoUser(id: map['id'] as String, displayName: map['display_name'] as String? ?? '', avatarUrl: map['avatar_url'] as String?, bio: map['bio'] as String?, level: map['level'] as int? ?? 1, friendsCount: map['friends_count'] as int? ?? 0, followersCount: map['followers_count'] as int? ?? 0, followingCount: map['following_count'] as int? ?? 0);

  Map<String, dynamic> toMap() => {'id': id, 'display_name': displayName, 'avatar_url': avatarUrl, 'bio': bio, 'level': level, 'friends_count': friendsCount, 'followers_count': followersCount, 'following_count': followingCount};
}
