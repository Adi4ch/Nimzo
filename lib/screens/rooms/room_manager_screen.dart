import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../models/room_seat.dart';
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
  final background = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  void _load() => data = Future.wait([RepositoryFactory.rooms().getById(widget.roomId), RepositoryFactory.rooms().getSeats(widget.roomId), RepositoryFactory.rooms().getActivities(widget.roomId), RepositoryFactory.rooms().getRanking(widget.roomId), RepositoryFactory.rooms().getModerators(widget.roomId), RepositoryFactory.rooms().getSanctions(widget.roomId)]);

  Future<void> _save() async {
    try { await RepositoryFactory.rooms().updateRoomSettings(roomId: widget.roomId, name: name.text.trim(), subtitle: subtitle.text.trim(), description: description.text.trim(), backgroundUrl: background.text.trim().isEmpty ? null : background.text.trim()); if (mounted) { setState(_load); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room settings saved'))); } } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
  }

  Future<void> _action(String userId, String action) async {
    try { await RepositoryFactory.rooms().manageMember(roomId: widget.roomId, userId: userId, action: action, durationMinutes: action == 'mute' ? 10 : null); if (mounted) { setState(_load); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Member $action applied'))); } } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
  }

  Future<void> _toggleModerator(String userId, bool assigned) async {
    try { await RepositoryFactory.rooms().assignModerator(widget.roomId, userId, !assigned); if (mounted) setState(_load); } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
  }

  Future<void> _reportRoom() async {
    try { await RepositoryFactory.social().report(targetType: 'room', targetId: widget.roomId, reason: 'other', details: 'Reported from Room Manager'); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Room report submitted'))); } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
  }

  @override
  void dispose() { name.dispose(); subtitle.dispose(); description.dispose(); background.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Room Manager'), actions: [IconButton(onPressed: _reportRoom, tooltip: 'Report room', icon: const Icon(Icons.flag_outlined))]), body: FutureBuilder<List<dynamic>>(future: data, builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: mint));
    if (snapshot.hasError) return Center(child: Text('Room manager unavailable: ${snapshot.error}'));
    final room = snapshot.data![0] as NimzoRoom?;
    final seats = snapshot.data![1] as List<RoomSeat>;
    final activities = snapshot.data![2] as List<Map<String, dynamic>>;
    final ranking = snapshot.data![3] as List<Map<String, dynamic>>;
    final moderators = snapshot.data![4] as List<String>;
    final sanctions = snapshot.data![5] as List<Map<String, dynamic>>;
    if (room == null) return const Center(child: Text('Room not found.'));
    if (name.text.isEmpty) { name.text = room.name; subtitle.text = room.subtitle; description.text = room.description; background.text = room.backgroundUrl ?? ''; }
    final members = seats.where((seat) => seat.userId != null).toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Room settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
      TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
      TextField(controller: subtitle, decoration: const InputDecoration(labelText: 'Subtitle')),
      TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
      TextField(controller: background, decoration: const InputDecoration(labelText: 'Background URL')),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Text('Save settings')),
      const SizedBox(height: 24),
      Text('Members (${members.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
      if (members.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No active members on seats.', style: TextStyle(color: muted))) else ...members.map((seat) { final assigned = moderators.contains(seat.userId); return ListTile(title: Text(seat.userId!), subtitle: Text(assigned ? 'Moderator' : 'Member'), trailing: PopupMenuButton<String>(onSelected: (action) { if (action == 'moderator') { _toggleModerator(seat.userId!, assigned); } else { _action(seat.userId!, action); } }, itemBuilder: (_) => [PopupMenuItem(value: 'moderator', child: Text(assigned ? 'Remove moderator' : 'Make moderator')), const PopupMenuItem(value: 'mute', child: Text('Mute 10 minutes')), const PopupMenuItem(value: 'kick', child: Text('Kick')), const PopupMenuItem(value: 'ban', child: Text('Ban'))])); }),
      const SizedBox(height: 24),
      Text('Room activity (${activities.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
      ...activities.take(10).map((item) => ListTile(dense: true, leading: const Icon(Icons.history, color: mint), title: Text(item['activity_type']?.toString() ?? 'Activity'), subtitle: Text(item['message']?.toString() ?? ''))),
      const SizedBox(height: 24),
      const Text('Room ranking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
      if (ranking.isEmpty) const Text('No ranking data yet.', style: TextStyle(color: muted)) else ...ranking.map((item) => ListTile(title: Text('Rank ${item['rank'] ?? '-'}'), trailing: Text('${item['score'] ?? 0} pts'))),
      const SizedBox(height: 24),
      Text('Recent sanctions (${sanctions.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
      ...sanctions.take(10).map((item) => ListTile(dense: true, title: Text(item['action']?.toString() ?? 'Action'), subtitle: Text(item['target_user']?.toString() ?? ''))),
    ]);
  }));
}
