import 'package:flutter/material.dart';

import '../models/room_seat.dart';
import '../theme/nimzo_theme.dart';

class MicSeatRow extends StatelessWidget {
  final int start;
  final bool active;
  final List<RoomSeat>? seats;
  final ValueChanged<int>? onTap;

  const MicSeatRow({super.key, required this.start, required this.active, this.seats, this.onTap});

  bool occupied(int index) => seats != null && seats!.length > index && seats![index].userId != null;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var offset = 0; offset < 5; offset++)
            GestureDetector(onTap: onTap == null ? null : () => onTap!(start + offset), child: Column(children: [
              CircleAvatar(radius: 23, backgroundColor: occupied(start + offset) ? lightMint : const Color(0xFFF0F2F2), child: Icon(Icons.mic, color: occupied(start + offset) ? mint : Colors.grey)),
              const SizedBox(height: 5),
              Text(occupied(start + offset) ? 'Live' : '${start + offset + 1}', style: const TextStyle(fontSize: 11)),
            ])),
            ]),
        ],
      );
}
