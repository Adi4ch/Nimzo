class NimzoUser {
  final String id;
  final String displayName;
  final String? username;
  final String? nimzoId;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final String? gender;
  final int level;
  final int activeLevel;
  final int charmLevel;
  final int wealthLevel;
  final int activeXp;
  final int charmXp;
  final int wealthXp;
  final int friendsCount;
  final int followersCount;
  final int followingCount;

  const NimzoUser(
      {required this.id,
      required this.displayName,
      this.username,
      this.nimzoId,
      this.avatarUrl,
      this.bio,
      this.country,
      this.gender,
      this.level = 1,
      this.activeLevel = 1,
      this.charmLevel = 1,
      this.wealthLevel = 1,
      this.activeXp = 0,
      this.charmXp = 0,
      this.wealthXp = 0,
      this.friendsCount = 0,
      this.followersCount = 0,
      this.followingCount = 0});

  NimzoUser copyWith(
          {String? id,
          String? displayName,
          String? username,
          String? nimzoId,
          String? avatarUrl,
          String? bio,
          String? country,
          String? gender,
          int? level,
          int? activeLevel,
          int? charmLevel,
          int? wealthLevel,
          int? activeXp,
          int? charmXp,
          int? wealthXp,
          int? friendsCount,
          int? followersCount,
          int? followingCount}) =>
      NimzoUser(
          id: id ?? this.id,
          displayName: displayName ?? this.displayName,
          username: username ?? this.username,
          nimzoId: nimzoId ?? this.nimzoId,
          avatarUrl: avatarUrl ?? this.avatarUrl,
          bio: bio ?? this.bio,
          country: country ?? this.country,
          gender: gender ?? this.gender,
          level: level ?? this.level,
          activeLevel: activeLevel ?? this.activeLevel,
          charmLevel: charmLevel ?? this.charmLevel,
          wealthLevel: wealthLevel ?? this.wealthLevel,
          activeXp: activeXp ?? this.activeXp,
          charmXp: charmXp ?? this.charmXp,
          wealthXp: wealthXp ?? this.wealthXp,
          friendsCount: friendsCount ?? this.friendsCount,
          followersCount: followersCount ?? this.followersCount,
          followingCount: followingCount ?? this.followingCount);

  factory NimzoUser.fromMap(Map<String, dynamic> map) => NimzoUser(
      id: map['id'] as String,
      displayName: map['display_name'] as String? ?? '',
      username: map['username'] as String?,
      nimzoId: map['nimzo_id'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String?,
      country: map['country'] as String?,
      gender: map['gender'] as String?,
      level: _intValue(map['level'], 1),
      activeLevel: _intValue(map['active_level'], _intValue(map['level'], 1)),
      charmLevel: _intValue(map['charm_level'], 1),
      wealthLevel: _intValue(map['wealth_level'], 1),
      activeXp: _intValue(map['active_xp'], 0),
      charmXp: _intValue(map['charm_xp'], 0),
      wealthXp: _intValue(map['wealth_xp'], 0),
      friendsCount: _intValue(map['friends_count'], 0),
      followersCount: _intValue(map['followers_count'], 0),
      followingCount: _intValue(map['following_count'], 0));

  Map<String, dynamic> toMap() => {
        'id': id,
        'display_name': displayName,
        'username': username,
        'nimzo_id': nimzoId,
        'avatar_url': avatarUrl,
        'bio': bio,
        'country': country,
        'gender': gender,
        'level': level,
        'active_level': activeLevel,
        'charm_level': charmLevel,
        'wealth_level': wealthLevel,
        'active_xp': activeXp,
        'charm_xp': charmXp,
        'wealth_xp': wealthXp,
        'friends_count': friendsCount,
        'followers_count': followersCount,
        'following_count': followingCount
      };

  static int _intValue(dynamic value, int fallback) =>
      value is num ? value.toInt() : fallback;
}
