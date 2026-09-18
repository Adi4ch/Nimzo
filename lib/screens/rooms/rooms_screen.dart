import 'package:flutter/material.dart';

import '../../screens/room/voice_room_screen.dart';
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
  final rooms = const ['Chill Vibes', 'Music Room', 'Friendship Room', 'Gaming Zone', 'Love & Relationship', 'Study & Career'];

  @override
  Widget build(BuildContext context) => Column(children: [
        const AppHeader('Rooms'),
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
              labelStyle: TextStyle(color: category == index ? Colors.white : ink, fontWeight: FontWeight.w700),
              onSelected: (_) => setState(() => category = index),
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
              title: Text(rooms[index], style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Sing  |  Dance  |  Enjoy  |  2.4K', style: TextStyle(color: muted)),
              trailing: FilledButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VoiceRoomScreen(name: rooms[index]))),
                style: FilledButton.styleFrom(backgroundColor: mint),
                child: const Text('Join'),
              ),
            ),
          ),
        ),
      ]);
}
