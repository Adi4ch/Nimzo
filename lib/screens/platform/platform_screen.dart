import 'package:flutter/material.dart';

import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class PlatformScreen extends StatelessWidget {
  const PlatformScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Nimzo Plus'),
            bottom: const TabBar(tabs: [
              Tab(text: 'VIP'),
              Tab(text: 'Mall'),
              Tab(text: 'Tasks'),
              Tab(text: 'Rankings')
            ]),
          ),
          body: const TabBarView(
              children: [VipTab(), MallTab(), TasksTab(), RankingsTab()]),
        ),
      );
}

class VipTab extends StatefulWidget {
  const VipTab({super.key});

  @override
  State<VipTab> createState() => _VipTabState();
}

class _VipTabState extends State<VipTab> {
  late Future<List<dynamic>> data;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => data = Future.wait([
        RepositoryFactory.platform().getCurrentVip(),
        RepositoryFactory.platform().getVipLevels()
      ]);

  Future<void> _purchase(Map<String, dynamic> level) async {
    try {
      await RepositoryFactory.platform().purchaseVip(level['id'].toString());
      if (!mounted) return;
      setState(_refresh);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('VIP upgraded successfully')));
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator(color: mint));
          if (snapshot.hasError)
            return _RetryState(
                message: 'VIP is temporarily unavailable.',
                onRetry: () => setState(_refresh));
          final current = snapshot.data![0] as Map<String, dynamic>?;
          final levels = snapshot.data![1] as List<Map<String, dynamic>>;
          final progress = (current?['progress'] as num?)?.toDouble() ?? 0;
          return ListView(padding: nimzoPagePadding, children: [
            _HeroPanel(
                icon: Icons.workspace_premium,
                title: 'VIP ${current?['name'] ?? 'Member'}',
                subtitle: current?['expires_at'] == null
                    ? 'Unlock more ways to stand out in Nimzo.'
                    : 'Active until ${current!['expires_at'].toString().split('T').first}',
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress to next level',
                                style: TextStyle(color: muted)),
                            Text('${(progress * 100).round()}%',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, color: mint))
                          ]),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                          value: progress,
                          minHeight: 9,
                          borderRadius: BorderRadius.circular(10),
                          color: mint,
                          backgroundColor: Colors.white),
                    ])),
            const SizedBox(height: 20),
            const Text('VIP levels',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 10),
            ...levels.map((level) => Card(
                child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: lightMint,
                        child: const Icon(Icons.verified, color: mint)),
                    title: Text('${level['name']}  ·  Level ${level['level']}',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(level['benefits'] is List
                        ? (level['benefits'] as List).join('  ·  ')
                        : level['benefits']?.toString() ?? 'VIP benefits'),
                    trailing: FilledButton(
                        onPressed: () => _purchase(level),
                        child: Text(
                            '${level['cost_coins'] ?? level['cost'] ?? 0}'))))),
          ]);
        },
      );
}

class MallTab extends StatefulWidget {
  const MallTab({super.key});

  @override
  State<MallTab> createState() => _MallTabState();
}

class _MallTabState extends State<MallTab> {
  String category = 'All';
  late Future<List<Map<String, dynamic>>> items;

  @override
  void initState() {
    super.initState();
    items = RepositoryFactory.platform().getMallItems();
  }

