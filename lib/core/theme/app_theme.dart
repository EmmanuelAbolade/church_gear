// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

enum AppThemeMode {
  cathedral,       // Classic / Traditional Blue
  metropolitan,    // Modern Deep Navy
  oliveGrove,      // Premium Organic Green
  goldenSpire,     // Vibrant Gold Accent
  ebonyGrace,      // Minimal Stark Black & Charcoal
  crimsonVine,     // Passionate Deep Wine Red
  royalBanner,     // Majestic Purple Heritage
  alpineCross,     // Clean Cool Slate Blue
  desertSpring,    // Warm Sand & Terracotta
  pacificWave      // Refreshing Bright Cyan & Teal
}

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode, {required bool isDarkMode}) {
    final ColorScheme scheme = _getColorScheme(mode, isDarkMode);
    
    // Factory constructor handles all widget backgrounds and card mappings automatically
    return ThemeData.from(
      colorScheme: scheme,
      useMaterial3: true,
    );
  }

  static ColorScheme _getColorScheme(AppThemeMode mode, bool isDarkMode) {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    
    switch (mode) {
      case AppThemeMode.cathedral:
        return ColorScheme.fromSeed(seedColor: Colors.blue, brightness: brightness);
      case AppThemeMode.metropolitan:
        return ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E), brightness: brightness);
      case AppThemeMode.oliveGrove:
        return ColorScheme.fromSeed(seedColor: Colors.green, brightness: brightness);
      case AppThemeMode.goldenSpire:
        return ColorScheme.fromSeed(seedColor: Colors.amber, brightness: brightness);
      case AppThemeMode.ebonyGrace:
        return ColorScheme.fromSeed(seedColor: Colors.grey, brightness: brightness);
      case AppThemeMode.crimsonVine:
        return ColorScheme.fromSeed(seedColor: Colors.redAccent, brightness: brightness);
      case AppThemeMode.royalBanner:
        return ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: brightness);
      case AppThemeMode.alpineCross:
        return ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: brightness);
      case AppThemeMode.desertSpring:
        return ColorScheme.fromSeed(seedColor: Colors.orange, brightness: brightness);
      case AppThemeMode.pacificWave:
        return ColorScheme.fromSeed(seedColor: Colors.teal, brightness: brightness);
    }
  }
}