import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_bootstrap.dart';
import 'navigation/nimzo_shell.dart';
import 'repositories/repository_factory.dart';
import 'screens/auth/auth_screen.dart';
import 'theme/nimzo_theme.dart';

class NimzoApp extends StatelessWidget {
  const NimzoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nimzo',
        theme: buildNimzoTheme(),
        home: const AuthGate(),
      );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!RepositoryFactory.usesSupabase) return const NimzoShell();
    final auth = RepositoryFactory.auth();
    return StreamBuilder(
      stream: auth.authStateChanges,
      initialData: AuthState(AuthChangeEvent.initialSession, SupabaseBootstrap.client?.auth.currentSession),
      builder: (context, snapshot) {
        final user = snapshot.data?.session?.user;
        if (snapshot.connectionState == ConnectionState.waiting) return const _StartupState();
        if (user == null) return const AuthScreen();
        return FutureBuilder(
          future: RepositoryFactory.users().ensureCurrentUser(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) return const _StartupState();
            if (profileSnapshot.hasError || profileSnapshot.data == null) {
              return const _StartupError();
            }
            return const NimzoShell();
          },
        );
      },
    );
  }
}

class _StartupState extends StatelessWidget {
  const _StartupState();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, size: 54, color: Color(0xFF79D9B0)),
          SizedBox(height: 16),
          CircularProgressIndicator(color: Color(0xFF79D9B0)),
          SizedBox(height: 12),
          Text('Loading Nimzo...'),
        ])),
      );
}

class _StartupError extends StatelessWidget {
  const _StartupError();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Nimzo could not load your profile.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: () => (context as Element).markNeedsBuild(), child: const Text('Retry')),
        ])),
      );
}
