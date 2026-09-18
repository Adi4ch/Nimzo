import 'package:flutter/material.dart';

void main() => runApp(const NimzoApp());

const mint = Color(0xFF12B878);
const lightMint = Color(0xFFE6FAF1);
const ink = Color(0xFF17332C);
const muted = Color(0xFF78918A);

class NimzoApp extends StatelessWidget {
  const NimzoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nimzo',
        theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: mint), scaffoldBackgroundColor: Colors.white),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}
class _ShellState extends State<Shell> {
  int index = 0;
  static const pages = [Home(), Rooms(), Discover(), Wallet(), Profile()];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: pages[index]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => setState(() => index = value),
          indicatorColor: lightMint,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.meeting_room_outlined), selectedIcon: Icon(Icons.meeting_room), label: 'Rooms'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
}

class Header extends StatelessWidget {
  final String title;
  final bool back;
  const Header(this.title, {super.key, this.back = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: Row(children: [
          if (back) IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: ink))),
          const Icon(Icons.search, color: ink), const SizedBox(width: 16), const Icon(Icons.notifications_none, color: ink),
        ]),
      );
}

class Avatar extends StatelessWidget {
  final IconData icon;
  const Avatar({super.key, this.icon = Icons.music_note});
  @override
  Widget build(BuildContext context) => Container(
        width: 58, height: 58,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFF0C5F48), Color(0xFF19C985)]), border: Border.all(color: mint, width: 2)),
        child: Icon(icon, color: Colors.white, size: 30),
      );
}

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) => ListView(children: [
        const Header('Nimzo'),
        Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(18), decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFFDFFBED), Color(0xFFF5FFFA)])), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome to Nimzo', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: ink)), SizedBox(height: 7), Text('Make new friends  |  Talk  |  Enjoy', style: TextStyle(color: muted))])),
        const Section('Featured Rooms'), const RoomGrid(['Chill Vibes', 'Music Zone', 'Friends Talk']),
        const Section('More Rooms'), const RoomGrid(['Ludo Lounge', 'Carrom Club', '8 Ball Pool', 'Study Circle']),
      ]);
}

class Section extends StatelessWidget {
  final String title;
  const Section(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 22, 20, 12), child: Row(children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ink)), const Spacer(), const Text('See All', style: TextStyle(color: mint, fontWeight: FontWeight.w700))]));
}

class RoomGrid extends StatelessWidget {
  final List<String> names;
  const RoomGrid(this.names, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(height: 125, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 20), scrollDirection: Axis.horizontal, itemCount: names.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => InkWell(
        borderRadius: BorderRadius.circular(18), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Room(name: names[i]))),
        child: Container(width: 105, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 12)]), child: Column(children: [Expanded(child: Avatar(icon: i.isEven ? Icons.people : Icons.music_note)), const SizedBox(height: 7), Text(names[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), const Text('1.2K', style: TextStyle(color: muted, fontSize: 11))])),
      )));
}

class Rooms extends StatefulWidget {
  const Rooms({super.key});
  @override
  State<Rooms> createState() => _RoomsState();
}
class _RoomsState extends State<Rooms> {
  int category = 0;
  final categories = const ['All', 'Popular', 'New', 'Music', 'Chat'];
  final rooms = const ['Chill Vibes', 'Music Room', 'Friendship Room', 'Gaming Zone', 'Love & Relationship', 'Study & Career'];
  @override
  Widget build(BuildContext context) => Column(children: [
        const Header('Rooms'),
        SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: category == i, selectedColor: mint, labelStyle: TextStyle(color: category == i ? Colors.white : ink, fontWeight: FontWeight.w700), onSelected: (_) => setState(() => category = i)))),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 20), itemCount: rooms.length, itemBuilder: (_, i) => ListTile(contentPadding: const EdgeInsets.symmetric(vertical: 7), leading: const Avatar(), title: Text(rooms[i], style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Sing  |  Dance  |  Enjoy  |  2.4K', style: TextStyle(color: muted)), trailing: FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Room(name: rooms[i]))), style: FilledButton.styleFrom(backgroundColor: mint), child: const Text('Join')))),
      ]);
}

