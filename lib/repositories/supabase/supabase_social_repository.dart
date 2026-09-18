import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_bootstrap.dart';
import '../../models/comment.dart';
import '../../models/social_post.dart';
import '../social_repository.dart';

class SupabaseSocialRepository implements SocialRepository {
  SupabaseClient get _client => SupabaseBootstrap.client ?? (throw StateError('Supabase is not configured.'));
  final _posts = StreamController<SocialPost>.broadcast();
  RealtimeChannel? _channel;

  @override
  Future<List<SocialPost>> getFeed() async {
    final userId = _client.auth.currentUser?.id;
    final blocked = userId == null ? const <String>[] : await getBlockedUsers();
    final rows = await _client.from('social_posts').select().order('created_at', ascending: false);
    return rows.where((row) => !blocked.contains(row['user_id'])).map((row) => SocialPost.fromMap(row)).toList();
  }

  @override
  Future<SocialPost> createPost({required String text, String? imageUrl}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    final row = await _client.from('social_posts').insert({'user_id': userId, 'text': text, 'image_url': imageUrl}).select().single();
    return SocialPost.fromMap(row);
  }

  @override
  Future<void> deletePost(String postId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client.from('social_posts').delete().eq('id', postId).eq('user_id', userId);
  }

  @override
  Stream<SocialPost> watchPosts() {
    _channel ??= _client.channel('social-feed').onPostgresChanges(event: PostgresChangeEvent.insert, schema: 'public', table: 'social_posts', callback: (payload) => _posts.add(SocialPost.fromMap(payload.newRecord))).subscribe();
    return _posts.stream;
  }

  @override
  Future<void> dispose() async {
    if (_channel != null) await _client.removeChannel(_channel!);
    _channel = null;
    await _posts.close();
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
  Future<void> sharePost(String postId) async { await _client.rpc('share_social_post', params: {'target_post': postId}); }

  @override
  Future<void> blockUser(String userId) async { await _client.rpc('block_user', params: {'target_user': userId}); }

  @override
  Future<void> unblockUser(String userId) async { await _client.rpc('unblock_user', params: {'target_user': userId}); }

  @override
  Future<List<String>> getBlockedUsers() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    final rows = await _client.from('blocks').select('blocked_id').eq('blocker_id', userId);
    return rows.map((row) => row['blocked_id'].toString()).toList();
  }

  @override
  Future<void> report({required String targetType, required String targetId, required String reason, String details = ''}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client.from('reports').insert({'reporter_id': userId, 'target_type': targetType, 'target_id': targetId, 'reason': reason, 'details': details});
  }

  @override
  Future<void> addComment(NimzoComment comment) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client.from('comments').insert({'post_id': comment.postId, 'user_id': userId, 'text': comment.text});
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw StateError('An authenticated user is required.');
    await _client.from('comments').delete().eq('id', commentId).eq('user_id', userId);
  }
}
