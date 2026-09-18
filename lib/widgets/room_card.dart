import 'package:flutter/material.dart';

import '../models/room.dart';
import '../screens/room/voice_room_screen.dart';
import '../theme/nimzo_theme.dart';
import 'avatar.dart';

class RoomCard extends StatelessWidget {
  final NimzoRoom room;
  final int index;

  const RoomCard({super.key, required this.room, required this.index});

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VoiceRoomScreen(name: room.name))),
        child: Container(
          width: 105,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 12)]),
          child: Column(children: [
            Expanded(child: NimzoAvatar(icon: index.isEven ? Icons.people : Icons.music_note)),
            const SizedBox(height: 7),
            Text(room.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            const Text('1.2K', style: TextStyle(color: muted, fontSize: 11)),
          ]),
        ),
      );
}

class RoomCardRow extends StatelessWidget {
  final List<NimzoRoom> rooms;

  const RoomCardRow(this.rooms, {super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 125,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: rooms.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, index) => RoomCard(room: rooms[index], index: index),
        ),
      );
}
