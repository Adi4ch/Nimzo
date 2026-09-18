import '../models/comment.dart';
import '../models/social_post.dart';

abstract class SocialRepository {
  Future<List<SocialPost>> getFeed();
  Future<SocialPost> createPost({required String text, String? imageUrl});
  Future<List<NimzoComment>> getComments(String postId);
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> sharePost(String postId);
  Future<void> addComment(NimzoComment comment);
}
