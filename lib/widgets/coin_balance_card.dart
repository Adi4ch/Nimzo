import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';

class CoinBalanceCard extends StatelessWidget {
  final int balance;
  final VoidCallback onRecharge;

  const CoinBalanceCard({super.key, required this.balance, required this.onRecharge});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFDDF8EA), Color(0xFFF6FFFA)])),
        child: Row(children: [
          const Icon(Icons.monetization_on, color: Color(0xFFFFB800), size: 42), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Balance', style: TextStyle(color: muted)), Text('$balance', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: ink))])),
          FilledButton(onPressed: onRecharge, child: const Text('Recharge')),
        ]),
      );
}
