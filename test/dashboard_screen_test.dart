// test/presentation/dashboard_screen_test.dart

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

    // INJECT STREAM STUBS TO PREVENT FLUTTER PROVIDER CRASHES
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockThemeBloc.stream).thenAnswer((_) => const Stream.empty());

    // Stub the active theme configuration
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

  testWidgets('Should display Media Hub by default and change view on bottom navigation tap', (WidgetTester tester) async {
    // Arrange: Stub AuthBloc state as Guest session
    when(() => mockAuthBloc.state).thenReturn(
      AuthState(session: UserSession.guest(), status: AuthStatus.authenticated),
    );

    // Act: Render dashboard layout scaffold frame
    await tester.pumpWidget(createWidgetUnderEst(mockAuthBloc, mockThemeBloc));

    // Assert: Default entry view shows the Media & Discipleship module content
    expect(find.text('Media & Discipleship Hub'), findsOneWidget);
    expect(find.text('Community Directory'), findsNothing);

    // Act: Tap on the Community bottom navigation item tab
    await tester.tap(find.byIcon(Icons.diversity_3));
    await tester.pumpAndSettle();

    // Assert: View hierarchy updates cleanly to show the Community layout matrix
    expect(find.text('Media & Discipleship Hub'), findsNothing);
    expect(find.text('Community Directory'), findsOneWidget);
  });
}