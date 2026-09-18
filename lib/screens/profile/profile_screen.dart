import 'package:flutter/material.dart';

import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/menu_tile.dart';
import '../host/host_center_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const AppHeader('Profile'),
        const Row(children: [
          CircleAvatar(radius: 42, backgroundColor: lightMint, child: Icon(Icons.person, size: 45, color: mint)),
          SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nimzo User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('ID: 12345678', style: TextStyle(color: muted)), SizedBox(height: 8), Text('Lv.5', style: TextStyle(color: mint, fontWeight: FontWeight.w800))]),
        ]),
        const SizedBox(height: 18),
        const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ProfileStat('256', 'Friends'), ProfileStat('4.2K', 'Followers'), ProfileStat('1.8K', 'Following')]),
        const SizedBox(height: 22),
        MenuTile('Host Center', Icons.workspace_premium, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostCenterScreen()))),
        const MenuTile('My Wallet', Icons.account_balance_wallet),
        const MenuTile('Settings', Icons.settings),
        const MenuTile('Help & Support', Icons.help_outline),
        const MenuTile('About Nimzo', Icons.info_outline),
      ]);
}

class ProfileStat extends StatelessWidget {
  final String amount;
  final String label;

  const ProfileStat(this.amount, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Column(children: [Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), Text(label, style: const TextStyle(color: muted, fontSize: 12))]);
}
