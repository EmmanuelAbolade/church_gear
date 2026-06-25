// lib/presentation/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../logic/auth_bloc/auth_bloc.dart';
import '../logic/theme_bloc/theme_bloc.dart';
import '../data/models/sermon_media_item.dart';
import './media_cathedral_view.dart';
import './media_metropolitan_view.dart';
import '../core/theme/app_theme.dart';
import '../data/models/church_member.dart';
import './community_directory_view.dart';
import '../data/repositories/sermon_repository.dart';
import '../data/repositories/member_repository.dart';

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

    // 1. Read the current premium/standard layout profile matrix out of the ThemeBloc state
    final activeThemeMode = context.watch<ThemeBloc>().state.themeMode;

    // 2. Read repository connection instances out of context providers
    final sermonRepo = RepositoryProvider.of<SermonRepository>(context);
    final memberRepo = RepositoryProvider.of<MemberRepository>(context);

    // 3. Dynamic screens array representing our 4 core modules tied to live database streams
    final List<Widget> screens = [
      // Module 1: Swaps presentation layouts dynamically and listens to live Supabase sermon updates!
      StreamBuilder<List<SermonMediaItem>>(
        stream: sermonRepo.streamSermons(tenantId: currentSession.tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final liveSermons = snapshot.data ?? [];
          return activeThemeMode == AppThemeMode.cathedral
              ? MediaCathedralView(sermons: liveSermons)
              : MediaMetropolitanView(sermons: liveSermons);
        },
      ),
      
      // Module 2: Listens to live multi-tenant member roster shifts from your Supabase backend grid!
      StreamBuilder<List<ChurchMember>>(
        stream: memberRepo.streamMembers(tenantId: currentSession.tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final liveMembers = snapshot.data ?? [];
          return CommunityDirectoryView(members: liveMembers);
        },
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

      // Module 4: Settings & Configuration Hub (10-Theme Customizer Engine)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'System Settings',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tenant Workspace: ${currentSession.tenantId}', style: const TextStyle(fontSize: 12)),
                          Text('Role Scope: ${currentSession.userRole.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, themeState) {
                        return IconButton(
                          icon: Icon(themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                          onPressed: () {
                            context.read<ThemeBloc>().add(ChangeThemeEvent(
                              themeMode: themeState.themeMode,
                              isDarkMode: !themeState.isDarkMode,
                            ));
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0),
              child: Text('Workspace Theme Presets', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
                  return ListView.builder(
                    itemCount: AppThemeMode.values.length,
                    itemBuilder: (context, index) {
                      final currentMode = AppThemeMode.values[index];
                      final isSelected = themeState.themeMode == currentMode;
                      
                      return Card(
                        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.getTheme(currentMode, isDarkMode: themeState.isDarkMode).colorScheme.primary,
                            radius: 12,
                          ),
                          title: Text(
                            currentMode.name.replaceAllMapped(RegExp(r'(^[a-z]|[A-Z])'), (match) => ' ${match.group(0)?.toUpperCase()}').trim(),
                            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                          onTap: () {
                            context.read<ThemeBloc>().add(ChangeThemeEvent(
                              themeMode: currentMode,
                              isDarkMode: themeState.isDarkMode,
                            ));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
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