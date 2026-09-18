class NimzoUser {
  final String id;
  final String displayName;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final String? gender;
  final int level;
  final int friendsCount;
  final int followersCount;
  final int followingCount;

  const NimzoUser({required this.id, required this.displayName, this.username = '', this.avatarUrl, this.bio, this.country, this.gender, this.level = 1, this.friendsCount = 0, this.followersCount = 0, this.followingCount = 0});

  NimzoUser copyWith({String? id, String? displayName, String? username, String? avatarUrl, String? bio, String? country, String? gender, int? level, int? friendsCount, int? followersCount, int? followingCount}) => NimzoUser(id: id ?? this.id, displayName: displayName ?? this.displayName, username: username ?? this.username, avatarUrl: avatarUrl ?? this.avatarUrl, bio: bio ?? this.bio, country: country ?? this.country, gender: gender ?? this.gender, level: level ?? this.level, friendsCount: friendsCount ?? this.friendsCount, followersCount: followersCount ?? this.followersCount, followingCount: followingCount ?? this.followingCount);

  factory NimzoUser.fromMap(Map<String, dynamic> map) => NimzoUser(id: map['id'] as String, displayName: map['display_name'] as String? ?? '', username: map['username'] as String? ?? '', avatarUrl: map['avatar_url'] as String?, bio: map['bio'] as String?, country: map['country'] as String?, gender: map['gender'] as String?, level: map['level'] as int? ?? 1, friendsCount: map['friends_count'] as int? ?? 0, followersCount: map['followers_count'] as int? ?? 0, followingCount: map['following_count'] as int? ?? 0);

  Map<String, dynamic> toMap() => {'id': id, 'display_name': displayName, 'username': username, 'avatar_url': avatarUrl, 'bio': bio, 'country': country, 'gender': gender, 'level': level, 'friends_count': friendsCount, 'followers_count': followersCount, 'following_count': followingCount};
}
