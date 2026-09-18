import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../repositories/mock/demo_data.dart';
import '../../repositories/repository_factory.dart';
import '../../screens/room/voice_room_screen.dart';
import 'room_manager_screen.dart';
import 'room_editor_screen.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/avatar.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  int category = 0;
  final categories = const ['All', 'Popular', 'New', 'Music', 'Chat'];
  List<NimzoRoom> rooms = DemoData.rooms;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final loaded = await RepositoryFactory.rooms()
          .getRooms(category: categories[category]);
      if (mounted && loaded.isNotEmpty) setState(() => rooms = loaded);
    } catch (_) {
      // Keep the local catalog when the project is not configured or seeded.
    }
  }

  Future<void> _createRoom() async {
    final created = await Navigator.push<NimzoRoom>(
        context, MaterialPageRoute(builder: (_) => const RoomEditorScreen()));
    if (created != null && mounted) {
      setState(() => rooms = [created, ...rooms]);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room created successfully')));
    }
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          const Expanded(child: AppHeader('Rooms')),
          IconButton(
              onPressed: _createRoom,
              tooltip: 'Create room',
              icon: const Icon(Icons.add_business_outlined, color: mint))
        ]),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) => ChoiceChip(
              label: Text(categories[index]),
              selected: category == index,
              selectedColor: mint,
              labelStyle: TextStyle(
                  color: category == index ? Colors.white : ink,
                  fontWeight: FontWeight.w700),
              onSelected: (_) {
                setState(() => category = index);
                _loadRooms();
              },
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: rooms.length,
            itemBuilder: (_, index) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 7),
              leading: const NimzoAvatar(),
              title: Text(rooms[index].name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Sing  |  Dance  |  Enjoy  |  2.4K',
                  style: TextStyle(color: muted)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                RoomManagerScreen(roomId: rooms[index].id))),
                    icon: const Icon(Icons.admin_panel_settings_outlined,
                        color: mint)),
                FilledButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => VoiceRoomScreen(
                                roomId: rooms[index].id,
                                name: rooms[index].name))),
                    style: FilledButton.styleFrom(backgroundColor: mint),
                    child: const Text('Join'))
              ]),
            ),
          ),
        ),
      ]);
}
