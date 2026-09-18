import 'package:flutter/material.dart';

import '../../widgets/app_header.dart';
import '../../widgets/room_card.dart';
import '../../widgets/section_header.dart';
import '../../theme/nimzo_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(children: [
        const AppHeader('Nimzo'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFFDFFBED), Color(0xFFF5FFFA)])),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Welcome to Nimzo', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: ink)),
            SizedBox(height: 7),
            Text('Make new friends  |  Talk  |  Enjoy', style: TextStyle(color: muted)),
          ]),
        ),
        const SectionHeader('Featured Rooms'),
        const RoomCardRow(['Chill Vibes', 'Music Zone', 'Friends Talk']),
        const SectionHeader('More Rooms'),
        const RoomCardRow(['Ludo Lounge', 'Carrom Club', '8 Ball Pool', 'Study Circle']),
      ]);
}
