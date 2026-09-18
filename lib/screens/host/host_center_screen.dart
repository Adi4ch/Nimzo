import 'package:flutter/material.dart';

import '../../theme/nimzo_theme.dart';
import '../../widgets/menu_tile.dart';

class HostCenterScreen extends StatelessWidget {
  const HostCenterScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Host Center')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: lightMint, borderRadius: BorderRadius.circular(22)), child: const Row(children: [
            Icon(Icons.workspace_premium, color: mint, size: 42),
            SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Build your room community', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ink)), SizedBox(height: 5), Text('Track hosting and agency activity.', style: TextStyle(color: muted))])),
          ])),
          const SizedBox(height: 20),
          const MenuTile('Host Dashboard', Icons.dashboard),
          const MenuTile('Agency Center', Icons.business),
          const MenuTile('Earnings', Icons.insights),
          const MenuTile('Host Guidelines', Icons.menu_book),
        ],
      );
}
