import '../models/host_profile.dart';

abstract class HostRepository {
  Future<HostProfile?> getHostProfile(String userId);
  Future<Map<String, dynamic>?> getAgency(String userId);
  Future<List<Map<String, dynamic>>> getAgencyHosts(String agencyId);
  Future<Map<String, dynamic>> createAgency(String name, String description);
  Future<void> addAgencyHost(String agencyId, String hostId);
  Future<void> removeAgencyHost(String agencyId, String hostId);
  Future<Map<String, dynamic>> getStatistics(String userId);
}
