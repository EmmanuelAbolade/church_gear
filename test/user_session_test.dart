// test/user_session_test.dart

import 'package:flutter_test/flutter_test.dart';
// ⚠️ THIS LINE WILL SHOW A RED ERROR: The model file doesn't exist yet!
import 'package:church_gear/data/models/user_session.dart';

void main() {
  group('UserSession Data Model TDD Tests', () {
    test(
      'Should correctly parse valid JSON payload into authenticated UserSession model',
      () {
        // 1. Arrange: Mimic a secure incoming JSON map from our authentication provider
        final Map<String, dynamic> rawJson = {
          'userId': 'usr_987654321',
          'tenantId': 'tenant_st_andrews',
          'userRole': 'admin',
          'jwtToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mockTokenSignature',
        };

        // 2. Act: Attempt to build the data entity model using our factory constructor
        final session = UserSession.fromJson(rawJson);

        // 3. Assert: Verify every domain parameter maps exactly as required
        expect(session.userId, equals('usr_987654321'));
        expect(session.tenantId, equals('tenant_st_andrews'));
        expect(session.userRole, equals(UserRole.admin));
        expect(
          session.jwtToken,
          equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mockTokenSignature'),
        );
        expect(session.isAuthenticated, isTrue);
      },
    );

    test(
      'Should successfully enforce structural fallback parameters for Anonymous Guest accounts',
      () {
        // Act: Create an unauthenticated placeholder profile
        final guestSession = UserSession.anonymous();

        // Assert: Verify structural boundaries lock down privileges
        expect(guestSession.userId, equals('anonymous_guest'));
        expect(guestSession.tenantId, equals('global_shared'));
        expect(guestSession.userRole, equals(UserRole.guest));
        expect(guestSession.jwtToken, isEmpty);
        expect(guestSession.isAuthenticated, isFalse);
      },
    );
  });
}
