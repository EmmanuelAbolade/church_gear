// test/auth_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:church_gear/logic/auth_bloc/auth_bloc.dart';
import 'package:church_gear/data/models/user_session.dart';

// Import our generated storage mock to intercept hardware hits
import 'secure_storage_test.mocks.dart';

void main() {
  group('AuthBloc Local Storage Integration Tests', () {
    late MockFlutterSecureStorage mockHardware;

    setUp(() {
      mockHardware = MockFlutterSecureStorage();
    });

    final mockSession = UserSession(
      userId: 'usr_admin123',
      tenantId: 'tenant_grace_chapel',
      userRole: UserRole.admin,
      jwtToken: 'mock_validated_jwt_token_string',
    );

    blocTest<AuthBloc, AuthState>(
      'Should persist JWT to local device keychain when LoginSuccessEvent is processed',
      build: () {
        // Stub the write behavior to resolve cleanly
        when(mockHardware.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => {});
        return AuthBloc(secureStorage: mockHardware);
      },
      act: (bloc) => bloc.add(LoginSuccessEvent(mockSession)),
      verify: (_) {
        // Assert that the token was safely written to hardware storage
        verify(mockHardware.write(key: 'jwt_auth_token', value: 'mock_validated_jwt_token_string')).called(1);
      },
    );
  });
}