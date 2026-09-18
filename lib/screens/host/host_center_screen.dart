import 'package:flutter/material.dart';

import '../../models/host_profile.dart';
import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';
import '../../widgets/menu_tile.dart';
import 'agency_screen.dart';

class HostCenterScreen extends StatefulWidget {
  const HostCenterScreen({super.key});

  @override
  State<HostCenterScreen> createState() => _HostCenterScreenState();
}

class _HostCenterScreenState extends State<HostCenterScreen> {
  late Future<List<dynamic>> data;

  @override
  void initState() { super.initState(); _refresh(); }

  void _refresh() {
    final userId = RepositoryFactory.auth().currentUser?.id;
    data = userId == null ? Future<List<dynamic>>.value(const [null, null, <String, dynamic>{}, <Map<String, dynamic>>[]]) : Future.wait([RepositoryFactory.host().getHostProfile(userId), RepositoryFactory.host().getAgency(userId), RepositoryFactory.host().getStatistics(userId), RepositoryFactory.host().getRecentActivity(userId)]);
  }

  Future<void> _createAgency() async {
    final name = TextEditingController();
    final description = TextEditingController();
    final submit = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Create agency'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: description, decoration: const InputDecoration(labelText: 'Description'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create'))]));
    if (submit == true) {
      try { await RepositoryFactory.host().createAgency(name.text, description.text); if (mounted) setState(_refresh); } catch (exception) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.toString()))); }
    }
    name.dispose();
    description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = RepositoryFactory.auth().currentUser?.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Host Center')),
      body: userId == null ? const Center(child: Text('Login required')) : FutureBuilder<List<dynamic>>(
        future: data,
        builder: (context, snapshot) {
          final host = snapshot.data?[0] as HostProfile?;
          final agency = snapshot.data?[1] as Map<String, dynamic>?;
          final statistics = snapshot.data?[2] as Map<String, dynamic>? ?? const {};
          final activity = snapshot.data?[3] as List<Map<String, dynamic>>? ?? const [];
          return ListView(padding: const EdgeInsets.all(20), children: [
            Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: lightMint, borderRadius: BorderRadius.circular(22)), child: Row(children: [
              const Icon(Icons.workspace_premium, color: mint, size: 42),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(host?.agencyName ?? 'Build your room community', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ink)), const SizedBox(height: 5), Text(host == null ? 'Host profile is ready to be activated.' : 'Level ${host.level}  |  ${host.earningsCoins} virtual coins', style: const TextStyle(color: muted))])),
            ])),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: _stat('Gifts received', '${statistics['gifts_received'] ?? 0} coins')), Expanded(child: _stat('Rooms hosted', '${statistics['rooms_hosted'] ?? 0}'))]),
            const SizedBox(height: 12),
            const Text('Recent host activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
            if (activity.isEmpty) const Text('No host activity yet.', style: TextStyle(color: muted)) else ...activity.take(5).map((item) => ListTile(dense: true, leading: const Icon(Icons.history, color: mint), title: Text(item['activity_type']?.toString() ?? 'Activity'), subtitle: Text(item['message']?.toString() ?? ''))),
            const SizedBox(height: 12),
            if (agency == null) Row(children: [Expanded(child: FilledButton.icon(onPressed: _createAgency, icon: const Icon(Icons.business), label: const Text('Create agency'))), const SizedBox(width: 8), IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgencyScreen())), icon: const Icon(Icons.search, color: mint))]) else Card(child: ListTile(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgencyScreen())), leading: const Icon(Icons.business, color: mint), title: Text(agency['name']?.toString() ?? 'Agency'), subtitle: Text('Status: ${agency['status'] ?? 'pending'}'))),
            const MenuTile('Host Dashboard', Icons.dashboard),
            const MenuTile('Earnings', Icons.insights),
            const MenuTile('Host Guidelines', Icons.menu_book),
          ]);
        },
      ),
    );
  }

  Widget _stat(String label, String value) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: mint)), Text(label, style: const TextStyle(color: muted, fontSize: 12))])));
}