class Room extends StatelessWidget {
  final String name;
  const Room({super.key, required this.name});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Column(children: [
        Header(name, back: true),
        Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFE4FAF0), Colors.white])), child: Column(children: [const Avatar(), const SizedBox(height: 10), Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)), const Text('Sing  |  Dance  |  Enjoy', style: TextStyle(color: muted))])),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18), child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _SeatRow(start: 0, active: true),
          _SeatRow(start: 5, active: false),
        ]))),
        Padding(padding: const EdgeInsets.only(right: 14, bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [RoomAction(Icons.card_giftcard, 'Gift', () => notice(context, 'Gift panel is ready for virtual coins.')), RoomAction(Icons.music_note, 'Music', () => notice(context, 'Music controls are coming soon.')), RoomAction(Icons.sports_esports, 'Game', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameHub())))])),
        Container(margin: const EdgeInsets.fromLTRB(16, 0, 16, 12), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), decoration: BoxDecoration(color: const Color(0xFFF4F8F6), borderRadius: BorderRadius.circular(28)), child: const Row(children: [Expanded(child: Text('Say something...', style: TextStyle(color: muted))), Icon(Icons.emoji_emotions_outlined, color: muted), SizedBox(width: 14), Icon(Icons.send, color: mint)])),
      ])));
}

class RoomAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const RoomAction(this.icon, this.label, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(left: 10), child: Column(children: [FloatingActionButton.small(heroTag: label, onPressed: onTap, backgroundColor: Colors.white, child: Icon(icon, color: mint)), Text(label, style: const TextStyle(fontSize: 10, color: muted))]));
}

class _SeatRow extends StatelessWidget {
  final int start;
  final bool active;
  const _SeatRow({required this.start, required this.active});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        for (var offset = 0; offset < 5; offset++)
          Column(children: [
            CircleAvatar(radius: 23, backgroundColor: active ? lightMint : const Color(0xFFF0F2F2), child: Icon(Icons.mic, color: active ? mint : Colors.grey)),
            const SizedBox(height: 5),
            Text(active ? 'Live' : '${start + offset + 1}', style: const TextStyle(fontSize: 11)),
          ]),
      ]);
}

class GameHub extends StatefulWidget {
  const GameHub({super.key});
  @override
  State<GameHub> createState() => _GameHubState();
}

class _GameHubState extends State<GameHub> {
  int category = 0;
  final categories = const ['All', 'Board', 'Classic'];
  final games = const ['Ludo', 'Carrom', '8'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Game List')), body: ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Pick a game', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 8),
      const Text('Play with room friends using demo coins.', style: TextStyle(color: muted)),
      const SizedBox(height: 20),
      Wrap(spacing: 8, children: [for (var i = 0; i < categories.length; i++) ChoiceChip(label: Text(categories[i]), selected: category == i, selectedColor: mint, labelStyle: TextStyle(color: category == i ? Colors.white : ink, fontWeight: FontWeight.w700), onSelected: (_) => setState(() => category = i))]),
      const SizedBox(height: 12),
      ...games.map((game) => Card(elevation: 0, color: lightMint, child: ListTile(leading: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.sports_esports, color: mint)), title: Text(game, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Play now  |  Demo coins'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GameDetail(name: game))))),
    ]));
  }
}
class GameDetail extends StatelessWidget {
  final String name;
  const GameDetail({super.key, required this.name});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(name)), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.sports_esports, size: 90, color: mint), const SizedBox(height: 18), Text('$name table', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 8), const Text('Game placeholder ready for integration', style: TextStyle(color: muted)), const SizedBox(height: 24), FilledButton.icon(onPressed: () => notice(context, 'Demo game started.'), icon: const Icon(Icons.play_arrow), label: const Text('Start demo'))])));
}

class Discover extends StatefulWidget {
  const Discover({super.key});
  @override
  State<Discover> createState() => _DiscoverState();
}
class _DiscoverState extends State<Discover> {
  final liked = <int>{}; final followed = <int>{};
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
        const Header('Discover'),
        Row(children: ['For You', 'Following', 'Videos'].asMap().entries.map((e) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: e.key == 0 ? mint : lightMint, borderRadius: BorderRadius.circular(18)), child: Center(child: Text(e.value, style: TextStyle(color: e.key == 0 ? Colors.white : ink, fontWeight: FontWeight.w700))))))).toList()),
        const SizedBox(height: 18),
        post(0, 'Life is better when you smile'), post(1, 'Good vibes only'),
      ]);
  Widget post(int id, String text) => Card(elevation: 0, margin: const EdgeInsets.only(bottom: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const CircleAvatar(backgroundColor: lightMint, child: Icon(Icons.person, color: mint)), const SizedBox(width: 10), const Text('Nimzo User', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: () => setState(() => followed.contains(id) ? followed.remove(id) : followed.add(id)), child: Text(followed.contains(id) ? 'Following' : 'Follow'))]), const SizedBox(height: 12), Text(text), const SizedBox(height: 12), Container(height: 170, decoration: BoxDecoration(color: lightMint, borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.image_outlined, size: 48, color: mint))), const SizedBox(height: 10), Row(children: [IconButton(onPressed: () => setState(() => liked.contains(id) ? liked.remove(id) : liked.add(id)), icon: Icon(liked.contains(id) ? Icons.favorite : Icons.favorite_border, color: liked.contains(id) ? Colors.red : ink)), const Text('342'), IconButton(onPressed: () => notice(context, 'Comments are ready for the social feed.'), icon: const Icon(Icons.chat_bubble_outline)), const Text('56'), const Spacer(), IconButton(onPressed: () => notice(context, 'Post link copied.'), icon: const Icon(Icons.share_outlined))])])));
}

