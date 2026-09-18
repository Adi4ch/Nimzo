import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/comment.dart';
import '../../models/social_post.dart';
import '../social_repository.dart';

class SupabaseSocialRepository implements SocialRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));

  @override
  Future<List<SocialPost>> getFeed() async {
    final rows = await _client.from('social_posts').select().order('created_at', ascending: false);
    return rows.map(SocialPost.fromMap).toList();
  }

  @override
  Future<SocialPost> createPost({required String text, String? imageUrl}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    final row = await _client.from('social_posts').insert({'user_id': userId, 'text': text, 'image_url': imageUrl}).select().single();
    return SocialPost.fromMap(row);
  }

  @override
  Future<List<NimzoComment>> getComments(String postId) async {
    final rows = await _client.from('comments').select().eq('post_id', postId).order('created_at');
    return rows.map(NimzoComment.fromMap).toList();
  }

  @override
  Future<void> likePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client.from('post_likes').upsert({'post_id': postId, 'user_id': userId});
  }

  @override
  Future<void> unlikePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client.from('post_likes').delete().eq('post_id', postId).eq('user_id', userId);
  }

  @override
  Future<void> followUser(String userId) async {
    final followerId = _client.auth.currentUser?.id;
    if (followerId == null) throw StateError('An authenticated user is required.');
    await _client.from('post_follows').upsert({'follower_id': followerId, 'following_id': userId});
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final followerId = _client.auth.currentUser?.id;
    if (followerId == null) throw StateError('An authenticated user is required.');
    await _client.from('post_follows').delete().eq('follower_id', followerId).eq('following_id', userId);
  }

  @override
  Future<void> sharePost(String postId) async {}

  @override
  Future<void> addComment(NimzoComment comment) async {
    await _client.from('comments').insert(comment.toMap());
  }
}
