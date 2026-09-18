import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/chat_message.dart';
import '../../models/gift.dart';
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
  final roomRepository = RepositoryFactory.rooms();
  final chatRepository = RepositoryFactory.chat();
  final giftRepository = RepositoryFactory.gifts();
  final messageController = TextEditingController();
  List<RoomSeat> seats = const [];
  List<ChatMessage> messages = const [];
  List<NimzoGift> gifts = const [];
  StreamSubscription<List<RoomSeat>>? seatSubscription;
  StreamSubscription<ChatMessage>? chatSubscription;
  StreamSubscription<dynamic>? giftSubscription;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadSeats();
    loadRoomStreams();
  }

  Future<void> loadRoomStreams() async {
    if (widget.roomId == null) return;
    try {
      messages = await chatRepository.getMessages(widget.roomId!);
      gifts = await giftRepository.getGifts();
      seatSubscription = roomRepository.watchSeats(widget.roomId!).listen((value) { if (mounted && value.length == 10) setState(() => seats = value); });
      chatSubscription = chatRepository.watchMessages(widget.roomId!).listen((message) { if (mounted) setState(() => messages = [...messages, message]); });
      giftSubscription = giftRepository.watchRoomGifts(widget.roomId!).listen((event) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A virtual gift was sent in this room.'))); });
      if (mounted) setState(() {});
    } catch (_) {
      // The room remains usable with local seat/demo state when realtime is unavailable.
    }
  }

  Future<void> loadSeats() async {
    if (widget.roomId == null) {
      setState(() { seats = DemoData.seatsForRoom(widget.name); loading = false; });
      return;
    }
    try {
      final loaded = await roomRepository.getSeats(widget.roomId!);
      if (mounted) setState(() { seats = loaded.length == 10 ? loaded : DemoData.seatsForRoom(widget.roomId!); loading = false; });
    } catch (_) {
      if (mounted) setState(() { seats = DemoData.seatsForRoom(widget.roomId!); loading = false; });
    }
  }

  Future<void> tapSeat(int position) async {
    if (widget.roomId == null || seats[position].userId != null) return;
    try {
      final joined = await roomRepository.joinSeat(widget.roomId!, position);
      if (mounted) setState(() => seats = [...seats]..[position] = joined);
    } catch (exception) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || widget.roomId == null) return;
    messageController.clear();
    try {
      final message = await chatRepository.sendMessage(widget.roomId!, text);
      if (mounted) setState(() => messages = [...messages, message]);
    } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
  }

  Future<void> openGiftPanel() async {
    if (widget.roomId == null) { showNimzoNotice(context, 'Gifts are available in connected rooms.'); return; }
    if (gifts.isEmpty) { showNimzoNotice(context, 'No gifts are available right now.'); return; }
    await showModalBottomSheet<void>(context: context, builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Send a gift', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 10, children: [for (final gift in gifts) OutlinedButton.icon(onPressed: () async {
        try {
          await giftRepository.sendGift(roomId: widget.roomId!, giftId: gift.id, quantity: 1, idempotencyKey: 'gift-${DateTime.now().microsecondsSinceEpoch}');
          if (context.mounted) Navigator.pop(context);
        } catch (exception) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
      }, icon: Icon(gift.iconName == 'favorite' ? Icons.favorite : Icons.card_giftcard, color: mint), label: Text('${gift.name}  ${gift.coinCost}'))]),
      const SizedBox(height: 8),
      const Text('Virtual coins only. Balance changes are server-side.', style: TextStyle(color: muted)),
    ]))));
  }

  @override
  void dispose() {
    seatSubscription?.cancel();
    chatSubscription?.cancel();
    giftSubscription?.cancel();
    messageController.dispose();
    roomRepository.disposeRoom(widget.roomId ?? '');
    chatRepository.disposeRoom(widget.roomId ?? '');
    giftRepository.disposeRoom(widget.roomId ?? '');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Column(children: [
          AppHeader(widget.name, back: true),
          Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFE4FAF0), Colors.white])), child: Column(children: [const NimzoAvatar(), const SizedBox(height: 10), Text(widget.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)), const Text('Sing  |  Dance  |  Enjoy', style: TextStyle(color: muted))])),
          Expanded(child: loading ? const Center(child: CircularProgressIndicator(color: mint)) : Padding(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [MicSeatRow(start: 0, active: true, seats: seats, onTap: tapSeat), MicSeatRow(start: 5, active: false, seats: seats, onTap: tapSeat)]))),
          Padding(padding: const EdgeInsets.only(right: 14, bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [RoomActionButton(Icons.card_giftcard, 'Gift', openGiftPanel), RoomActionButton(Icons.music_note, 'Music', () => showNimzoNotice(context, 'Music player service is ready for local playback.')), RoomActionButton(Icons.sports_esports, 'Game', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameListScreen())))])),
          Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFF4F8F6), borderRadius: BorderRadius.circular(28)), child: Row(children: [Expanded(child: TextField(controller: messageController, onSubmitted: (_) => sendMessage(), decoration: const InputDecoration(hintText: 'Say something...', border: InputBorder.none))), const Icon(Icons.emoji_emotions_outlined, color: muted), const SizedBox(width: 14), IconButton(onPressed: sendMessage, icon: const Icon(Icons.send, color: mint))])),
        ])),
      );
}