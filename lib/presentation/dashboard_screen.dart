// lib/presentation/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/theme/app_theme.dart';
import '../logic/theme_bloc/theme_bloc.dart';
import '../logic/auth_bloc/auth_bloc.dart';
import '../data/models/user_session.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      app_board: AppBar(
        title: const Text('Church Gear Command Center'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Security Session Visualizer Card
            _buildSessionCard(context),
            const SizedBox(height: 20),

            // Section 2: Mock Authentication Terminal Switches
            _buildAuthTerminal(context),
            const SizedBox(height: 20),

            // Section 3: The 10-Theme Dynamic Matrix Pilot Grid
            _buildThemePilot(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final session = state.session;
        final colorScheme = Theme.of(context).colorScheme;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      session.isAuthenticated
                          ? Icons.verified_user
                          : Icons.gpp_maybe,
                      color: session.isAuthenticated
                          ? Colors.green
                          : colorScheme.error,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      session.isAuthenticated
                          ? 'Authenticated Session'
                          : 'Guest / Restricted Mode',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'User ID: ${session.userId}',
                  style: const TextStyle(fontFamily: 'Courier'),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tenant Domain: ${session.tenantId}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Access Privilege Level: ${session.userRole.name.toUpperCase()}',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthTerminal(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Auth Simulator',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final adminSession = UserSession(
                      userId: 'admin_usr_77',
                      tenantId: 'cathedral_hq',
                      userRole: UserRole.admin,
                      jwtToken: 'mock_jwt_admin_token',
                    );
                    context.read<AuthBloc>().add(
                      LoginSuccessEvent(adminSession),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('As Admin'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final memberSession = UserSession(
                      userId: 'member_usr_243',
                      tenantId: 'olive_grove_branch',
                      userRole: UserRole.member,
                      jwtToken: 'mock_jwt_member_token',
                    );
                    context.read<AuthBloc>().add(
                      LoginSuccessEvent(memberSession),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('As Member'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                context.read<AuthBloc>().add(const LogoutRequestedEvent());
              },
              icon: const Icon(Icons.logout),
              label: const Text('Terminate Session (Clear Cache)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePilot(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Theme Matrix Selector',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.light_mode, size: 18),
                        Switch(
                          value: state.isDarkMode,
                          onChanged: (val) {
                            context.read<ThemeBloc>().add(
                              ChangeThemeEvent(
                                themeMode: state.themeMode,
                                isDarkMode: val,
                              ),
                            );
                          },
                        ),
                        const Icon(Icons.dark_mode, size: 18),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: AppThemeMode.values.length,
                  itemBuilder: (context, index) {
                    final mode = AppThemeMode.values[index];
                    final isSelected = state.themeMode == mode;

                    return RadioListTile<AppThemeMode>(
                      title: Text(
                        mode.name.replaceAll('G', ' G').toUpperCase(),
                      ),
                      value: mode,
                      groupValue: state.themeMode,
                      selected: isSelected,
                      onChanged: (newMode) {
                        if (newMode != null) {
                          context.read<ThemeBloc>().add(
                            ChangeThemeEvent(
                              themeMode: newMode,
                              isDarkMode: state.isDarkMode,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
