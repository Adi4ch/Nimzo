import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class RoomEditorScreen extends StatefulWidget {
  final NimzoRoom? room;

  const RoomEditorScreen({super.key, this.room});

  @override
  State<RoomEditorScreen> createState() => _RoomEditorScreenState();
}

class _RoomEditorScreenState extends State<RoomEditorScreen> {
  final name = TextEditingController();
  final subtitle = TextEditingController();
  final description = TextEditingController();
  final avatar = TextEditingController();
  final background = TextEditingController();
  final password = TextEditingController();
  final announcement = TextEditingController();
  String category = 'Chat';
  String privacy = 'public';
  String theme = 'mint';
  bool saving = false;
  String? error;

  bool get editing => widget.room != null;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    if (room != null) {
      name.text = room.name;
      subtitle.text = room.subtitle;
      description.text = room.description;
      avatar.text = room.avatarUrl ?? '';
      background.text = room.backgroundUrl ?? '';
      announcement.text = room.announcement;
      category = room.category;
      privacy = room.privacy;
      theme = room.theme;
    }
  }

  Future<void> save() async {
    final roomName = name.text.trim();
    if (roomName.length < 2) {
      setState(() => error = 'Room name must have at least 2 characters.');
      return;
    }
    if (privacy == 'private' && !editing && password.text.trim().length < 4) {
      setState(() =>
          error = 'Private rooms need a password of at least 4 characters.');
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final rooms = RepositoryFactory.rooms();
      final result = editing
          ? await rooms.updateRoomSettings(
              roomId: widget.room!.id,
              name: roomName,
              subtitle: subtitle.text.trim(),
              description: description.text.trim(),
              avatarUrl: _value(avatar),
              backgroundUrl: _value(background),
              privacy: privacy,
              password: _value(password),
              announcement: announcement.text.trim(),
              theme: theme)
          : await rooms.createRoom(
              name: roomName,
              subtitle: subtitle.text.trim(),
              category: category,
              description: description.text.trim(),
              avatarUrl: _value(avatar),
              backgroundUrl: _value(background),
              privacy: privacy,
              password: _value(password),
              announcement: announcement.text.trim(),
              theme: theme);
      if (mounted) Navigator.pop(context, result);
    } catch (exception) {
      if (mounted)
        setState(() {
          error = exception.toString();
          saving = false;
        });
    }
  }

  String? _value(TextEditingController controller) =>
      controller.text.trim().isEmpty ? null : controller.text.trim();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(editing ? 'Edit room' : 'Create room')),
        body: Form(
          child: ListView(padding: nimzoPagePadding, children: [
            TextField(
                controller: name,
                enabled: !saving,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    labelText: 'Room name *',
                    prefixIcon: Icon(Icons.meeting_room_outlined))),
            const SizedBox(height: 12),
            TextField(
                controller: subtitle,
                enabled: !saving,
                decoration: const InputDecoration(
                    labelText: 'Subtitle', prefixIcon: Icon(Icons.short_text))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Chat', child: Text('Chat')),
                  DropdownMenuItem(value: 'Music', child: Text('Music')),
                  DropdownMenuItem(value: 'Gaming', child: Text('Gaming')),
                  DropdownMenuItem(value: 'Popular', child: Text('Popular'))
                ],
                onChanged: saving
                    ? null
                    : (value) => setState(() => category = value!)),
            const SizedBox(height: 12),
            TextField(
                controller: description,
                enabled: !saving,
                maxLines: 3,
                decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes_outlined))),
            const SizedBox(height: 12),
            TextField(
                controller: avatar,
                enabled: !saving,
                decoration: const InputDecoration(
                    labelText: 'Room avatar URL',
                    prefixIcon: Icon(Icons.image_outlined))),
            const SizedBox(height: 12),
            TextField(
                controller: background,
                enabled: !saving,
                decoration: const InputDecoration(
                    labelText: 'Room background URL',
                    prefixIcon: Icon(Icons.wallpaper_outlined))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                value: privacy,
                decoration: const InputDecoration(labelText: 'Privacy'),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public room')),
                  DropdownMenuItem(
                      value: 'private', child: Text('Private room'))
                ],
                onChanged: saving
                    ? null
                    : (value) => setState(() => privacy = value!)),
            const SizedBox(height: 12),
            TextField(
                controller: password,
                enabled: !saving,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: editing ? 'New password (optional)' : 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    helperText: editing
                        ? 'Leave empty to keep the current password.'
                        : 'At least 4 characters for private rooms.')),
            const SizedBox(height: 12),
            TextField(
                controller: announcement,
                enabled: !saving,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Room announcement',
                    prefixIcon: Icon(Icons.campaign_outlined))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
                value: theme,
                decoration: const InputDecoration(labelText: 'Room theme'),
                items: const [
                  DropdownMenuItem(value: 'mint', child: Text('Mint')),
                  DropdownMenuItem(value: 'sunset', child: Text('Sunset')),
                  DropdownMenuItem(value: 'ocean', child: Text('Ocean')),
                  DropdownMenuItem(value: 'mono', child: Text('Mono'))
                ],
                onChanged:
                    saving ? null : (value) => setState(() => theme = value!)),
            if (error != null)
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child:
                      Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 22),
            FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(saving
                    ? 'Saving...'
                    : editing
                        ? 'Save changes'
                        : 'Create room')),
            if (editing)
              const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                      'Only the room owner or host can save these settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted))),
          ]),
        ),
      );

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
}
