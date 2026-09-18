import '../models/comment.dart';
import '../models/social_post.dart';

abstract class SocialRepository {
  Future<List<SocialPost>> getFeed();
  Future<List<NimzoComment>> getComments(String postId);
  Future<void> likePost(String postId);
  Future<void> followUser(String userId);
  Future<void> sharePost(String postId);
  Future<void> addComment(NimzoComment comment);
}
