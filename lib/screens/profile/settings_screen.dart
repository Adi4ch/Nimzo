import 'package:flutter/material.dart';

import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  String language = 'en';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await RepositoryFactory.platform().getSettings();
    if (!mounted) return;
    setState(() {
      notifications = settings['notifications_enabled'] != false;
      language = settings['language']?.toString() ?? 'en';
      loading = false;
    });
  }

  Future<void> _save() async {
    await RepositoryFactory.platform().updateSettings(
        language: language, notificationsEnabled: notifications);
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: mint))
            : ListView(padding: nimzoPagePadding, children: [
                const Text('Account',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Account & profile'),
                    subtitle: const Text('Your public Nimzo identity'),
                    onTap: () => _showInfo(context,
                        'Edit your display name and bio from Profile.')),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Security'),
                    subtitle: const Text('Sign-in and account protection'),
                    onTap: () => _showInfo(context,
                        'Your sign-in is managed by the configured authentication provider.')),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Delete account',
                        style: TextStyle(color: Colors.red)),
                    subtitle:
                        const Text('Permanently remove your Nimzo account'),
                    onTap: _confirmDeleteAccount),
                const Divider(height: 28),
                const Text('Preferences',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
                SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notifications'),
                    subtitle: const Text('Room, gift and social updates'),
                    value: notifications,
                    onChanged: (value) =>
                        setState(() => notifications = value)),
                DropdownButtonFormField<String>(
                    value: language,
                    decoration: const InputDecoration(labelText: 'Language'),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                      DropdownMenuItem(value: 'bn', child: Text('Bengali'))
                    ],
                    onChanged: (value) => setState(() => language = value!)),
                const Divider(height: 28),
                const Text('Privacy & support',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.block_outlined),
                    title: const Text('Blocked users'),
                    onTap: _showBlockedUsers),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy policy'),
                    onTap: () => _showInfo(context, 'Nimzo privacy policy')),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Terms of service'),
                    onTap: () => _showInfo(context, 'Nimzo terms of service')),
                ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About Nimzo'),
                    onTap: () =>
                        _showInfo(context, 'Nimzo social rooms and community')),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: _save, child: const Text('Save changes')),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout')),
              ]),
      );

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Log out of Nimzo?'),
                content: const Text('You can sign back in any time.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'))
                ]));
    if (confirmed == true && mounted) await RepositoryFactory.auth().signOut();
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Delete account?'),
                content: const Text(
                    'This permanently removes your profile, posts and wallet history.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'))
                ]));
    if (confirmed != true || !mounted) return;
    try {
      await RepositoryFactory.auth().deleteAccount();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (exception) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(exception.toString())));
    }
  }

  void _showInfo(BuildContext context, String message) => showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
              title: const Text('Nimzo'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ]));

  Future<void> _showBlockedUsers() async {
    final social = RepositoryFactory.social();
    final blocked = await social.getBlockedUsers();
    if (!mounted) return;
    showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(
                child: ListView(padding: nimzoPagePadding, children: [
              const Text('Blocked users',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              if (blocked.isEmpty)
                const Text('No blocked users.')
              else
                ...blocked.map((id) => ListTile(
                    title: Text(id),
                    trailing: TextButton(
                        onPressed: () async {
                          await social.unblockUser(id);
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Unblock'))))
            ])));
  }
}
