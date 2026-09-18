import 'package:flutter/material.dart';

const mint = Color(0xFF12B878);
const lightMint = Color(0xFFE6FAF1);
const ink = Color(0xFF17332C);
const muted = Color(0xFF78918A);
const nimzoPagePadding = EdgeInsets.all(20);
const nimzoCardRadius = 20.0;

ThemeData buildNimzoTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: mint),
      scaffoldBackgroundColor: Colors.white,
      cardTheme: CardTheme(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(nimzoCardRadius)),
      ),
      navigationBarTheme: const NavigationBarThemeData(height: 70),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: ink),
        bodyMedium: TextStyle(color: ink),
      ),
    );
