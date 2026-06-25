// test/dashboard_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:church_gear/presentation/dashboard_screen.dart';
import 'package:church_gear/logic/auth_bloc/auth_bloc.dart';
import 'package:church_gear/logic/theme_bloc/theme_bloc.dart';
import 'package:church_gear/data/models/user_session.dart';
import 'package:church_gear/data/models/sermon_media_item.dart';
import 'package:church_gear/data/models/church_member.dart';
import 'package:church_gear/core/theme/app_theme.dart';
import 'package:church_gear/data/repositories/sermon_repository.dart';
import 'package:church_gear/data/repositories/member_repository.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockThemeBloc extends Mock implements ThemeBloc {}
class MockSermonRepository extends Mock implements SermonRepository {}
class MockMemberRepository extends Mock implements MemberRepository {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockThemeBloc mockThemeBloc;
  late MockSermonRepository mockSermonRepository;
  late MockMemberRepository mockMemberRepository;

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
  ];

  final dummyMembers = [
    const ChurchMember(
      id: 'mem_1',
      tenantId: 'global_shared',
      name: 'Alex Bruce',
      role: 'Small Group Pastor',
      imageUrl: '',
      groupName: 'Young Adults Fellowship',
    ),
  ];

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockThemeBloc = MockThemeBloc();
    mockSermonRepository = MockSermonRepository();
    mockMemberRepository = MockMemberRepository();

    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockThemeBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockThemeBloc.state).thenReturn(
      const ThemeState(themeMode: AppThemeMode.cathedral, isDarkMode: false),
    );

    // 💡 Provide streams that emit real mock data instantly
    when(() => mockSermonRepository.streamSermons(tenantId: any(named: 'tenantId')))
        .thenAnswer((_) => Stream.value(dummySermons));
    when(() => mockMemberRepository.streamMembers(tenantId: any(named: 'tenantId')))
        .thenAnswer((_) => Stream.value(dummyMembers));
  });

  Widget createWidgetUnderEst(
    MockAuthBloc authBloc,
    MockThemeBloc themeBloc,
    MockSermonRepository sermonRepo,
    MockMemberRepository memberRepo,
  ) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SermonRepository>.value(value: sermonRepo),
        RepositoryProvider<MemberRepository>.value(value: memberRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<ThemeBloc>.value(value: themeBloc),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
  }

  testWidgets('Should display Media Hub in Cathedral layout by default', (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(
      AuthState(session: UserSession.guest(), status: AuthStatus.authenticated),
    );

    await tester.pumpWidget(createWidgetUnderEst(
      mockAuthBloc,
      mockThemeBloc,
      mockSermonRepository,
      mockMemberRepository,
    ));
    
    await tester.pumpAndSettle();

    // Verify stream data forces cathedral layout elements onto the viewport
    expect(find.text('The Blueprint of Honor'), findsOneWidget);
    expect(find.text('Trending Sermon Series'), findsNothing);
  });

  testWidgets('Should switch Media Hub to Premium layout when theme updates', (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(
      AuthState(session: UserSession.guest(), status: AuthStatus.authenticated),
    );
    when(() => mockThemeBloc.state).thenReturn(
      const ThemeState(themeMode: AppThemeMode.oliveGrove, isDarkMode: false),
    );

    await tester.pumpWidget(createWidgetUnderEst(
      mockAuthBloc,
      mockThemeBloc,
      mockSermonRepository,
      mockMemberRepository,
    ));
    
    await tester.pumpAndSettle();

    // Verify metropolitan premium layout updates properly
    expect(find.text('LATEST RELEASE'), findsOneWidget);
    expect(find.text('Trending Sermon Series'), findsOneWidget);
  });

  testWidgets('Should navigate to Community Directory and render roster entries successfully', (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(
      AuthState(session: UserSession.guest(), status: AuthStatus.authenticated),
    );

    await tester.pumpWidget(createWidgetUnderEst(
      mockAuthBloc,
      mockThemeBloc,
      mockSermonRepository,
      mockMemberRepository,
    ));

    await tester.pumpAndSettle();

    // Tap on the 'Community' navigation tab icon
    await tester.tap(find.byIcon(Icons.diversity_3));
    await tester.pumpAndSettle();

    // Verify stream data successfully populates our roster view grid
    expect(find.text('Directory Roster'), findsOneWidget);
    expect(find.text('Alex Bruce'), findsOneWidget);
  });
}