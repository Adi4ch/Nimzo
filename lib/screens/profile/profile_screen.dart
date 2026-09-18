import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/menu_tile.dart';
import '../host/host_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<NimzoUser?> profile;

  @override
  void initState() {
    super.initState();
    profile = RepositoryFactory.users().getCurrentUser();
  }

  Future<void> editProfile(NimzoUser user) async {
    final name = TextEditingController(text: user.displayName);
    final bio = TextEditingController(text: user.bio);
    final result = await showDialog<NimzoUser>(context: context, builder: (context) => AlertDialog(
      title: const Text('Edit profile'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Display name')),
        TextField(controller: bio, decoration: const InputDecoration(labelText: 'Bio')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () async {
        try {
          final updated = await RepositoryFactory.users().updateProfile(displayName: name.text.trim(), bio: bio.text.trim());
          if (context.mounted) Navigator.pop(context, updated);
        } catch (exception) {
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString())));
        }
      }, child: const Text('Save'))],
    ));
    name.dispose();
    bio.dispose();
    if (result != null && mounted) setState(() => profile = Future.value(result));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<NimzoUser?>(
        future: profile,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: mint));
          if (user == null) return const Center(child: Text('Profile unavailable'));
          return ListView(padding: const EdgeInsets.all(20), children: [
            const AppHeader('Profile'),
            Row(children: [
              CircleAvatar(radius: 42, backgroundColor: lightMint, child: const Icon(Icons.person, size: 45, color: mint)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(user.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('ID: ${user.id}', style: const TextStyle(color: muted)), if (user.bio?.isNotEmpty == true) Text(user.bio!, style: const TextStyle(color: muted)), const SizedBox(height: 8), Text('Lv.${user.level}', style: const TextStyle(color: mint, fontWeight: FontWeight.w800))])),
              IconButton(onPressed: () => editProfile(user), icon: const Icon(Icons.edit_outlined)),
            ]),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ProfileStat('${user.friendsCount}', 'Friends'), ProfileStat('${user.followersCount}', 'Followers'), ProfileStat('${user.followingCount}', 'Following')]),
            const SizedBox(height: 22),
            MenuTile('Host Center', Icons.workspace_premium, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostCenterScreen()))),
            const MenuTile('My Wallet', Icons.account_balance_wallet),
            const MenuTile('Settings', Icons.settings),
            const MenuTile('Help & Support', Icons.help_outline),
            const MenuTile('About Nimzo', Icons.info_outline),
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: () => RepositoryFactory.auth().signOut(), icon: const Icon(Icons.logout), label: const Text('Logout')),
          ]);
        },
      );
}

class ProfileStat extends StatelessWidget {
  final String amount;
  final String label;

  const ProfileStat(this.amount, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Column(children: [Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), Text(label, style: const TextStyle(color: muted, fontSize: 12))]);
}
