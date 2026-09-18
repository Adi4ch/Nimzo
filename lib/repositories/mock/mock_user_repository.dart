import '../../models/user.dart';
import '../user_repository.dart';
import 'demo_data.dart';

class MockUserRepository implements UserRepository {
  NimzoUser user = DemoData.currentUser;

  @override
  Future<NimzoUser?> getCurrentUser() async => user;

  @override
  Future<NimzoUser?> getById(String id) async => id == user.id ? user : null;

  @override
  Future<NimzoUser> updateProfile({required String displayName, String? bio, String? avatarUrl}) async {
    user = user.copyWith(displayName: displayName, avatarUrl: avatarUrl);
    return user;
  }
}
