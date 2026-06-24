// lib/data/repositories/secure_storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A secure hardware storage service wrapper that handles encrypting,
/// caching, and wiping session credential tokens on the local device.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  // Explicit token lookup key for the hardware keychain matrix
  static const _tokenKey = 'jwt_auth_token';

  /// Dependency injection constructor allowing mock instances during test sweeps
  const SecureStorageService({required FlutterSecureStorage storage})
    : _storage = storage;

  /// Safely serializes and encrypts an active user authentication passport
  /// into the device's secure hardware storage tier.
  Future<void> persistAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Retrieves the encrypted string payload from the local device cache.
  /// Returns null if no active token data is found.
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Permanently removes the encrypted token array from the hardware layer
  /// to prevent token re-use after a logout event.
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
