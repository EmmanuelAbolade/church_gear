// lib/data/models/registration_payload.dart

class RegistrationPayload {
  final String pastorName;
  final String email;
  final String password;
  final String churchName;

  const RegistrationPayload({
    required this.pastorName,
    required this.email,
    required this.password,
    required this.churchName,
  });

  /// Automatically derives a clean, URL-safe tenant ID from the church name
  String get derivedTenantId {
    return churchName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Strip special characters
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');       // Convert spaces to underscores
  }
}