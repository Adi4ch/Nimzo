import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';

class MicSeatRow extends StatelessWidget {
  final int start;
  final bool active;

  const MicSeatRow({super.key, required this.start, required this.active});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var offset = 0; offset < 5; offset++)
            Column(children: [
              CircleAvatar(radius: 23, backgroundColor: active ? lightMint : const Color(0xFFF0F2F2), child: Icon(Icons.mic, color: active ? mint : Colors.grey)),
              const SizedBox(height: 5),
              Text(active ? 'Live' : '${start + offset + 1}', style: const TextStyle(fontSize: 11)),
            ]),
        ],
      );
}
