import '../models/user.dart';

abstract class UserRepository {
  Future<NimzoUser?> getCurrentUser();
  Future<NimzoUser?> ensureCurrentUser();
  Future<NimzoUser?> getById(String id);
  Future<NimzoUser> updateProfile({required String displayName, required String username, String? bio, String? avatarUrl, String? country, String? gender});
  Future<List<NimzoUser>> search(String query);
}
