// test/auth_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:church_gear/logic/auth_bloc/auth_bloc.dart';
import 'package:church_gear/data/models/user_session.dart';
import 'package:church_gear/data/repositories/auth_repository.dart';
import 'package:church_gear/data/repositories/secure_storage_service.dart';

// Create explicit mock classes for our infrastructure layers
class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSecureStorageService mockSecureStorageService;
  late UserSession testSession;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSecureStorageService = MockSecureStorageService();

    testSession = const UserSession(
      userId: 'test_user_123',
      tenantId: 'global_shared',
      userRole: UserRole.member,
      jwtToken: 'mock_jwt_token_payload',
    );
  });

  group('AuthBloc Network Integration Tests', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] when login is requested and succeeds',
      build: () {
        when(
          () => mockAuthRepository.signInWithEmail(
            email: 'test@church.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async => testSession);

        when(
          () => mockSecureStorageService.persistAuthToken(any()),
        ).thenAnswer((_) async => {});

        return AuthBloc(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        );
      },
      act: (bloc) => bloc.add(
        const LoginWithEmailRequestedEvent(
          email: 'test@church.com',
          password: 'password123',
        ),
      ),
      expect: () => [
        AuthState(session: UserSession.anonymous(), status: AuthStatus.loading),
        AuthState(session: testSession, status: AuthStatus.authenticated),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] when network credentials fail authentication checks',
      build: () {
        when(
          () => mockAuthRepository.signInWithEmail(
            email: 'wrong@church.com',
            password: 'bad',
          ),
        ).thenThrow(Exception('Invalid login credentials'));

        return AuthBloc(
          authRepository: mockAuthRepository,
          secureStorageService: mockSecureStorageService,
        );
      },
      act: (bloc) => bloc.add(
        const LoginWithEmailRequestedEvent(
          email: 'wrong@church.com',
          password: 'bad',
        ),
      ),
      expect: () => [
        AuthState(session: UserSession.anonymous(), status: AuthStatus.loading),
        AuthState(
          // 🔍 FIXED: Removed the 'const' keyword from this constructor
          session: UserSession.anonymous(),
          status: AuthStatus.error,
          errorMessage: 'Invalid login credentials',
        ),
      ],
    );
  });
}
