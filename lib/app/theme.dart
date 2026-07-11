import 'package:flutter/material.dart';

/// MakanKira theme — a warm Malaysian-food orange seed, Material 3.
/// Pass [brightness] to build the matching light or dark variant.
ThemeData buildTheme([Brightness brightness = Brightness.light]) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFFEA6A12),
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    appBarTheme: const AppBarTheme(centerTitle: false),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}
