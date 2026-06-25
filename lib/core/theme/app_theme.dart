// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

/// Supported custom theme styles for the Church Gear SaaS ecosystem.
enum AppThemeMode { cathedral, oliveGrove, royalPurple, charcoal, midnight }

/// A centralized, reusable design system configuration that manages
/// our 10 distinct look-and-feel states across the platform.
class AppTheme {
  // Private constructor to prevent direct instantiation
  AppTheme._();

  /// Primary factory method to retrieve any of our 10 thematic variations.
  /// It pairs one of our 5 core styles with a matching Light or Dark mode profile.
  static ThemeData getTheme(AppThemeMode mode, {required bool isDarkMode}) {
    switch (mode) {
      case AppThemeMode.oliveGrove:
        return _buildTheme(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          primary: const Color(0xFF2F855A), // Forest Green
          secondary: const Color(0xFFC69214), // Muted Gold Accent
          background: isDarkMode
              ? const Color(0xFF1A231E)
              : const Color(0xFFF4F7F5),
          surface: isDarkMode ? const Color(0xFF243029) : Colors.white,
        );

      case AppThemeMode.royalPurple:
        return _buildTheme(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          primary: const Color(0xFF553C9A), // Deep Majestic Purple
          secondary: const Color(0xFFED64A6), // Soft Rose Pink
          background: isDarkMode
              ? const Color(0xFF171224)
              : const Color(0xFFFAF5FF),
          surface: isDarkMode ? const Color(0xFF231B34) : Colors.white,
        );

      case AppThemeMode.charcoal:
        return _buildTheme(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          primary: const Color(0xFF4A5568), // Crisp Slate Gray
          secondary: const Color(0xFFED8936), // Warm Accent Orange
          background: isDarkMode
              ? const Color(0xFF1A202C)
              : const Color(0xFFEDF2F7),
          surface: isDarkMode ? const Color(0xFF2D3748) : Colors.white,
        );

      case AppThemeMode.midnight:
        return _buildTheme(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          primary: isDarkMode ? Colors.white : Colors.black,
          secondary: const Color(0xFF718096),
          background: isDarkMode ? Colors.black : const Color(0xFFF7FAFC),
          surface: isDarkMode ? const Color(0xFF121212) : Colors.white,
        );

      case AppThemeMode.cathedral:
        return _buildTheme(
          brightness: isDarkMode ? Brightness.dark : Brightness.light,
          primary: const Color(0xFF1A365D), // Deep Cathedral Navy
          secondary: const Color(0xFFD69E2E), // Polished Gold Accent
          background: isDarkMode
              ? const Color(0xFF141A24)
              : const Color(0xFFF7FAFC),
          surface: isDarkMode ? const Color(0xFF1E2633) : Colors.white,
        );
    }
  }

  /// Private helper component to build a standard, accessible Material 3 template.
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
    );
  }
}
