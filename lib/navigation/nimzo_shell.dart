import 'package:flutter/material.dart';

import '../screens/discover/discover_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/rooms/rooms_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../theme/nimzo_theme.dart';
import '../widgets/nimzo_bottom_navigation.dart';

class NimzoShell extends StatefulWidget {
  const NimzoShell({super.key});

  @override
  State<NimzoShell> createState() => _NimzoShellState();
}

class _NimzoShellState extends State<NimzoShell> {
  int index = 0;

  static const pages = [HomeScreen(), RoomsScreen(), DiscoverScreen(), WalletScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: pages[index]),
        bottomNavigationBar: NimzoBottomNavigation(
          selectedIndex: index,
          onSelected: (value) => setState(() => index = value),
          indicatorColor: lightMint,
        ),
      );
}
