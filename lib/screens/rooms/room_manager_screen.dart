import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class RoomManagerScreen extends StatefulWidget {
  final String roomId;
  const RoomManagerScreen({super.key, required this.roomId});

  @override
  State<RoomManagerScreen> createState() => _RoomManagerScreenState();
}

class _RoomManagerScreenState extends State<RoomManagerScreen> {
  late Future<List<dynamic>> data;
  final name = TextEditingController();
  final subtitle = TextEditingController();
  final description = TextEditingController();
  final avatar = TextEditingController();
  final background = TextEditingController();
  final password = TextEditingController();
  final announcement = TextEditingController();
  String privacy = 'public';
  String theme = 'mint';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => data = Future.wait([
        RepositoryFactory.rooms().getById(widget.roomId),
        RepositoryFactory.rooms().getSeats(widget.roomId),
        RepositoryFactory.rooms().getMembers(widget.roomId),
        RepositoryFactory.rooms().getActivities(widget.roomId),
        RepositoryFactory.rooms().getRanking(widget.roomId),
        RepositoryFactory.rooms().getModerators(widget.roomId),
        RepositoryFactory.rooms().getSanctions(widget.roomId)
      ]);

  Future<void> _save() async {
    try {
      await RepositoryFactory.rooms().updateRoomSettings(
          roomId: widget.roomId,
          name: name.text.trim(),
          subtitle: subtitle.text.trim(),
          description: description.text.trim(),
          avatarUrl: avatar.text.trim().isEmpty ? null : avatar.text.trim(),
          backgroundUrl:
              background.text.trim().isEmpty ? null : background.text.trim(),
          privacy: privacy,
          password: password.text.trim().isEmpty ? null : password.text.trim(),
          announcement: announcement.text.trim(),
          theme: theme);
      if (mounted) {
        setState(_load);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Room settings saved')));
      }
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  Future<void> _action(String userId, String action) async {
    try {
      await RepositoryFactory.rooms().manageMember(
          roomId: widget.roomId,
          userId: userId,
          action: action,
          durationMinutes: action == 'mute' ? 10 : null);
      if (mounted) {
        setState(_load);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Member $action applied')));
      }
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  Future<void> _toggleModerator(String userId, bool assigned) async {
    try {
      await RepositoryFactory.rooms()
          .assignModerator(widget.roomId, userId, !assigned);
      if (mounted) setState(_load);
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  Future<void> _reportRoom() async {
    try {
      await RepositoryFactory.social().report(
          targetType: 'room',
          targetId: widget.roomId,
          reason: 'other',
          details: 'Reported from Room Manager');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room report submitted')));
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  Future<void> _unban(String userId) async {
    try {
      await RepositoryFactory.rooms()
          .unbanMember(roomId: widget.roomId, userId: userId);
      if (mounted) {
        setState(_load);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Member unbanned')));
      }
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  @override
  void dispose() {
    name.dispose();
    subtitle.dispose();
    description.dispose();
    avatar.dispose();
    background.dispose();
    password.dispose();
    announcement.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Room Manager'), actions: [
        IconButton(
            onPressed: _reportRoom,
            tooltip: 'Report room',
            icon: const Icon(Icons.flag_outlined))
      ]),
      body: FutureBuilder<List<dynamic>>(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(
                  child: CircularProgressIndicator(color: mint));
            if (snapshot.hasError)
              return Center(
                  child: Text('Room manager unavailable: ${snapshot.error}'));
            final room = snapshot.data![0] as NimzoRoom?;
            final members = snapshot.data![2] as List<Map<String, dynamic>>;
            final activities = snapshot.data![3] as List<Map<String, dynamic>>;
            final ranking = snapshot.data![4] as List<Map<String, dynamic>>;
            final moderators = snapshot.data![5] as List<String>;
            final sanctions = snapshot.data![6] as List<Map<String, dynamic>>;
            if (room == null)
              return const Center(child: Text('Room not found.'));
            if (name.text.isEmpty) {
              name.text = room.name;
              subtitle.text = room.subtitle;
              description.text = room.description;
              avatar.text = room.avatarUrl ?? '';
              background.text = room.backgroundUrl ?? '';
              announcement.text = room.announcement;
              privacy = room.privacy;
              theme = room.theme;
            }
            return ListView(padding: const EdgeInsets.all(20), children: [
              const Text('Room settings',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: subtitle,
                  decoration: const InputDecoration(labelText: 'Subtitle')),
              TextField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                  controller: avatar,
                  decoration:
                      const InputDecoration(labelText: 'Room avatar URL')),
              TextField(
                  controller: background,
                  decoration:
                      const InputDecoration(labelText: 'Background URL')),
              DropdownButtonFormField<String>(
                  value: privacy,
                  decoration: const InputDecoration(labelText: 'Privacy'),
                  items: const [
                    DropdownMenuItem(
                        value: 'public', child: Text('Public room')),
                    DropdownMenuItem(
                        value: 'private', child: Text('Private room'))
                  ],
                  onChanged: (value) => setState(() => privacy = value!)),
              TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'New password (optional)',
                      helperText: 'Leave empty to keep the current password.')),
              TextField(
                  controller: announcement,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Announcement')),
              DropdownButtonFormField<String>(
                  value: theme,
                  decoration: const InputDecoration(labelText: 'Theme'),
                  items: const [
                    DropdownMenuItem(value: 'mint', child: Text('Mint')),
                    DropdownMenuItem(value: 'sunset', child: Text('Sunset')),
                    DropdownMenuItem(value: 'ocean', child: Text('Ocean')),
                    DropdownMenuItem(value: 'mono', child: Text('Mono'))
                  ],
                  onChanged: (value) => setState(() => theme = value!)),
              const SizedBox(height: 10),
              FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save settings')),
              const SizedBox(height: 24),
              Text('Members (${members.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
              if (members.isEmpty)
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No active members on seats.',
                        style: TextStyle(color: muted)))
              else
                ...members.map((member) {
                  final userId = member['user_id'].toString();
                  final assigned = moderators.contains(userId);
                  final role = userId == room.createdBy
                      ? 'Owner'
                      : userId == room.hostId
                          ? 'Admin'
                          : assigned
                              ? 'Moderator'
                              : 'Member';
                  return ListTile(
                      leading: CircleAvatar(
                          backgroundColor: lightMint,
                          backgroundImage: member['avatar_url']
                                      ?.toString()
                                      .isNotEmpty ==
                                  true
                              ? NetworkImage(member['avatar_url'].toString())
                              : null,
                          child: member['avatar_url']?.toString().isNotEmpty ==
                                  true
                              ? null
                              : const Icon(Icons.person, color: mint)),
                      title: Text(member['display_name']?.toString() ?? userId),
                      subtitle: Text(role),
                      trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'moderator') {
                              _toggleModerator(userId, assigned);
                            } else {
                              _action(userId, action);
                            }
                          },
                          itemBuilder: (_) => [
                                if (role != 'Owner' && role != 'Admin')
                                  PopupMenuItem(
                                      value: 'moderator',
                                      child: Text(assigned
                                          ? 'Remove moderator'
                                          : 'Make moderator')),
                                if (role != 'Owner' && role != 'Admin')
                                  const PopupMenuItem(
                                      value: 'mute',
                                      child: Text('Mute 10 minutes')),
                                if (role != 'Owner' && role != 'Admin')
                                  const PopupMenuItem(
                                      value: 'kick', child: Text('Kick')),
                                if (role != 'Owner' && role != 'Admin')
                                  const PopupMenuItem(
                                      value: 'ban', child: Text('Ban'))
                              ]));
                }),
              const SizedBox(height: 24),
              Text('Room activity (${activities.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
              ...activities.take(10).map((item) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.history, color: mint),
                  title: Text(item['activity_type']?.toString() ?? 'Activity'),
                  subtitle: Text(item['message']?.toString() ?? ''))),
              const SizedBox(height: 24),
              const Text('Room ranking',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
              if (ranking.isEmpty)
                const Text('No ranking data yet.',
                    style: TextStyle(color: muted))
              else
                ...ranking.map((item) => ListTile(
                    title: Text('Rank ${item['rank'] ?? '-'}'),
                    trailing: Text('${item['score'] ?? 0} pts'))),
              const SizedBox(height: 24),
              Text('Recent sanctions (${sanctions.length})',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
              ...sanctions.take(10).map((item) => ListTile(
                  dense: true,
                  title: Text(item['action']?.toString() ?? 'Action'),
                  subtitle: Text(item['target_user']?.toString() ?? ''),
                  trailing: item['action'] == 'ban'
                      ? TextButton(
                          onPressed: () =>
                              _unban(item['target_user'].toString()),
                          child: const Text('Unban'))
                      : null)),
            ]);
          }));
}
