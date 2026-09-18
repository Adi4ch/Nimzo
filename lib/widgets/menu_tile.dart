import 'package:flutter/material.dart';

import '../theme/nimzo_theme.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const MenuTile(this.title, this.icon, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(onTap: onTap, contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: lightMint, child: Icon(icon, color: mint)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: const Icon(Icons.chevron_right, color: muted));
}
