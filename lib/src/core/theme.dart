import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appThemeProvider = Provider<AppTheme>((ref) {
  return AppTheme();
});

class AppTheme {
  ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1865F2),
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(centerTitle: false),
      );

  ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1865F2),
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(centerTitle: false),
      );

  ThemeMode get mode => ThemeMode.system;
}
