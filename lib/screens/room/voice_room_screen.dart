import 'package:flutter/material.dart';

import '../../models/room_seat.dart';
import '../../repositories/mock/demo_data.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/avatar.dart';
import '../../widgets/mic_seat.dart';
import '../../widgets/notice.dart';
import '../../widgets/room_actions.dart';
import '../games/game_list_screen.dart';

class VoiceRoomScreen extends StatefulWidget {
  final String name;
  final String? roomId;

  const VoiceRoomScreen({super.key, required this.name, this.roomId});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen> {
  List<RoomSeat> seats = const [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSeats();
  }

  Future<void> loadSeats() async {
    if (widget.roomId == null) {
      setState(() { seats = DemoData.seatsForRoom(widget.name); loading = false; });
      return;
    }
    try {
      final loaded = await RepositoryFactory.rooms().getSeats(widget.roomId!);
      if (mounted) setState(() { seats = loaded.length == 10 ? loaded : DemoData.seatsForRoom(widget.roomId!); loading = false; });
    } catch (_) {
      if (mounted) setState(() { seats = DemoData.seatsForRoom(widget.roomId!); loading = false; });
    }
  }

  Future<void> tapSeat(int position) async {
    if (widget.roomId == null || seats[position].userId != null) return;
    try {
      final joined = await RepositoryFactory.rooms().joinSeat(widget.roomId!, position);
      if (mounted) setState(() => seats = [...seats]..[position] = joined);
    } catch (exception) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Column(children: [
          AppHeader(widget.name, back: true),
          Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFE4FAF0), Colors.white])), child: Column(children: [const NimzoAvatar(), const SizedBox(height: 10), Text(widget.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)), const Text('Sing  |  Dance  |  Enjoy', style: TextStyle(color: muted))])),
          Expanded(child: loading ? const Center(child: CircularProgressIndicator(color: mint)) : Padding(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [MicSeatRow(start: 0, active: true, seats: seats, onTap: tapSeat), MicSeatRow(start: 5, active: false, seats: seats, onTap: tapSeat)]))),
          Padding(padding: const EdgeInsets.only(right: 14, bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [RoomActionButton(Icons.card_giftcard, 'Gift', () => showNimzoNotice(context, 'Gift panel is ready for virtual coins.')), RoomActionButton(Icons.music_note, 'Music', () => showNimzoNotice(context, 'Music controls are coming soon.')), RoomActionButton(Icons.sports_esports, 'Game', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameListScreen())))])),
          Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), decoration: BoxDecoration(color: const Color(0xFFF4F8F6), borderRadius: BorderRadius.circular(28)), child: const Row(children: [Expanded(child: Text('Say something...', style: TextStyle(color: muted))), Icon(Icons.emoji_emotions_outlined, color: muted), SizedBox(width: 14), Icon(Icons.send, color: mint)])),
        ])),
      );
}