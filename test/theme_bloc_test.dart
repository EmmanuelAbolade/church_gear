// test/theme_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
// ⚠️ THESE IMPORTS WILL SHOW RED ERRORS: The logic files do not exist yet!
import 'package:church_gear/logic/theme_bloc/theme_bloc.dart';
import 'package:church_gear/core/theme/app_theme.dart';

void main() {
  group('ThemeBloc State Management Tests', () {
    // Test 1: Verifies the initialization default state
    test(
      'Initial state of ThemeBloc should be default Cathedral light mode',
      () {
        final themeBloc = ThemeBloc();

        // Assert: Verify that out of the box, it defaults to Cathedral light
        expect(themeBloc.state.themeMode, equals(AppThemeMode.cathedral));
        expect(themeBloc.state.isDarkMode, isFalse);

        themeBloc.close(); // Clean up memory resource
      },
    );

    // Test 2: Verifies that changing the theme emits the correct subsequent state
    blocTest<ThemeBloc, ThemeState>(
      'Emits updated ThemeState color profiles when ChangeThemeEvent is added',
      build: () => ThemeBloc(),
      act: (bloc) => bloc.add(
        const ChangeThemeEvent(
          themeMode: AppThemeMode.oliveGrove,
          isDarkMode: true,
        ),
      ),
      expect: () => [
        predicate<ThemeState>((state) {
          return state.themeMode == AppThemeMode.oliveGrove &&
              state.isDarkMode == true;
        }),
      ],
    );
  });
}
