import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../repositories/mock/demo_data.dart';
import '../../repositories/repository_factory.dart';
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
        FutureBuilder<List<NimzoRoom>>(
          future: _loadFeaturedRooms(),
          builder: (_, snapshot) => RoomCardRow(snapshot.data ?? const <NimzoRoom>[]),
        ),
        const SectionHeader('More Rooms'),
        FutureBuilder<List<NimzoRoom>>(
          future: _loadMoreRooms(),
          builder: (_, snapshot) => RoomCardRow(snapshot.data ?? const <NimzoRoom>[]),
        ),
      ]);

  Future<List<NimzoRoom>> _loadFeaturedRooms() async {
    try {
      final rooms = await RepositoryFactory.rooms().getFeaturedRooms();
      return RepositoryFactory.usesSupabase ? rooms.take(3).toList() : (rooms.isEmpty ? DemoData.featuredRooms : rooms.take(3).toList());
    } catch (_) {
      if (RepositoryFactory.usesSupabase) rethrow;
      return DemoData.featuredRooms;
    }
  }

  Future<List<NimzoRoom>> _loadMoreRooms() async {
    try {
      final rooms = await RepositoryFactory.rooms().getRooms();
      final more = rooms.where((room) => !room.featured).toList();
      return RepositoryFactory.usesSupabase ? more : (more.isEmpty ? DemoData.moreRooms : more);
    } catch (_) {
      if (RepositoryFactory.usesSupabase) rethrow;
      return DemoData.moreRooms;
    }
  }
}
