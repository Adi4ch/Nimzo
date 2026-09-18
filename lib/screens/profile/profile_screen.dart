import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/menu_tile.dart';
import '../host/host_center_screen.dart';
import '../gifts/gift_center_screen.dart';
import '../platform/platform_screen.dart';
import '../wallet/wallet_screen.dart';
import 'settings_screen.dart';
import 'level_summary.dart';
import 'user_profile_screen.dart';

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
    final username = TextEditingController(text: user.username);
    final bio = TextEditingController(text: user.bio);
    final avatar = TextEditingController(text: user.avatarUrl);
    final country = TextEditingController(text: user.country);
    final gender = TextEditingController(text: user.gender);
    final result = await showDialog<NimzoUser>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Edit profile'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: name,
                    decoration:
                        const InputDecoration(labelText: 'Display name')),
                TextField(
                    controller: username,
                    decoration: const InputDecoration(labelText: 'Username')),
                TextField(
                    controller: bio,
                    decoration: const InputDecoration(labelText: 'Bio')),
                TextField(
                    controller: avatar,
                    decoration: const InputDecoration(labelText: 'Avatar URL')),
                TextField(
                    controller: country,
                    decoration: const InputDecoration(labelText: 'Country')),
                TextField(
                    controller: gender,
                    decoration: const InputDecoration(labelText: 'Gender')),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      try {
                        final updated = await RepositoryFactory.users()
                            .updateProfile(
                                displayName: name.text.trim(),
                                username: username.text.trim(),
                                bio: bio.text.trim(),
                                avatarUrl: avatar.text.trim(),
                                country: country.text.trim(),
                                gender: gender.text.trim());
                        if (context.mounted) Navigator.pop(context, updated);
                      } catch (exception) {
                        if (context.mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(exception.toString())));
                      }
                    },
                    child: const Text('Save'))
              ],
            ));
    name.dispose();
    username.dispose();
    bio.dispose();
    avatar.dispose();
    country.dispose();
    gender.dispose();
    if (result != null && mounted)
      setState(() => profile = Future.value(result));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<NimzoUser?>(
        future: profile,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator(color: mint));
          if (user == null)
            return const Center(child: Text('Profile unavailable'));
          return ListView(padding: const EdgeInsets.all(20), children: [
            Row(children: [
              const Expanded(child: AppHeader('Profile')),
              IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileSearchScreen())),
                  icon: const Icon(Icons.search),
                  tooltip: 'Search users')
            ]),
            Row(children: [
              CircleAvatar(
                  radius: 42,
                  backgroundColor: lightMint,
                  backgroundImage: user.avatarUrl?.isNotEmpty == true
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl?.isNotEmpty == true
                      ? null
                      : const Icon(Icons.person, size: 45, color: mint)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(user.displayName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    if (user.username?.isNotEmpty == true)
                      Text('@${user.username}',
                          style: const TextStyle(color: muted)),
                    Text('Nimzo ID: ${user.nimzoId ?? user.id}',
                        style: const TextStyle(color: muted)),
                    if (user.bio?.isNotEmpty == true)
                      Text(user.bio!, style: const TextStyle(color: muted))
                  ])),
              IconButton(
                  onPressed: () => editProfile(user),
                  icon: const Icon(Icons.edit_outlined)),
            ]),
            const SizedBox(height: 18),
            LevelSummary(user: user),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ProfileStat('${user.friendsCount}', 'Friends'),
              ProfileStat('${user.followersCount}', 'Followers'),
              ProfileStat('${user.followingCount}', 'Following')
            ]),
            const SizedBox(height: 22),
            MenuTile('Host Center', Icons.workspace_premium,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HostCenterScreen()))),
            MenuTile('VIP, Mall & Tasks', Icons.auto_awesome,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PlatformScreen()))),
            MenuTile('Gift Bag', Icons.card_giftcard,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GiftCenterScreen()))),
            MenuTile('My Wallet', Icons.account_balance_wallet,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const WalletScreen()))),
            MenuTile('Settings', Icons.settings,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()))),
            MenuTile('Help & Support', Icons.help_outline,
                onTap: () => _showSupport(context)),
            MenuTile('About Nimzo', Icons.info_outline,
                onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Nimzo',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Nimzo uses virtual coins only.',
                        children: const [
                          Text('A social rooms and community app.')
                        ])),
            const SizedBox(height: 12),
            OutlinedButton.icon(
                onPressed: () => RepositoryFactory.auth().signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Logout')),
          ]);
        },
      );

  void _showSupport(BuildContext context) => showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
            title: const Text('Help & Support'),
            content: const Text(
                'For account, safety, or room issues, contact support@nimzo.app.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'))
            ],
          ));
}

class ProfileStat extends StatelessWidget {
  final String amount;
  final String label;

  const ProfileStat(this.amount, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(amount,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        Text(label, style: const TextStyle(color: muted, fontSize: 12))
      ]);
}
