import 'package:flutter/material.dart';

import 'navigation/nimzo_shell.dart';
import 'theme/nimzo_theme.dart';

class NimzoApp extends StatelessWidget {
  const NimzoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nimzo',
        theme: buildNimzoTheme(),
        home: const NimzoShell(),
      );
}
