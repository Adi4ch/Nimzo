import 'package:flutter/material.dart';

import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/avatar.dart';
import '../../widgets/mic_seat.dart';
import '../../widgets/notice.dart';
import '../../widgets/room_actions.dart';
import '../games/game_list_screen.dart';

class VoiceRoomScreen extends StatelessWidget {
  final String name;

  const VoiceRoomScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            AppHeader(name, back: true),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFE4FAF0), Colors.white])),
              child: Column(children: [
                const NimzoAvatar(),
                const SizedBox(height: 10),
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
                const Text('Sing  |  Dance  |  Enjoy', style: TextStyle(color: muted)),
              ]),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  MicSeatRow(start: 0, active: true),
                  MicSeatRow(start: 5, active: false),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                RoomActionButton(Icons.card_giftcard, 'Gift', () => showNimzoNotice(context, 'Gift panel is ready for virtual coins.')),
                RoomActionButton(Icons.music_note, 'Music', () => showNimzoNotice(context, 'Music controls are coming soon.')),
                RoomActionButton(Icons.sports_esports, 'Game', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameListScreen()))),
              ]),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(color: const Color(0xFFF4F8F6), borderRadius: BorderRadius.circular(28)),
              child: const Row(children: [
                Expanded(child: Text('Say something...', style: TextStyle(color: muted))),
                Icon(Icons.emoji_emotions_outlined, color: muted),
                SizedBox(width: 14),
                Icon(Icons.send, color: mint),
              ]),
            ),
          ]),
        ),
      );
}
