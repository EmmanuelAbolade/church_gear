// lib/logic/theme_bloc/theme_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';

// ============================================================================
// 1. THEME BLOC EVENTS (Inputs)
// ============================================================================

/// Base definition for all incoming user theme events.
abstract class ThemeEvent {
  const ThemeEvent();
}

/// Dispatched when a tenant user manually changes their layout configuration style.
class ChangeThemeEvent extends ThemeEvent {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const ChangeThemeEvent({
    required this.themeMode,
    required this.isDarkMode,
  });
}

// ============================================================================
// 2. THEME BLOC STATES (Outputs)
// ============================================================================

/// Represents the current absolute aesthetic configuration state of Church Gear.
class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({
    required this.themeMode,
    required this.isDarkMode,
  });

  /// Factory constructor defining our standard configuration parameters.
  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: AppThemeMode.cathedral,
      isDarkMode: false,
    );
  }
}

// ============================================================================
// 3. THEME BLOC HUB (The Engine Brain)
// ============================================================================

/// Coordinates incoming aesthetic adjustments and outputs updated layout properties.
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState.initial()) {
    
    // Register our event handler method
    on<ChangeThemeEvent>((event, emit) {
      // Stream out the freshly updated user preference configuration states
      emit(ThemeState(
        themeMode: event.themeMode,
        isDarkMode: event.isDarkMode,
      ));
    });
  }
}