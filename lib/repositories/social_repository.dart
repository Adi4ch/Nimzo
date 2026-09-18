import '../models/comment.dart';
import '../models/social_post.dart';

abstract class SocialRepository {
  Future<List<SocialPost>> getFeed({bool followingOnly = false});
  Future<SocialPost> createPost({required String text, String? imageUrl});
  Future<void> deletePost(String postId);
  Stream<SocialPost> watchPosts();
  Future<void> dispose();
  Future<List<NimzoComment>> getComments(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> sharePost(String postId);
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Future<List<String>> getBlockedUsers();
  Future<void> report(
      {required String targetType,
      required String targetId,
      required String reason,
      String details = ''});
  Future<void> addComment(NimzoComment comment);
  Future<void> deleteComment(String commentId);
}
