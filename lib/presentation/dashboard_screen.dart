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
import 'package:church_gear/data/models/transaction_model.dart';
import 'package:church_gear/data/repositories/operations_repository.dart';
import 'package:church_gear/data/models/featured_update_model.dart';
import 'package:church_gear/data/repositories/home_repository.dart';
import './admin_control_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // 💡 Categorized Emoji Bank for Members to choose from
  final Map<String, List<String>> _emojiCategories = {
    'Worship & Faith': ['🙌', '🙏', '🛐', '🔥', '✨', '🕊️'],
    'Love & Community': ['❤️', '🤝', '😊', '💡', '🛡️', '👑'],
    'Celebration': ['🎉', '👏', '🥳', '🎺', '🌟', '💪'],
  };

  // Dynamic state repository tracking active counts on each card locally (Fallback only)
  final Map<String, Map<String, int>> _reactionCounters = {
    'verse': {'❤️': 24, '🙌': 18, '🙏': 32},
    'prayer': {'🙏': 41, '🔥': 28, '✨': 15},
    'theme': {'🔥': 45, '🎯': 29, '🙌': 51},
    'milestone': {'🎉': 62, '❤️': 41, '✨': 19},
  };

  /// Increments or registers an emoji reaction dynamically on local fallback items
  void _handleReaction(String cardId, String emoji) {
    setState(() {
      final currentCardMap = _reactionCounters[cardId] ?? {};
      currentCardMap[emoji] = (currentCardMap[emoji] ?? 0) + 1;
      _reactionCounters[cardId] = currentCardMap;
    });
  }

  String _getCurrencySymbol(String tenantId) {
    if (tenantId.contains('nigeria') || tenantId.contains('ng')) return '₦';
    if (tenantId.contains('usa') || tenantId.contains('global')) return '\$';
    if (tenantId.contains('uk')) return '£';
    return '€'; 
  }

  @override
  Widget build(BuildContext context) {
    final currentSession = context.watch<AuthBloc>().state.session;
    final isGuest = currentSession.userRole.name.toLowerCase() == 'guest';
    final activeThemeMode = context.watch<ThemeBloc>().state.themeMode;

    final sermonRepo = RepositoryProvider.of<SermonRepository>(context);
    final memberRepo = RepositoryProvider.of<MemberRepository>(context);
    
    final currencySymbol = _getCurrencySymbol(currentSession.tenantId);
    final displayMinistryName = currentSession.tenantId == 'global_shared' 
        ? 'Global Shared Ministry' 
        : currentSession.tenantId.replaceAll('_', ' ').toUpperCase();

    final List<Widget> screens = [
      // ==========================================
      // INDEX 0: HOME PORTAL HUB (WITH LIVE CLOUD STREAM)
      // ==========================================
      ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text(displayMinistryName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(20)),
                  child: Text(isGuest ? 'Guest Access Active' : 'Connected Member', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Quick Access Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.3,
            children: [
              _buildHomeActionCard(Icons.auto_stories, 'Holy Bible', () {}, isPremium: true),
              _buildHomeActionCard(Icons.forum_outlined, 'Sermon Q&A', () {}),
              _buildHomeActionCard(Icons.calendar_month_outlined, 'Ministry Events', () {}),
              _buildHomeActionCard(Icons.poll_outlined, 'Active Polls', () {}),
              _buildHomeActionCard(Icons.campaign_outlined, 'Announcements', () {}),
              _buildHomeActionCard(Icons.all_inbox_outlined, 'Suggestion Box', () {}),
              _buildHomeActionCard(Icons.handshake_outlined, 'Prayer Requests', () {}),
              _buildHomeActionCard(Icons.group_add_outlined, 'Get Involved', () {}),
            ],
          ),
          const SizedBox(height: 28),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Featured Updates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Routing to full historical Featured Feed archive...')),
                  );
                }, 
                child: const Text('See All', style: TextStyle(fontSize: 12))
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          SizedBox(
            height: 185,
            child: StreamBuilder<List<FeaturedUpdateItem>>(
              stream: HomeRepository().streamFeaturedUpdates(currentSession.tenantId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Sync Error: Ensure cloud database matching parameters are clean.', 
                        style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final liveUpdates = snapshot.data ?? [];
                
                // FALLBACK INTERFACE: Keeps displaying your local design cards if no rows are published in cloud yet
                if (liveUpdates.isEmpty) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFeaturedContentCard(
                        cardId: 'verse',
                        badgeText: 'VERSE OF THE DAY 📖',
                        titleText: '"The Lord is my strength and my shield; my heart trusts in him, and he helps me."',
                        subtitleText: 'Psalms 28:7 • Keep your armor firm today.',
                        currentReactions: _reactionCounters['verse'] ?? {},
                        isLiveCloudCard: false,
                      ),
                      _buildFeaturedContentCard(
                        cardId: 'prayer',
                        badgeText: 'DAILY DECLARATION 🙏',
                        titleText: 'I walk in divine speed and supernatural favor today. No delay shall stand in my gateway.',
                        subtitleText: 'Declare this out loud over your morning workspace layout.',
                        currentReactions: _reactionCounters['prayer'] ?? {},
                        isLiveCloudCard: false,
                      ),
                    ],
                  );
                }

                // DYNAMIC OUTPUT: Paints real rows down straight from your Supabase table in real time
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: liveUpdates.length,
                  itemBuilder: (context, index) {
                    final item = liveUpdates[index];
                    return _buildFeaturedContentCard(
                      cardId: item.id,
                      badgeText: item.badgeText,
                      titleText: item.titleText,
                      subtitleText: item.subtitleText,
                      currentReactions: item.reactions,
                      isLiveCloudCard: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // INDEX 1: MODULE 1 (SERMONS)
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
      
      // INDEX 2: MODULE 2 (COMMUNITY)
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

      // INDEX 3: MODULE 3 (GIVING)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Giving & Operations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ministry Collection Pool', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                        Text('$currencySymbol Synchronizing...', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Live Operational Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<TransactionRecord>>(
                stream: OperationsRepository().streamTransactions(currentSession.tenantId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Database Synchronization Pending:\nEnsure the "transactions" table is initialized in your Supabase Console.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                        ),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final transactions = snapshot.data ?? [];
                  if (transactions.isEmpty) {
                    return const Center(child: Text('No operational records found for this workspace.'));
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isCompleted = tx.status == TransactionStatus.completed;
                      final statusColor = isCompleted ? Colors.green : (tx.status == TransactionStatus.pending ? Colors.orange : Colors.red);
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: statusColor.withAlpha(30),
                            child: Icon(isCompleted ? Icons.arrow_upward : Icons.hourglass_empty, color: statusColor),
                          ),
                          title: Text(tx.contributorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${tx.category.name.toUpperCase()} • ${tx.timestamp.toLocal().toString().split('.')[0]}', style: const TextStyle(fontSize: 11)),
                          trailing: Text(
                            '$currencySymbol${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 14),
                          ),
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

      // INDEX 4: MORE HUB
      ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('More Options', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSettingsHeaderCard(context, displayMinistryName, currentSession.userRole.name.toUpperCase()),
          const SizedBox(height: 20),
          const Text('Ministry Engagement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Card(
            child: ListTile(
              leading: const Icon(Icons.group_add_outlined),
              title: const Text('Get Involved & Volunteer'),
              subtitle: const Text('Join departments, teams and groups'),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
          const Text('Interaction & Feedback Loops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.admin_panel_settings_outlined, color: Theme.of(context).colorScheme.error),
                  title: const Text('Launch Administrative Desk Panel'),
                  subtitle: const Text('Manage workspace content channels, drafts, and states'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminControlScreen(tenantId: currentSession.tenantId),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.swap_horizontal_circle_outlined, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Switch Ministry Workspace'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Appearance & Branding'),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildThemePickerBottomSheet(context),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_outlined), activeIcon: Icon(Icons.video_library), label: 'Media'),
          BottomNavigationBarItem(icon: Icon(Icons.diversity_3_outlined), activeIcon: Icon(Icons.diversity_3), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism_outlined), activeIcon: Icon(Icons.volunteer_activism), label: 'Giving'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_outlined), activeIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildHomeActionCard(IconData icon, String label, VoidCallback onTap, {bool isPremium = false}) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (isPremium)
                      Text('PREMIUM', style: TextStyle(fontSize: 9, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper template builder for interactive reaction content items with advanced picker hooks
  Widget _buildFeaturedContentCard({
    required String cardId,
    required String badgeText,
    required String titleText,
    required String subtitleText,
    required Map<String, int> currentReactions,
    bool isLiveCloudCard = false,
  }) {
    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 12.0, bottom: 4.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  titleText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(subtitleText, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              
              // Reaction Row containing counters and the Dynamic Category Selector Button (+)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...currentReactions.keys.map((emoji) {
                      final count = currentReactions[emoji] ?? 0;
                      if (count == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: InkWell(
                          onTap: () {
                            if (isLiveCloudCard) {
                              HomeRepository().incrementEmojiReaction(cardId, emoji, currentReactions);
                            } else {
                              _handleReaction(cardId, emoji);
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withAlpha(60), width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 3),
                                Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    // ➕ Dynamic Picker Button: Launches categorized grid overlay sheet
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                          builder: (context) => _buildCategorizedEmojiSheet(cardId, currentReactions, isLiveCloudCard),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 11, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 2),
                            Text('React', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a beautifully organized, categorized layout pane sheet for multi-emoji choices
  Widget _buildCategorizedEmojiSheet(String cardId, Map<String, int> currentReactions, bool isLiveCloudCard) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 380,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Expression Reaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: _emojiCategories.keys.map((categoryName) {
                final emojis = _emojiCategories[categoryName] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Text(categoryName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: emojis.map((emoji) {
                        return InkWell(
                          onTap: () {
                            if (isLiveCloudCard) {
                              HomeRepository().incrementEmojiReaction(cardId, emoji, currentReactions);
                            } else {
                              _handleReaction(cardId, emoji);
                            }
                            Navigator.pop(context); // Dismiss sheet immediately upon selection
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 20)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsHeaderCard(BuildContext context, String title, String sub) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
              child: Icon(Icons.church_outlined, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Role Scope: $sub', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePickerBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Appearance & Branding', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Divider(),
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
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.getTheme(currentMode, isDarkMode: themeState.isDarkMode).colorScheme.primary,
                          radius: 10,
                        ),
                        title: Text(currentMode.name.replaceAllMapped(RegExp(r'(^[a-z]|[A-Z])'), (match) => ' ${match.group(0)?.toUpperCase()}').trim()),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                        onTap: () {
                          context.read<ThemeBloc>().add(ChangeThemeEvent(themeMode: currentMode, isDarkMode: themeState.isDarkMode));
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
    );
  }
}