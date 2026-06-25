// test/auth_persistence_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:church_gear/logic/auth_bloc/auth_bloc.dart';
import 'package:church_gear/data/repositories/auth_repository.dart';
import 'package:church_gear/data/repositories/secure_storage_service.dart';
import 'package:church_gear/data/models/user_session.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  group('AuthBloc Session Persistence Unit Tests', () {
    late MockAuthRepository mockAuthRepository;
    late MockSecureStorageService mockSecureStorageService;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockSecureStorageService = MockSecureStorageService();
    });

    // Test 1: Clear storage fallback path
    blocTest<AuthBloc, AuthState>(
      'Should emit unauthenticated state with an anonymous session when token is missing',
      build: () {
        when(() => mockSecureStorageService.getAuthToken())
            .thenAnswer((_) async => null);
        return AuthBloc(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        );
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        AuthState(session: UserSession.anonymous(), status: AuthStatus.loading),
        AuthState(session: UserSession.anonymous(), status: AuthStatus.unauthenticated),
      ],
    );

    // Test 2: Hydrated persistent login path
    blocTest<AuthBloc, AuthState>(
      'Should emit authenticated state with cached user when a valid token exists',
      build: () {
        when(() => mockSecureStorageService.getAuthToken())
            .thenAnswer((_) async => 'valid_persisted_jwt_token');
        return AuthBloc(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        );
      },
      act: (bloc) => bloc.add(CheckAuthStatusEvent()),
      expect: () => [
        AuthState(session: UserSession.anonymous(), status: AuthStatus.loading),
        const AuthState(
          session: UserSession(
            userId: 'cached_verified_user',
            tenantId: 'global_shared',
            userRole: UserRole.member,
            jwtToken: 'valid_persisted_jwt_token',
          ),
          status: AuthStatus.authenticated,
        ),
      ],
    );
  });
}