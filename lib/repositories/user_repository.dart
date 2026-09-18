import '../models/user.dart';

abstract class UserRepository {
  Future<NimzoUser?> getCurrentUser();
  Future<NimzoUser?> ensureCurrentUser();
  Future<NimzoUser?> getById(String id);
  Future<NimzoUser> updateProfile({required String displayName, String? bio, String? avatarUrl});
}
