// test/theme_engine_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ THIS LINE WILL SHOW A RED ERROR: The file doesn't exist yet!
import 'package:church_gear/core/theme/app_theme.dart';

void main() {
  // Group opens a collection of related tests for our styling engine
  group('Church Gear Theme Engine Tests', () {
    test('Default theme selection should return Cathedral configuration', () {
      // 1. Arrange: Define what we expect
      const expectedMode = AppThemeMode.cathedral;

      // 2. Act: Try to fetch the configuration data
      final themeData = AppTheme.getTheme(expectedMode, isDarkMode: false);

      // 3. Assert: Verify the data matches our system specifications
      expect(themeData.brightness, equals(Brightness.light));
      expect(themeData.useMaterial3, isTrue);
    });

    test(
      'Midnight mode should explicitly enforce dark brightness parameters',
      () {
        // Act: Fetch our high-efficiency dark profile
        final themeData = AppTheme.getTheme(
          AppThemeMode.midnight,
          isDarkMode: true,
        );

        // Assert: Verify it locks down deep dark mode features
        expect(themeData.brightness, equals(Brightness.dark));
        expect(themeData.scaffoldBackgroundColor, equals(Colors.black));
      },
    );
  });
}
