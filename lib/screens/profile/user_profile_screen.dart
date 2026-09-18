import 'package:flutter/material.dart';

import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class UserProfileScreen extends StatelessWidget {
  final String userId;

  const UserProfileScreen({required this.userId, super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: FutureBuilder(
          future: RepositoryFactory.users().getById(userId),
          builder: (context, snapshot) {
            final user = snapshot.data;
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(
                  child: CircularProgressIndicator(color: mint));
            if (user == null)
              return const Center(child: Text('Profile unavailable'));
            return ListView(padding: nimzoPagePadding, children: [
              CircleAvatar(
                  radius: 44,
                  backgroundColor: lightMint,
                  backgroundImage: user.avatarUrl?.isNotEmpty == true
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl?.isNotEmpty == true
                      ? null
                      : const Icon(Icons.person, size: 44, color: mint)),
              const SizedBox(height: 12),
              Center(
                  child: Text(user.displayName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800))),
              Center(
                  child: Text('Nimzo ID: ${user.id}',
                      style: const TextStyle(color: muted))),
              if (user.bio?.isNotEmpty == true)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                        child: Text(user.bio!, textAlign: TextAlign.center))),
              const SizedBox(height: 20),
              ListTile(
                  leading: const Icon(Icons.bolt, color: mint),
                  title: Text('Active Level ${user.level}'),
                  subtitle: const Text('Activity level')),
              ListTile(
                  leading: const Icon(Icons.favorite, color: mint),
                  title: Text('Followers ${user.followersCount}'),
                  subtitle: const Text('Community connections')),
            ]);
          },
        ),
      );
}
