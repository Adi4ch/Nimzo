import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';

class NimzoAvatar extends StatelessWidget {
  final IconData icon;

  const NimzoAvatar({super.key, this.icon = Icons.music_note});

  @override
  Widget build(BuildContext context) => Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF0C5F48), Color(0xFF19C985)]),
          border: Border.all(color: mint, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      );
}
