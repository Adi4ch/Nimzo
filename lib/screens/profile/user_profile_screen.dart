import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import 'level_summary.dart';

class ProfileSearchScreen extends StatefulWidget {
  const ProfileSearchScreen({super.key});

  @override
  State<ProfileSearchScreen> createState() => _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends State<ProfileSearchScreen> {
  final controller = TextEditingController();
  List<NimzoUser> results = const [];
  bool loading = false;

  Future<void> _search(String value) async {
    if (value.trim().isEmpty) {
      setState(() => results = const []);
      return;
    }
    setState(() => loading = true);
    try {
      final found = await RepositoryFactory.users().search(value);
      if (mounted) setState(() => results = found);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Find people')),
        body: ListView(padding: nimzoPagePadding, children: [
          TextField(
              controller: controller,
              autofocus: true,
              onChanged: _search,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Name, username or Nimzo ID')),
          const SizedBox(height: 16),
          if (loading)
            const Center(child: CircularProgressIndicator(color: mint)),
          if (!loading && controller.text.isNotEmpty && results.isEmpty)
            const Text('No users found.'),
          ...results.map((user) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                  backgroundColor: lightMint,
                  child: const Icon(Icons.person, color: mint)),
              title: Text(user.displayName),
              subtitle: Text('@${user.username ?? user.nimzoId ?? user.id}'),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => UserProfileScreen(userId: user.id))))),
        ]),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({required this.userId, super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<NimzoUser?> profile;
  bool following = false;

  @override
  void initState() {
    super.initState();
    profile = RepositoryFactory.users().getById(widget.userId);
    _loadFollowState();
  }

  Future<void> _loadFollowState() async {
    final value = await RepositoryFactory.users().isFollowing(widget.userId);
    if (mounted) setState(() => following = value);
  }

  Future<void> _toggleFollow() async {
    final users = RepositoryFactory.users();
    if (following) {
      await users.unfollow(widget.userId);
    } else {
      await users.follow(widget.userId);
    }
    if (mounted) setState(() => following = !following);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: FutureBuilder<NimzoUser?>(
            future: profile,
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                    child: CircularProgressIndicator(color: mint));
              if (user == null)
                return const Center(child: Text('Profile unavailable'));
              return ListView(padding: nimzoPagePadding, children: [
                CircleAvatar(
                    radius: 48,
                    backgroundColor: lightMint,
                    backgroundImage: user.avatarUrl?.isNotEmpty == true
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, size: 48, color: mint)),
                const SizedBox(height: 10),
                Center(
                    child: Text(user.displayName,
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w800))),
                if (user.username?.isNotEmpty == true)
                  Center(
                      child: Text('@${user.username}',
                          style: const TextStyle(color: muted))),
                Center(
                    child: Text('Nimzo ID: ${user.nimzoId ?? user.id}',
                        style: const TextStyle(color: muted))),
                if (user.bio?.isNotEmpty == true)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                          child: Text(user.bio!, textAlign: TextAlign.center))),
                const SizedBox(height: 12),
                FilledButton.icon(
                    onPressed: _toggleFollow,
                    icon: Icon(
                        following ? Icons.person_remove : Icons.person_add),
                    label: Text(following ? 'Following' : 'Follow')),
                const SizedBox(height: 18),
                LevelSummary(user: user),
              ]);
            }),
      );
}
