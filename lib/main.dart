// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'logic/theme_bloc/theme_bloc.dart';

void main() {
  runApp(const ChurchGearApp());
}

/// The absolute root entry container for the Church Gear multi-tenant platform.
class ChurchGearApp extends StatelessWidget {
  const ChurchGearApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecting the ThemeBloc right at the top of the widget tree 
    // so every sub-screen can listen to it.
    return BlocProvider(
      create: (context) => ThemeBloc(),
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
          // Dynamically pulling the correct palette from our AppTheme matrix
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