// test/dashboard_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:church_gear/presentation/dashboard_screen.dart';
import 'package:church_gear/logic/auth_bloc/auth_bloc.dart';
import 'package:church_gear/logic/theme_bloc/theme_bloc.dart';
import 'package:church_gear/data/models/user_session.dart';
import 'package:church_gear/core/theme/app_theme.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockThemeBloc extends Mock implements ThemeBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockThemeBloc mockThemeBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockThemeBloc = MockThemeBloc();

    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockThemeBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockThemeBloc.state).thenReturn(
      const ThemeState(themeMode: AppThemeMode.cathedral, isDarkMode: false),
    );
  });

  Widget createWidgetUnderEst(MockAuthBloc authBloc, MockThemeBloc themeBloc) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ThemeBloc>.value(value: themeBloc),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  testWidgets('Should display Media Hub in Cathedral layout by default', (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(
      AuthState(session: UserSession.guest(), status: AuthStatus.authenticated),
    );

    await tester.pumpWidget(createWidgetUnderEst(mockAuthBloc, mockThemeBloc));

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

    await tester.pumpWidget(createWidgetUnderEst(mockAuthBloc, mockThemeBloc));

    expect(find.text('LATEST RELEASE'), findsOneWidget);
    expect(find.text('Trending Sermon Series'), findsOneWidget);
  });

  testWidgets('Should navigate to Community Directory and render roster entries successfully', (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(
      AuthState(session: UserSession.guest(), status: AuthStatus.authenticated),
    );

    await tester.pumpWidget(createWidgetUnderEst(mockAuthBloc, mockThemeBloc));

    // Tap on the 'Community' navigation tab icon to change modules
    await tester.tap(find.byIcon(Icons.diversity_3));
    await tester.pumpAndSettle();

    // Assert: Check that the header bar title and custom mock entries render flawlessly
    expect(find.text('Directory Roster'), findsOneWidget);
    expect(find.text('Alex Bruce'), findsOneWidget);
    expect(find.text('Keji Alex'), findsOneWidget);
  });
}