import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../theme/nimzo_theme.dart';

class LevelSummary extends StatelessWidget {
  final NimzoUser user;

  const LevelSummary({required this.user, super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        _level('Active', user.activeLevel, user.activeXp),
        _level('Charm', user.charmLevel, user.charmXp),
        _level('Wealth', user.wealthLevel, user.wealthXp),
      ]);

  Widget _level(String label, int level, int xp) {
    final requirement = level * 1000;
    return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(
              width: 70,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(
              child: LinearProgressIndicator(
                  value: (xp / requirement).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  color: mint,
                  backgroundColor: lightMint)),
          const SizedBox(width: 10),
          Text('Lv.$level  $xp/$requirement',
              style: const TextStyle(fontSize: 11, color: muted))
        ]));
  }
}
