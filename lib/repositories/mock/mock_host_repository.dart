import '../../models/host_profile.dart';
import '../host_repository.dart';
import 'demo_data.dart';

class MockHostRepository implements HostRepository {
  @override
  Future<HostProfile?> getHostProfile(String userId) async => userId == DemoData.hostProfile.userId ? DemoData.hostProfile : null;
}
