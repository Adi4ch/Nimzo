import 'package:flutter/material.dart';

import '../../repositories/repository_factory.dart';
import '../../theme/nimzo_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final displayName = TextEditingController();
  bool signup = false;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    displayName.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() { busy = true; error = null; });
    try {
      final auth = RepositoryFactory.auth();
      if (signup) {
        await auth.signUp(email: email.text.trim(), password: password.text, displayName: displayName.text.trim());
      } else {
        await auth.signIn(email: email.text.trim(), password: password.text);
      }
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString().replaceFirst('AuthException: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetPassword() async {
    if (email.text.trim().isEmpty) { setState(() => error = 'Email enter karein.'); return; }
    try {
      await RepositoryFactory.auth().resetPassword(email.text.trim());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
    } catch (exception) {
      if (mounted) setState(() => error = exception.toString().replaceFirst('AuthException: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Icon(Icons.mic, size: 62, color: mint),
            const SizedBox(height: 14),
            const Text('Welcome to Nimzo', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: ink)),
            const SizedBox(height: 28),
            if (signup) TextField(controller: displayName, decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.person_outline))),
            if (signup) const SizedBox(height: 12),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 12),
            TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
            if (error != null) Padding(padding: const EdgeInsets.only(top: 14), child: Text(error!, style: const TextStyle(color: Colors.red))),
            const SizedBox(height: 20),
            FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(backgroundColor: mint, padding: const EdgeInsets.symmetric(vertical: 15)), child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(signup ? 'Create account' : 'Login')),
            if (!signup) TextButton(onPressed: busy ? null : resetPassword, child: const Text('Forgot password?')),
            TextButton(onPressed: busy ? null : () => setState(() { signup = !signup; error = null; }), child: Text(signup ? 'Already have an account? Login' : 'Create a new account')),
          ]),
        )))),
      );
}