class Wallet extends StatefulWidget {
  const Wallet({super.key});
  @override
  State<Wallet> createState() => _WalletState();
}
class _WalletState extends State<Wallet> {
  int balance = 12450;
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [const Header('Wallet'), Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(colors: [Color(0xFFDDF8EA), Color(0xFFF6FFFA)])), child: Row(children: [const Icon(Icons.monetization_on, color: Color(0xFFFFB800), size: 42), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Balance', style: TextStyle(color: muted)), Text('$balance', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: ink))])), FilledButton(onPressed: () => recharge(context), child: const Text('Recharge'))])), const Section('Recent Transactions'), for (final item in const ['Recharge  +1,000 Coins', 'Game Win  +250 Coins', 'Room Gift  +500 Coins', 'Withdraw  -3,000 Coins']) ListTile(leading: const CircleAvatar(backgroundColor: lightMint, child: Icon(Icons.receipt_long, color: mint)), title: Text(item, style: const TextStyle(fontWeight: FontWeight.w700))) ]);
  void recharge(BuildContext context) => showModalBottomSheet<void>(context: context, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Recharge demo coins', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)), const SizedBox(height: 14), Wrap(spacing: 10, children: [for (final amount in [500, 1000, 2500]) OutlinedButton(onPressed: () { setState(() => balance += amount); Navigator.pop(context); }, child: Text('+$amount'))]), const SizedBox(height: 8), const Text('Payments are not connected. These are virtual coins.', style: TextStyle(color: muted))]))));
}

class Profile extends StatelessWidget {
  const Profile({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [const Header('Profile'), const Row(children: [CircleAvatar(radius: 42, backgroundColor: lightMint, child: Icon(Icons.person, size: 45, color: mint)), SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nimzo User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)), Text('ID: 12345678', style: TextStyle(color: muted)), SizedBox(height: 8), Text('Lv.5', style: TextStyle(color: mint, fontWeight: FontWeight.w800))])]), const SizedBox(height: 18), const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Stat('256', 'Friends'), Stat('4.2K', 'Followers'), Stat('1.8K', 'Following')]), const SizedBox(height: 22), Menu('Host Center', Icons.workspace_premium, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostCenter()))), const Menu('My Wallet', Icons.account_balance_wallet), const Menu('Settings', Icons.settings), const Menu('Help & Support', Icons.help_outline), const Menu('About Nimzo', Icons.info_outline)]);
}
class HostCenter extends StatelessWidget {
  const HostCenter({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Host Center')), body: ListView(padding: const EdgeInsets.all(20), children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: lightMint, borderRadius: BorderRadius.circular(22)), child: const Row(children: [Icon(Icons.workspace_premium, color: mint, size: 42), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Build your room community', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: ink)), SizedBox(height: 5), Text('Track hosting and agency activity.', style: TextStyle(color: muted))]))])), const SizedBox(height: 20), const Menu('Host Dashboard', Icons.dashboard), const Menu('Agency Center', Icons.business), const Menu('Earnings', Icons.insights), const Menu('Host Guidelines', Icons.menu_book)]));
}
class Stat extends StatelessWidget { final String amount, label; const Stat(this.amount, this.label, {super.key}); @override Widget build(BuildContext context) => Column(children: [Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)), Text(label, style: const TextStyle(color: muted, fontSize: 12))]); }
class Menu extends StatelessWidget { final String title; final IconData icon; final VoidCallback? onTap; const Menu(this.title, this.icon, {super.key, this.onTap}); @override Widget build(BuildContext context) => ListTile(onTap: onTap, contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: lightMint, child: Icon(icon, color: mint)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: const Icon(Icons.chevron_right, color: muted)); }
void notice(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
