import 'package:flutter/material.dart';

import '../../models/host_profile.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/menu_tile.dart';

class HostCenterScreen extends StatelessWidget {
  const HostCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = RepositoryFactory.auth().currentUser?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Host Center')),
      body: userId == null ? const Center(child: Text('Login required')) : FutureBuilder<HostProfile?>(
        future: RepositoryFactory.host().getHostProfile(userId),
        builder: (context, snapshot) {
          final host = snapshot.data;
          return ListView(padding: const EdgeInsets.all(20), children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: lightMint, borderRadius: BorderRadius.circular(22)), child: Row(children: [
              const Icon(Icons.workspace_premium, color: mint, size: 42),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(host?.agencyName ?? 'Build your room community', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ink)), const SizedBox(height: 5), Text(host == null ? 'Host profile is ready to be activated.' : 'Level ${host.level}  |  ${host.earningsCoins} virtual coins', style: const TextStyle(color: muted))])),
            ])),
            const SizedBox(height: 20),
            const MenuTile('Host Dashboard', Icons.dashboard),
            const MenuTile('Agency Center', Icons.business),
            const MenuTile('Earnings', Icons.insights),
            const MenuTile('Host Guidelines', Icons.menu_book),
          ]);
        },
      ),
    );
  }
}