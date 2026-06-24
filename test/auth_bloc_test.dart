// test/auth_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
// ⚠️ THESE IMPORTS WILL SHOW RED ERRORS: The auth bloc files don't exist yet!
import 'package:church_gear/logic/auth_bloc/auth_bloc.dart';
import 'package:church_gear/data/models/user_session.dart';

void main() {
  group('AuthBloc Logic Layer TDD Tests', () {
    
    // Test 1: Out of the box initialization safety
    test('Initial state of AuthBloc should contain an unauthenticated anonymous guest profile', () {
      final authBloc = AuthBloc();
      
      expect(authBloc.state.session.isAuthenticated, isFalse);
      expect(authBloc.state.session.userRole, equals(UserRole.guest));
      
      authBloc.close();
    });

    // Test 2: Simulating a successful profile validation flow
    final mockSession = UserSession(
      userId: 'usr_admin123',
      tenantId: 'tenant_grace_chapel',
      userRole: UserRole.admin,
      jwtToken: 'mock_validated_jwt_token_string',
    );

    blocTest<AuthBloc, AuthState>(
      'Emits AuthState with verified session properties when LoginSuccessEvent is received',
      build: () => AuthBloc(),
      act: (bloc) => bloc.add(LoginSuccessEvent(mockSession)),
      expect: () => [
        predicate<AuthState>((state) {
          return state.session.isAuthenticated == true && 
                 state.session.userId == 'usr_admin123' &&
                 state.session.userRole == UserRole.admin;
        }),
      ],
    );

    // Test 3: Wiping a session completely on user logout
    blocTest<AuthBloc, AuthState>(
      'Emits unauthenticated state with anonymous structures when LogoutRequestedEvent is received',
      build: () => AuthBloc(),
      seed: () => AuthState(session: mockSession), // Seed an already logged-in block
      act: (bloc) => bloc.add(const LogoutRequestedEvent()),
      expect: () => [
        predicate<AuthState>((state) {
          return state.session.isAuthenticated == false && 
                 state.session.userId == 'anonymous_guest';
        }),
      ],
    );
  });
}