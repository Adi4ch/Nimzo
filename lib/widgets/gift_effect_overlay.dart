import 'package:flutter/material.dart';

import '../services/gift_effect_service.dart';
import '../theme/nimzo_theme.dart';

class GiftEffectOverlay extends StatefulWidget {
  final GiftEffect effect;
  final String senderName;

  const GiftEffectOverlay({super.key, required this.effect, required this.senderName});

  @override
  State<GiftEffectOverlay> createState() => _GiftEffectOverlayState();
}

class _GiftEffectOverlayState extends State<GiftEffectOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(vsync: this, duration: widget.effect.duration)..forward();

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut), child: ScaleTransition(scale: Tween(begin: .7, end: 1.1).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut)), child: Column(mainAxisSize: MainAxisSize.min, children: [Text(widget.effect.icon, style: const TextStyle(fontSize: 72)), Text('${widget.senderName} sent a gift', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(widget.effect.tier.name.toUpperCase(), style: const TextStyle(color: lightMint, fontWeight: FontWeight.w900))])));
}