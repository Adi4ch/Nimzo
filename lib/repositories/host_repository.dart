import '../models/host_profile.dart';

abstract class HostRepository {
  Future<HostProfile?> getHostProfile(String userId);
}