  Future<void> purchase(Map<String, dynamic> item) async {
    try {
      await RepositoryFactory.platform().purchaseMallItem(item['id'] as String);
      if (mounted)
        setState(() => items = RepositoryFactory.platform().getMallItems());
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item['name']} added to your inventory')));
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator(color: mint));
          if (snapshot.hasError)
            return _RetryState(
                message: 'The Mall is temporarily unavailable.',
                onRetry: () => setState(
                    () => items = RepositoryFactory.platform().getMallItems()));
          final allItems = snapshot.data ?? const <Map<String, dynamic>>[];
          final categories = [
            'All',
            ...allItems.map((item) => item['category'] as String).toSet()
          ];
          final visible = category == 'All'
              ? allItems
              : allItems.where((item) => item['category'] == category).toList();
          return ListView(padding: nimzoPagePadding, children: [
            const _SectionIntro(
                title: 'Make your space yours',
                subtitle:
                    'Frames, themes and effects purchased with virtual coins.'),
            SizedBox(
                height: 42,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) => ChoiceChip(
                        label: Text(categories[index]),
                        selected: category == categories[index],
                        onSelected: (_) =>
                            setState(() => category = categories[index])))),
            const SizedBox(height: 12),
            if (visible.isEmpty)
              const _EmptyState('Nothing in this category yet.')
            else
              ...visible.map((item) => Card(
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: lightMint,
                          child: Icon(_icon(item['icon'] as String?),
                              color: mint)),
                      title: Text(item['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle:
                          Text('${item['description']}\n${item['category']}'),
                      isThreeLine: true,
                      trailing: FilledButton(
                          onPressed: () => purchase(item),
                          child: Text('${item['price_coins']}'))))),
            const SizedBox(height: 16),
            OutlinedButton.icon(
                onPressed: () => _showInventory(context),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('View my inventory')),
          ]);
        },
      );

  Future<void> _showInventory(BuildContext context) async {
    var inventory = await RepositoryFactory.platform().getInventory();
    if (!context.mounted) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: ListView(
            padding: nimzoPagePadding,
            children: [
              const Text('My inventory',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (inventory.isEmpty)
                const _EmptyState('Your inventory is empty.')
              else
                ...inventory.map((item) {
                  final catalog = item['mall_items'] as Map<String, dynamic>?;
                  final itemId = item['id'].toString();
                  final name = item['name']?.toString() ??
                      catalog?['name']?.toString() ??
                      'Item';
                  final category = item['category']?.toString() ??
                      catalog?['category']?.toString() ??
                      '';
                  final equipped = item['equipped'] == true;
                  return ListTile(
                    leading: const Icon(Icons.check_circle, color: mint),
                    title: Text(name),
                    subtitle: Text(category),
                    trailing: TextButton(
                      onPressed: () async {
                        if (equipped) {
                          await RepositoryFactory.platform()
                              .unequipMallItem(itemId);
                        } else {
                          await RepositoryFactory.platform()
                              .equipMallItem(itemId);
                        }
                        inventory =
                            await RepositoryFactory.platform().getInventory();
                        setSheetState(() {});
                      },
                      child: Text(equipped ? 'Unequip' : 'Equip'),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  late Future<List<dynamic>> data;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => data = Future.wait([
        RepositoryFactory.platform().getDailyTasks(),
        RepositoryFactory.platform().getAchievements()
      ]);

  Future<void> _claim(String id, bool achievement) async {
    try {
      if (achievement) {
        await RepositoryFactory.platform().claimAchievement(id);
      } else {
        await RepositoryFactory.platform().claimDailyTask(id);
      }
      if (mounted) {
        setState(_refresh);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Reward claimed')));
      }
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<dynamic>>(
        future: data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator(color: mint));
          if (snapshot.hasError)
            return _RetryState(
                message: 'Tasks are temporarily unavailable.',
                onRetry: () => setState(_refresh));
          final tasks = snapshot.data![0] as List<Map<String, dynamic>>;
          final achievements = snapshot.data![1] as List<Map<String, dynamic>>;
          return ListView(padding: nimzoPagePadding, children: [
            const _SectionIntro(
                title: 'Today in Nimzo',
                subtitle:
                    'Small actions, steady progress. Tasks reset every day.'),
            ...tasks.map((task) => _ProgressTile(
                title: task['title'] as String,
                subtitle: task['description'] as String,
                progress: task['progress'] as int? ?? 0,
                target: task['target'] as int? ?? 1,
                reward: task['reward_coins'] as int? ?? 0,
                complete: task['claimed'] == true,
                claimable: task['progress'] >= (task['target'] ?? 1) &&
                    task['claimed'] != true,
                onClaim: () => _claim(task['id'].toString(), false))),
            const SizedBox(height: 20),
            const Text('Achievements',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 8),
            ...achievements.map((achievement) => _ProgressTile(
                title: achievement['title'] as String,
                subtitle: achievement['description'] as String,
                progress: achievement['progress'] as int? ?? 0,
                target: achievement['target'] as int? ?? 1,
                reward: achievement['reward_coins'] as int? ?? 0,
                complete: achievement['claimed'] == true,
                claimable: achievement['complete'] == true &&
                    achievement['claimed'] != true,
                onClaim: () => _claim(achievement['id'].toString(), true))),
          ]);
        },
      );
}

class RankingsTab extends StatefulWidget {
  const RankingsTab({super.key});

  @override
  State<RankingsTab> createState() => _RankingsTabState();
}

class _RankingsTabState extends State<RankingsTab> {
  String period = 'daily';
  String kind = 'users';

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<List<Map<String, dynamic>>>(
        future: RepositoryFactory.platform()
            .getRankings(period: period, kind: kind),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator(color: mint));
          final rows = snapshot.data ?? const <Map<String, dynamic>>[];
          return ListView(padding: nimzoPagePadding, children: [
            SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'daily', label: Text('Daily')),
                  ButtonSegment(value: 'weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'monthly', label: Text('Monthly')),
                  ButtonSegment(value: 'all', label: Text('All time'))
                ],
                selected: {
                  period
                },
                onSelectionChanged: (value) =>
                    setState(() => period = value.first)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
                value: kind,
                decoration: const InputDecoration(labelText: 'Ranking by'),
                items: const [
                  DropdownMenuItem(value: 'users', child: Text('Users')),
                  DropdownMenuItem(
                      value: 'gift_senders', child: Text('Gift senders')),
                  DropdownMenuItem(
                      value: 'gift_receivers', child: Text('Gift receivers')),
                  DropdownMenuItem(value: 'hosts', child: Text('Hosts')),
                  DropdownMenuItem(value: 'rooms', child: Text('Rooms'))
                ],
                onChanged: (value) => setState(() => kind = value!)),
            const SizedBox(height: 16),
            if (snapshot.hasError || rows.isEmpty)
              const _EmptyState('No rankings for this period yet.')
            else
              ...rows.map((row) => Card(
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: row['current'] == true
                              ? lightMint
                              : Colors.grey.shade100,
                          child: Text('${row['rank']}')),
                      title: Text(
                          row['name']?.toString() ??
                              row['subject_id']?.toString() ??
                              'Nimzo member',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      trailing: Text('${row['score']} pts',
                          style: const TextStyle(
                              color: mint, fontWeight: FontWeight.w800))))),
          ]);
        },
      );
}

class _ProgressTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int progress;
  final int target;
  final int reward;
  final bool complete;
  final bool claimable;
  final VoidCallback onClaim;

  const _ProgressTile(
      {required this.title,
      required this.subtitle,
      required this.progress,
      required this.target,
      required this.reward,
      required this.complete,
      required this.claimable,
      required this.onClaim});

  @override
  Widget build(BuildContext context) => Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w800))),
              Text('+$reward',
                  style: const TextStyle(
                      color: mint, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              if (claimable)
                TextButton(onPressed: onClaim, child: const Text('Claim'))
              else
                Icon(
                    complete
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: complete ? mint : muted)
            ]),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: muted)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
                value: target == 0 ? 0 : (progress / target).clamp(0, 1),
                color: mint,
                backgroundColor: lightMint),
            const SizedBox(height: 6),
            Text('$progress / $target',
                style: const TextStyle(color: muted, fontSize: 12))
          ])));
}

class _HeroPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _HeroPanel(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.child});

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: lightMint,
          borderRadius: BorderRadius.circular(nimzoCardRadius)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: mint, size: 34),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: ink)),
        Text(subtitle, style: const TextStyle(color: muted)),
        const SizedBox(height: 18),
        child
      ]));
}

class _SectionIntro extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionIntro({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w900, color: ink)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: muted))
      ]));
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState(this.message);

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(28),
      child: Center(
          child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted))));
}

class _RetryState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RetryState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: const TextStyle(color: muted)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'))
      ]));
}

IconData _icon(String? name) =>
    {
      'crop_square': Icons.crop_square,
      'park': Icons.park,
      'auto_awesome': Icons.auto_awesome,
      'chat_bubble': Icons.chat_bubble,
      'cloud': Icons.cloud
    }[name] ??
    Icons.auto_awesome;
