import 'package:flutter/material.dart';

import '../../models/social_post.dart';
import '../../repositories/mock/demo_data.dart';
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
  final liked = <int>{};
  final followed = <int>{};

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const AppHeader('Discover'),
        Row(children: ['For You', 'Following', 'Videos'].asMap().entries.map((entry) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: entry.key == 0 ? mint : lightMint, borderRadius: BorderRadius.circular(18)), child: Center(child: Text(entry.value, style: TextStyle(color: entry.key == 0 ? Colors.white : ink, fontWeight: FontWeight.w700))))))).toList()),
        const SizedBox(height: 18),
          for (var index = 0; index < DemoData.posts.length; index++) _post(DemoData.posts[index], index),
      ]);

        Widget _post(SocialPost post, int index) => SocialPostCard(
          text: post.text,
        isLiked: liked.contains(index),
        isFollowed: followed.contains(index),
        onLike: () => setState(() => liked.contains(index) ? liked.remove(index) : liked.add(index)),
        onFollow: () => setState(() => followed.contains(index) ? followed.remove(index) : followed.add(index)),
        onComment: () => showNimzoNotice(context, 'Comments are ready for the social feed.'),
        onShare: () => showNimzoNotice(context, 'Post link copied.'),
      );
}
