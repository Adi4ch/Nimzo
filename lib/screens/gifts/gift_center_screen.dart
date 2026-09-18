import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/gift.dart';
import '../../models/gift_event.dart';
import '../../repositories/repository_factory.dart';
import '../../services/gift_effect_service.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/gift_effect_overlay.dart';

class GiftCenterScreen extends StatefulWidget {
  const GiftCenterScreen({super.key});

  @override
  State<GiftCenterScreen> createState() => _GiftCenterScreenState();
}

class _GiftCenterScreenState extends State<GiftCenterScreen> {
  final repository = RepositoryFactory.gifts();
  final roomController = TextEditingController();
  final receiverController = TextEditingController();
  late Future<List<dynamic>> data;
  int quantity = 1;
  String? selectedGift;
  GiftEffect? activeEffect;
  StreamSubscription<GiftEvent>? eventSubscription;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => data = Future.wait([
        repository.getGifts(),
        repository.getInventory(),
        repository.getFavorites(),
        repository.getRecent()
      ]);

  @override
  void dispose() {
    eventSubscription?.cancel();
    roomController.dispose();
    receiverController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(String giftId, bool value) async {
    await repository.setFavorite(giftId, value);
    if (mounted) setState(_refresh);
  }

  Future<void> _send(NimzoGift gift) async {
    final roomId = roomController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a room ID to send a gift.')));
      return;
    }
    try {
      final event = await repository.sendGift(
          roomId: roomId,
          giftId: gift.id,
          receiverId: receiverController.text.trim().isEmpty
              ? null
              : receiverController.text.trim(),
          quantity: quantity,
          idempotencyKey:
              'gift-center-${DateTime.now().microsecondsSinceEpoch}');
      if (!mounted) return;
      setState(() {
        activeEffect = GiftEffectService.forCost(event.totalCost);
        _refresh();
      });
      Future<void>.delayed(activeEffect!.duration, () {
        if (mounted) setState(() => activeEffect = null);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${gift.name} combo x${event.quantity} sent')));
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Gifts')),
        body: FutureBuilder<List<dynamic>>(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(
                  child: CircularProgressIndicator(color: mint));
            if (snapshot.hasError)
              return Center(
                  child: Text('Gift catalog unavailable: ${snapshot.error}'));
            final gifts = snapshot.data![0] as List<NimzoGift>;
            final inventory = snapshot.data![1] as Map<String, int>;
            final favorites = snapshot.data![2] as Set<String>;
            final recent = snapshot.data![3] as List<GiftEvent>;
            return Stack(children: [
              ListView(padding: const EdgeInsets.all(20), children: [
                TextField(
                    controller: roomController,
                    decoration: const InputDecoration(
                        labelText: 'Room ID for sending',
                        prefixIcon: Icon(Icons.meeting_room_outlined))),
                const SizedBox(height: 10),
                TextField(
                    controller: receiverController,
                    decoration: const InputDecoration(
                        labelText: 'Receiver user ID (optional)',
                        prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(
                      child: Text('Combo quantity',
                          style: TextStyle(fontWeight: FontWeight.w800))),
                  IconButton(
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline)),
                  Text('$quantity',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  IconButton(
                      onPressed: quantity < 99
                          ? () => setState(() => quantity++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline))
                ]),
                const SizedBox(height: 8),
                const Text('Gift bag and catalog',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
                const SizedBox(height: 8),
                if (gifts.isEmpty)
                  const Text('No gifts are available.')
                else
                  ...gifts.map((gift) {
                    final owned = inventory[gift.id] ?? 0;
                    final favorite = favorites.contains(gift.id);
                    return Card(
                        child: ListTile(
                            leading: Icon(
                                gift.iconName == 'favorite'
                                    ? Icons.favorite
                                    : Icons.card_giftcard,
                                color: mint),
                            title: Text(gift.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800)),
                            subtitle: Text(
                                '${gift.coinCost} virtual coins  |  Owned: $owned  |  Combo total: ${gift.coinCost * quantity}'),
                            trailing: Wrap(spacing: 0, children: [
                              IconButton(
                                  onPressed: () =>
                                      _toggleFavorite(gift.id, !favorite),
                                  icon: Icon(
                                      favorite ? Icons.star : Icons.star_border,
                                      color: favorite ? Colors.amber : muted)),
                              FilledButton(
                                  onPressed: () => _send(gift),
                                  child: const Text('Send'))
                            ])));
                  }),
                const SizedBox(height: 18),
                const Text('Recent gifts',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
                if (recent.isEmpty)
                  const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('No recent gifts yet.',
                          style: TextStyle(color: muted)))
                else
                  ...recent.map((event) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.auto_awesome, color: mint),
                      title: Text('Gift combo x${event.quantity}'),
                      subtitle: Text(
                          '${event.totalCost} virtual coins  |  Room ${event.roomId}'))),
              ]),
              if (activeEffect != null)
                Positioned.fill(
                    child: IgnorePointer(
                        child: Center(
                            child: GiftEffectOverlay(
                                effect: activeEffect!, senderName: 'You')))),
            ]);
          },
        ),
      );
}
