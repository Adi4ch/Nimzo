import '../../models/host_profile.dart';
import '../host_repository.dart';
import 'demo_data.dart';

class MockHostRepository implements HostRepository {
  @override
  Future<HostProfile?> getHostProfile(String userId) async => userId == DemoData.hostProfile.userId ? DemoData.hostProfile : null;

  @override
  Future<Map<String, dynamic>?> getAgency(String userId) async => {'id': 'agency-1', 'name': DemoData.hostProfile.agencyName, 'owner_id': userId, 'status': 'active'};

  @override
  Future<List<Map<String, dynamic>>> getAgencyHosts(String agencyId) async => const [];

  @override
  Future<Map<String, dynamic>> createAgency(String name, String description) async => {'id': 'agency-new', 'name': name, 'description': description};

  @override
  Future<void> addAgencyHost(String agencyId, String hostId) async {}

  @override
  Future<void> removeAgencyHost(String agencyId, String hostId) async {}

  @override
  Future<Map<String, dynamic>> getStatistics(String userId) async => {'gifts_received': 0, 'rooms_hosted': 0};

  @override
  Future<List<Map<String, dynamic>>> getRecentActivity(String userId) async => const [];

  @override
  Future<List<Map<String, dynamic>>> getAgencies() async => const [{'id': 'agency-1', 'name': 'Nimzo Agency', 'description': 'Community hosts', 'status': 'active'}];

  @override
  Future<void> applyToAgency(String agencyId) async {}
}
