import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';

class SocialPostCard extends StatelessWidget {
  final String text;
  final bool isLiked;
  final bool isFollowed;
  final VoidCallback onLike;
  final VoidCallback onFollow;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;

  const SocialPostCard({super.key, required this.text, required this.isLiked, required this.isFollowed, required this.onLike, required this.onFollow, required this.onComment, required this.onShare, this.onReport, this.onBlock});

  @override
  Widget build(BuildContext context) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const CircleAvatar(backgroundColor: lightMint, child: Icon(Icons.person, color: mint)), const SizedBox(width: 10), const Text('Nimzo User', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: onFollow, child: Text(isFollowed ? 'Following' : 'Follow')), if (onReport != null || onBlock != null) PopupMenuButton<String>(onSelected: (value) { if (value == 'report') onReport?.call(); if (value == 'block') onBlock?.call(); }, itemBuilder: (_) => [if (onReport != null) const PopupMenuItem(value: 'report', child: Text('Report')), if (onBlock != null) const PopupMenuItem(value: 'block', child: Text('Block author'))])]),
        const SizedBox(height: 12), Text(text), const SizedBox(height: 12),
        Container(height: 170, decoration: BoxDecoration(color: lightMint, borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.image_outlined, size: 48, color: mint))),
        const SizedBox(height: 10),
        Row(children: [IconButton(onPressed: onLike, icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : ink)), const Text('342'), IconButton(onPressed: onComment, icon: const Icon(Icons.chat_bubble_outline)), const Text('56'), const Spacer(), IconButton(onPressed: onShare, icon: const Icon(Icons.share_outlined))]),
      ])));
}
