import '../../models/user.dart';
import '../user_repository.dart';
import 'demo_data.dart';

class MockUserRepository implements UserRepository {
  @override
  Future<NimzoUser?> getCurrentUser() async => DemoData.currentUser;

  @override
  Future<NimzoUser?> getById(String id) async => id == DemoData.currentUser.id ? DemoData.currentUser : null;
}
