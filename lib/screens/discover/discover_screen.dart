import 'package:flutter/material.dart';

import '../../models/social_post.dart';
import '../../repositories/mock/demo_data.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/notice.dart';
import '../../widgets/social_post_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final liked = <String>{};
  final followed = <String>{};
  late Future<List<SocialPost>> feed;

  @override
  void initState() { super.initState(); feed = loadFeed(); }

  Future<List<SocialPost>> loadFeed() async {
    try { final loaded = await RepositoryFactory.social().getFeed(); return loaded.isEmpty ? DemoData.posts : loaded; } catch (_) { return DemoData.posts; }
  }

  Future<void> createPost() async {
    final text = TextEditingController();
    final value = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: const Text('Create post'), content: TextField(controller: text, maxLines: 4, decoration: const InputDecoration(hintText: 'What is on your mind?')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, text.text.trim()), child: const Text('Post'))]));
    text.dispose();
    if (value == null || value.isEmpty) return;
    try { await RepositoryFactory.social().createPost(text: value); if (mounted) setState(() => feed = loadFeed()); } catch (exception) { if (mounted) showNimzoNotice(context, exception.toString()); }
  }

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const AppHeader('Discover'),
        Align(alignment: Alignment.centerRight, child: IconButton(onPressed: createPost, icon: const Icon(Icons.add_circle_outline, color: mint))),
        Row(children: ['For You', 'Following', 'Videos'].asMap().entries.map((entry) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: entry.key == 0 ? mint : lightMint, borderRadius: BorderRadius.circular(18)), child: Center(child: Text(entry.value, style: TextStyle(color: entry.key == 0 ? Colors.white : ink, fontWeight: FontWeight.w700))))))).toList()),
        const SizedBox(height: 18),
          FutureBuilder<List<SocialPost>>(future: feed, builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: mint));
            final posts = snapshot.data ?? const <SocialPost>[];
            if (posts.isEmpty) return const Padding(padding: EdgeInsets.all(30), child: Text('No posts yet.'));
            return Column(children: [for (final post in posts) _post(post)]);
          }),
      ]);

        Widget _post(SocialPost post) => SocialPostCard(
          text: post.text,
        isLiked: liked.contains(post.id),
        isFollowed: followed.contains(post.userId),
        onLike: () async { final isLiked = liked.contains(post.id); setState(() => isLiked ? liked.remove(post.id) : liked.add(post.id)); try { await (isLiked ? RepositoryFactory.social().unlikePost(post.id) : RepositoryFactory.social().likePost(post.id)); } catch (_) {} },
        onFollow: () async { final isFollowed = followed.contains(post.userId); setState(() => isFollowed ? followed.remove(post.userId) : followed.add(post.userId)); try { await (isFollowed ? RepositoryFactory.social().unfollowUser(post.userId) : RepositoryFactory.social().followUser(post.userId)); } catch (_) {} },
        onComment: () => showNimzoNotice(context, 'Comments are ready for the social feed.'),
        onShare: () => showNimzoNotice(context, 'Post link copied.'),
      );
}
