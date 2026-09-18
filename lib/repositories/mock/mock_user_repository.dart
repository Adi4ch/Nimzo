import '../../models/user.dart';
import '../user_repository.dart';
import 'demo_data.dart';

class MockUserRepository implements UserRepository {
  NimzoUser user = DemoData.currentUser;

  @override
  Future<NimzoUser?> getCurrentUser() async => user;

  @override
  Future<NimzoUser?> ensureCurrentUser() async => user;

  @override
  Future<NimzoUser?> getById(String id) async => id == user.id ? user : null;

  @override
  Future<NimzoUser> updateProfile({required String displayName, required String username, String? bio, String? avatarUrl, String? country, String? gender}) async {
    user = user.copyWith(displayName: displayName, username: username, bio: bio, avatarUrl: avatarUrl, country: country, gender: gender);
    return user;
  }

  @override
  Future<List<NimzoUser>> search(String query) async => [user];
}
