import 'dart:async';

import '../../models/comment.dart';
import '../../models/social_post.dart';
import '../social_repository.dart';
import 'demo_data.dart';

class MockSocialRepository implements SocialRepository {
    final _postEvents = StreamController<SocialPost>.broadcast();
  final List<SocialPost> posts = [...DemoData.posts];
  final Set<String> likedPosts = {};
  final Set<String> followedUsers = {};
  final List<NimzoComment> comments = [...DemoData.comments];

  @override
  Future<List<SocialPost>> getFeed() async => posts;

  @override
  Future<SocialPost> createPost({required String text, String? imageUrl}) async {
    final post = SocialPost(id: 'post-${posts.length + 1}', userId: DemoData.currentUser.id, text: text, imageUrl: imageUrl);
    posts.insert(0, post);
    _postEvents.add(post);
    return post;
  }

  @override
  Future<List<NimzoComment>> getComments(String postId) async => comments.where((comment) => comment.postId == postId).toList();

  @override
  Future<void> likePost(String postId) async => likedPosts.add(postId);

  @override
  Future<void> unlikePost(String postId) async => likedPosts.remove(postId);

  @override
  Future<void> followUser(String userId) async => followedUsers.add(userId);

  @override
  Future<void> unfollowUser(String userId) async => followedUsers.remove(userId);

  @override
  Future<void> sharePost(String postId) async {}

  @override
  Future<void> addComment(NimzoComment comment) async => comments.add(comment);

  @override
  Future<void> deletePost(String postId) async => posts.removeWhere((post) => post.id == postId && post.userId == DemoData.currentUser.id);

  @override
  Stream<SocialPost> watchPosts() => _postEvents.stream;

  @override
  Future<void> dispose() async => _postEvents.close();

  @override
  Future<void> deleteComment(String commentId) async => comments.removeWhere((comment) => comment.id == commentId && comment.userId == DemoData.currentUser.id);
}
