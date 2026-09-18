import '../models/user.dart';

abstract class UserRepository {
  Future<NimzoUser?> getCurrentUser();
  Future<NimzoUser?> ensureCurrentUser();
  Future<NimzoUser?> getById(String id);
  Future<List<NimzoUser>> search(String query);
  Future<bool> isFollowing(String userId);
  Future<void> follow(String userId);
  Future<void> unfollow(String userId);
  Future<NimzoUser> updateProfile(
      {required String displayName,
      String? username,
      String? bio,
      String? avatarUrl,
      String? country,
      String? gender});
}
