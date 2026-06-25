// lib/presentation/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc/auth_bloc.dart';
import '../logic/theme_bloc/theme_bloc.dart';
import '../data/models/sermon_media_item.dart';
import './media_cathedral_view.dart';
import './media_metropolitan_view.dart';
import '../core/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentSession = context.watch<AuthBloc>().state.session;
    final isGuest = currentSession.userRole.name.toLowerCase() == 'guest';

    // 1. Define dataset mimicking an active multi-tenant Supabase record stream
    final dummySermons = [
      const SermonMediaItem(
        id: '1',
        tenantId: 'global_shared',
        title: 'The Blueprint of Honor',
        speaker: 'Pastor Timothy Vance',
        mediaUrl: '',
        thumbnailUrl: '',
        category: 'Leadership',
      ),
      const SermonMediaItem(
        id: '2',
        tenantId: 'global_shared',
        title: 'Deep Waters of Faith',
        speaker: 'Evangelist Sarah Jenkins',
        mediaUrl: '',
        thumbnailUrl: '',
        category: 'Faith',
      ),
    ];

    // 2. Read the current premium/standard layout profile matrix out of the ThemeBloc state
    final activeThemeMode = context.watch<ThemeBloc>().state.themeMode;

    // 3. Dynamic screens array representing our 4 core modules
    final List<Widget> screens = [
      // 💡 Module 1: Swaps presentation layouts dynamically based on church tier!
      activeThemeMode == AppThemeMode.cathedral
          ? MediaCathedralView(sermons: dummySermons)
          : MediaMetropolitanView(sermons: dummySermons),
      
      // Module 2: Community & Connection View Placeholder
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt_outlined, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text('Community Directory', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(isGuest ? 'Sign in to access interactive member directories' : 'Connected to Small Groups'),
          ],
        ),
      ),

      // Module 3: Operations & Engagement View Placeholder
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text('Giving & Operations Portal', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),

      // Module 4: Settings & Configuration Hub
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined, size: 64, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('User Identity ID: ${currentSession.userId}'),
                    const SizedBox(height: 4),
                    Text('Active Workspace Tenant: ${currentSession.tenantId}'),
                    const SizedBox(height: 4),
                    Text(
                      'Access Scope: ${currentSession.userRole.name.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return SwitchListTile(
                  title: const Text('Dark Mode Intensity'),
                  value: themeState.isDarkMode,
                  onChanged: (value) {
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(isGuest ? 'Church Gear (Guest Mode)' : 'Church Gear Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
            },
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Media',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diversity_3),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Giving',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}