import 'package:flutter/material.dart';

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
        _post(0, 'Life is better when you smile'),
        _post(1, 'Good vibes only'),
      ]);

  Widget _post(int id, String text) => SocialPostCard(
        text: text,
        isLiked: liked.contains(id),
        isFollowed: followed.contains(id),
        onLike: () => setState(() => liked.contains(id) ? liked.remove(id) : liked.add(id)),
        onFollow: () => setState(() => followed.contains(id) ? followed.remove(id) : followed.add(id)),
        onComment: () => showNimzoNotice(context, 'Comments are ready for the social feed.'),
        onShare: () => showNimzoNotice(context, 'Post link copied.'),
      );
}
