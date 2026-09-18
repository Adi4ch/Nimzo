import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
        child: Row(children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink)),
          const Spacer(),
          const Text('See All', style: TextStyle(color: mint, fontWeight: FontWeight.w700)),
        ]),
      );
}
