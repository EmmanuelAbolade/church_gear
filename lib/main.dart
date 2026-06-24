// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'logic/theme_bloc/theme_bloc.dart';
import 'logic/auth_bloc/auth_bloc.dart';
import 'presentation/dashboard_screen.dart';
import 'presentation/auth_screen.dart';

void main() async {
  // 1. Ensure Flutter widget bindings are fully initialized before handling async startup routines
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the protected environment config parameters from memory assets
  await dotenv.load(fileName: '.env');

  // 3. Initialize the cloud engine securely using our environment abstractions
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

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
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Church Gear',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(themeState.themeMode, isDarkMode: themeState.isDarkMode),
          // Dynamically streams view states based on active cloud session verification status
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, AuthState authState) { // Explicit type annotation added
              if (authState.status == AuthStatus.authenticated) {
                return const DashboardScreen();
              }
              return const AuthScreen(); // Default fallback gateway
            },
          ),
        );
      },
    );
  }
}
