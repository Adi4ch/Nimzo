import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';

class RoomActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const RoomActionButton(this.icon, this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(children: [
          FloatingActionButton.small(heroTag: label, onPressed: onTap, backgroundColor: Colors.white, child: Icon(icon, color: mint)),
          Text(label, style: const TextStyle(fontSize: 10, color: muted)),
        ]),
      );
}
