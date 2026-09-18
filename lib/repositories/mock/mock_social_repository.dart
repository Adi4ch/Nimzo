import '../../models/comment.dart';
import '../../models/social_post.dart';
import '../social_repository.dart';
import 'demo_data.dart';

class MockSocialRepository implements SocialRepository {
  final Set<String> likedPosts = {};
  final Set<String> followedUsers = {};
  final List<NimzoComment> comments = [...DemoData.comments];

  @override
  Future<List<SocialPost>> getFeed() async => DemoData.posts;

  @override
  Future<List<NimzoComment>> getComments(String postId) async => comments.where((comment) => comment.postId == postId).toList();

  @override
  Future<void> likePost(String postId) async => likedPosts.add(postId);

  @override
  Future<void> followUser(String userId) async => followedUsers.add(userId);

  @override
  Future<void> sharePost(String postId) async {}

  @override
  Future<void> addComment(NimzoComment comment) async => comments.add(comment);
}
