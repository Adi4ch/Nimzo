class HostProfile {
  final String id;
  final String userId;
  final int level;
  final String? agencyName;
  final int earningsCoins;

  const HostProfile({required this.id, required this.userId, this.level = 1, this.agencyName, this.earningsCoins = 0});

  HostProfile copyWith({String? id, String? userId, int? level, String? agencyName, int? earningsCoins}) => HostProfile(id: id ?? this.id, userId: userId ?? this.userId, level: level ?? this.level, agencyName: agencyName ?? this.agencyName, earningsCoins: earningsCoins ?? this.earningsCoins);

  factory HostProfile.fromMap(Map<String, dynamic> map) => HostProfile(id: map['id'] as String, userId: map['user_id'] as String? ?? '', level: map['level'] as int? ?? 1, agencyName: map['agency_name'] as String?, earningsCoins: map['earnings_coins'] as int? ?? 0);

  Map<String, dynamic> toMap() => {'id': id, 'user_id': userId, 'level': level, 'agency_name': agencyName, 'earnings_coins': earningsCoins};
}
