import 'room_seat.dart';

class NimzoRoom {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final int listenerCount;
  final bool featured;
  final List<RoomSeat> seats;
  final String description;
  final String? backgroundUrl;
  final String? avatarUrl;
  final String privacy;
  final bool passwordProtected;
  final String announcement;
  final String theme;
  final String? createdBy;
  final String? hostId;

  const NimzoRoom(
      {required this.id,
      required this.name,
      this.subtitle = '',
      this.category = 'All',
      this.listenerCount = 0,
      this.featured = false,
      this.seats = const [],
      this.description = '',
      this.backgroundUrl,
      this.avatarUrl,
      this.privacy = 'public',
      this.passwordProtected = false,
      this.announcement = '',
      this.theme = 'mint',
      this.createdBy,
      this.hostId});

  NimzoRoom copyWith(
          {String? id,
          String? name,
          String? subtitle,
          String? category,
          int? listenerCount,
          bool? featured,
          List<RoomSeat>? seats,
          String? description,
          String? backgroundUrl,
          String? avatarUrl,
          String? privacy,
          bool? passwordProtected,
          String? announcement,
          String? theme,
          String? createdBy,
          String? hostId}) =>
      NimzoRoom(
          id: id ?? this.id,
          name: name ?? this.name,
          subtitle: subtitle ?? this.subtitle,
          category: category ?? this.category,
          listenerCount: listenerCount ?? this.listenerCount,
          featured: featured ?? this.featured,
          seats: seats ?? this.seats,
          description: description ?? this.description,
          backgroundUrl: backgroundUrl ?? this.backgroundUrl,
          avatarUrl: avatarUrl ?? this.avatarUrl,
          privacy: privacy ?? this.privacy,
          passwordProtected: passwordProtected ?? this.passwordProtected,
          announcement: announcement ?? this.announcement,
          theme: theme ?? this.theme,
          createdBy: createdBy ?? this.createdBy,
          hostId: hostId ?? this.hostId);

  factory NimzoRoom.fromMap(Map<String, dynamic> map) => NimzoRoom(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      category: map['category'] as String? ?? 'All',
      listenerCount: _intValue(map['listener_count']),
      featured:
          map['featured'] as bool? ?? map['is_featured'] as bool? ?? false,
      seats: ((map['seats'] ?? map['room_seats']) as List<dynamic>? ?? [])
          .map((item) =>
              RoomSeat.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      description: map['description'] as String? ?? '',
      backgroundUrl: map['background_url'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      privacy: map['privacy'] as String? ?? 'public',
      passwordProtected: map['password_protected'] as bool? ?? false,
      announcement: map['announcement'] as String? ?? '',
      theme: map['theme'] as String? ?? 'mint',
      createdBy: map['created_by'] as String?,
      hostId: map['host_id'] as String?);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subtitle': subtitle,
        'category': category,
        'listener_count': listenerCount,
        'featured': featured,
        'description': description,
        'background_url': backgroundUrl,
        'avatar_url': avatarUrl,
        'privacy': privacy,
        'password_protected': passwordProtected,
        'announcement': announcement,
        'theme': theme,
        'seats': seats.map((item) => item.toMap()).toList()
      };

  static int _intValue(dynamic value) => value is num ? value.toInt() : 0;
}
