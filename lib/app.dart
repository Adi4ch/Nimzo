import 'package:flutter/material.dart';

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
      stream: auth.authStateChanges.map((state) => state.session?.user),
      initialData: auth.currentUser,
      builder: (context, snapshot) => snapshot.data == null ? const AuthScreen() : const NimzoShell(),
    );
  }
}
