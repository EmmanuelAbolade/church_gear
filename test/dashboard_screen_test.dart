// test/dashboard_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:church_gear/presentation/dashboard_screen.dart';
import 'package:church_gear/logic/auth_bloc/auth_bloc.dart';
import 'package:church_gear/logic/theme_bloc/theme_bloc.dart';
import 'package:church_gear/data/repositories/sermon_repository.dart';
import 'package:church_gear/data/repositories/member_repository.dart';
import 'package:church_gear/data/models/user_session.dart';
import 'package:church_gear/core/theme/app_theme.dart';

// Create pure testing mocks to bypass raw production cloud initialization loops
class MockAuthBloc extends Mock implements AuthBloc {}
class MockThemeBloc extends Mock implements ThemeBloc {}
class MockSermonRepository extends Mock implements SermonRepository {}
class MockMemberRepository extends Mock implements MemberRepository {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockThemeBloc mockThemeBloc;
  late MockSermonRepository mockSermonRepo;
  late MockMemberRepository mockMemberRepo;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockThemeBloc = MockThemeBloc();
    mockSermonRepo = MockSermonRepository();
    mockMemberRepo = MockMemberRepository();

    // Stub the default session state context
    final mockSession = UserSession.guest();

    when(() => mockAuthBloc.state).thenReturn(AuthState(session: mockSession));
    when(() => mockThemeBloc.state).thenReturn(const ThemeState(
      themeMode: AppThemeMode.cathedral,
      isDarkMode: false,
    ));

    // Stub the repository methods to return empty testing streams safely
    when(() => mockSermonRepo.streamSermons(tenantId: any(named: 'tenantId')))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockMemberRepo.streamMembers(tenantId: any(named: 'tenantId')))
        .thenAnswer((_) => Stream.value([]));
  });

  Widget buildTestableWidget() {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SermonRepository>.value(value: mockSermonRepo),
        RepositoryProvider<MemberRepository>.value(value: mockMemberRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<ThemeBloc>.value(value: mockThemeBloc),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );
  }

  group('DashboardScreen Scaled Architecture Tests', () {
    testWidgets('Should display New Home Portal Hub layout by default on entry', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Verify that the new layout headline renders perfectly
      expect(find.text('Welcome to'), findsOneWidget);
      expect(find.text('Global Shared Ministry'), findsOneWidget);
      expect(find.text('Quick Access Actions'), findsOneWidget);
      expect(find.text('Holy Bible'), findsOneWidget);
    });

    testWidgets('Should render scalable More options page correctly when tab is clicked', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      // Tap on the 'More' bottom navigation item icon
      final moreTabFinder = find.byIcon(Icons.more_horiz_outlined);
      expect(moreTabFinder, findsOneWidget);
      
      await tester.tap(moreTabFinder);
      await tester.pumpAndSettle();

      // Confirm the scalable engagement sections render beautifully
      expect(find.text('More Options'), findsOneWidget);
      expect(find.text('Ministry Engagement'), findsOneWidget);
      expect(find.text('Interaction & Feedback Loops'), findsOneWidget);
    });
  });
}