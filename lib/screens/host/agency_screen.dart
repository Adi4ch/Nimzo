import 'package:flutter/material.dart';

import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class AgencyScreen extends StatefulWidget {
  const AgencyScreen({super.key});

  @override
  State<AgencyScreen> createState() => _AgencyScreenState();
}

class _AgencyScreenState extends State<AgencyScreen> {
  late Future<List<dynamic>> data;

  @override
  void initState() { super.initState(); _load(); }

  void _load() {
    final userId = RepositoryFactory.auth().currentUser?.id;
    data = Future.wait([RepositoryFactory.host().getAgencies(), userId == null ? Future<Map<String, dynamic>?>.value(null) : RepositoryFactory.host().getAgency(userId)]);
  }

  Future<void> _apply(String id) async {
    try { await RepositoryFactory.host().applyToAgency(id); if (mounted) { setState(_load); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agency application submitted'))); } } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
  }

  Future<void> _invite(String agencyId) async {
    final controller = TextEditingController();
    final hostId = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: const Text('Invite host'), content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Host user ID')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Invite'))]));
    controller.dispose();
    if (hostId == null || hostId.isEmpty) return;
    try { await RepositoryFactory.host().addAgencyHost(agencyId, hostId); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Host invitation sent'))); } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Agency Center')), body: FutureBuilder<List<dynamic>>(future: data, builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: mint));
    if (snapshot.hasError) return Center(child: Text('Agency data unavailable: ${snapshot.error}'));
    final rows = (snapshot.data?[0] as List<Map<String, dynamic>>?) ?? const <Map<String, dynamic>>[];
    final current = snapshot.data?[1] as Map<String, dynamic>?;
    if (rows.isEmpty) return const Center(child: Text('No agencies are accepting applications.'));
    return ListView(padding: const EdgeInsets.all(20), children: [const Text('Find an agency', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 8), ...rows.map((agency) => Card(child: ListTile(title: Text(agency['name']?.toString() ?? 'Agency', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${agency['description'] ?? ''}\nStatus: ${agency['status'] ?? 'pending'}'), isThreeLine: true, trailing: FilledButton(onPressed: () => _apply(agency['id'].toString()), child: const Text('Apply'))))), if (current != null) ...[const SizedBox(height: 20), Card(child: ListTile(leading: const Icon(Icons.business, color: mint), title: Text('Your agency: ${current['name'] ?? ''}'), subtitle: Text('Status: ${current['status'] ?? 'pending'}'), trailing: IconButton(onPressed: () => _invite(current['id'].toString()), icon: const Icon(Icons.person_add_alt_1))))]]);
  }));
}
