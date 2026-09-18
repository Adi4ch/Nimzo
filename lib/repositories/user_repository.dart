import '../models/user.dart';

abstract class UserRepository {
  Future<NimzoUser?> getCurrentUser();
  Future<NimzoUser?> getById(String id);
}
