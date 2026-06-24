// test/secure_storage_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ⚠️ THIS IMPORT WILL SHOW A RED ERROR: The service does not exist yet!
import 'package:church_gear/data/repositories/secure_storage_service.dart';

// Generate a mock instance of FlutterSecureStorage for isolation
@GenerateMocks([FlutterSecureStorage])
import 'secure_storage_test.mocks.dart';

void main() {
  // Setup unit testing binding parameters
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService TDD Cryptographic Vault Tests', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageService storageService;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      storageService = SecureStorageService(storage: mockStorage);
    });

    test(
      'Should invoke hardware write methods when saving target token signatures',
      () async {
        // Arrange: Stub our mock hardware to resolve successfully
        when(
          mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async => {});

        // Act: Trigger our custom service execution wrapper
        await storageService.persistAuthToken('mock_encrypted_jwt_passport');

        // Assert: Verify our service passed the data directly to secure hardware keys
        verify(
          mockStorage.write(
            key: 'jwt_auth_token',
            value: 'mock_encrypted_jwt_passport',
          ),
        ).called(1);
      },
    );

    test(
      'Should return empty fallback data frames if a cache check misses',
      () async {
        when(
          mockStorage.read(key: anyNamed('key')),
        ).thenAnswer((_) async => null);

        final token = await storageService.getAuthToken();

        expect(token, isNull);
      },
    );
  });
}
