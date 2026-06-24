// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'logic/theme_bloc/theme_bloc.dart';
import 'logic/auth_bloc/auth_bloc.dart';

void main() {
  runApp(const ChurchGearApp());
}

/// The absolute root entry container for the Church Gear multi-tenant platform.
class ChurchGearApp extends StatelessWidget {
  const ChurchGearApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiBlocProvider initializes both engines simultaneously at the root level
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
      ],
      child: const RootMaterialSelector(),
    );
  }
}

/// A wrapper widget that listens for ThemeState updates and reconstructs
/// the active Material design configuration parameters dynamically.
class RootMaterialSelector extends StatelessWidget {
  const RootMaterialSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Church Gear',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(state.themeMode, isDarkMode: state.isDarkMode),
          home: const Scaffold(
            body: Center(
              child: Text(
                'Welcome to Church Gear',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}