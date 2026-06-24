// lib/presentation/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc/auth_bloc.dart';
import '../logic/theme_bloc/theme_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentSession = context.watch<AuthBloc>().state.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Gear Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('User ID: ${currentSession.userId}'),
                      const SizedBox(height: 4),
                      Text('Assigned Tenant: ${currentSession.tenantId}'),
                      const SizedBox(height: 4),
                      Text(
                        'Role Level: ${currentSession.userRole.name.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('System Theme Engine Configuration'),
              const SizedBox(height: 8),
              // Unified theme toggles
              BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return SwitchListTile(
                    title: const Text('Dark Mode Intensity'),
                    value: themeState.isDarkMode,
                    onChanged: (value) {
                      // 💡 FIXED: Dispatches your exact, existing theme adjustment event contract
                      context.read<ThemeBloc>().add(
                            ChangeThemeEvent(
                              themeMode: themeState.themeMode,
                              isDarkMode: value,
                            ),
                          );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}