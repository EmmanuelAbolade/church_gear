// lib/data/models/user_session.dart

/// Enumeration defining the absolute authorization tiers across
/// the Church Gear multi-tenant ecosystem.
enum UserRole {
  guest,
  member,
  admin
}

/// Representational data entity containing current security tokens,
/// active tenant tracking keys, and profile access vectors.
class UserSession {
  final String userId;
  final String tenantId;
  final UserRole userRole;
  final String jwtToken;

  const UserSession({
    required this.userId,
    required this.tenantId,
    required this.userRole,
    required this.jwtToken,
  });

  /// Factory constructor to securely extract incoming identity structures
  /// returned by our authentication server infrastructure.
  factory UserSession.fromJson(Map<String, dynamic> json) {
    // Helper mapper to safely transform raw role strings to robust types
    final roleString = json['userRole'] as String?;
    UserRole evaluatedRole;
    
    switch (roleString?.toLowerCase()) {
      case 'admin':
        evaluatedRole = UserRole.admin;
        break;
      case 'member':
        evaluatedRole = UserRole.member;
        break;
      case 'guest':
      default:
        evaluatedRole = UserRole.guest;
    }

    return UserSession(
      userId: json['userId'] as String? ?? 'anonymous_guest',
      tenantId: json['tenantId'] as String? ?? 'global_shared',
      userRole: evaluatedRole,
      jwtToken: json['jwtToken'] as String? ?? '',
    );
  }

  /// Factory utility generating pristine, restricted-access parameters 
  /// for guest accounts browsing public tenant landing nodes.
  factory UserSession.anonymous() {
    return const UserSession(
      userId: 'anonymous_guest',
      tenantId: 'global_shared',
      userRole: UserRole.guest,
      jwtToken: '',
    );
  }

  /// Evaluates whether this specific context instance maintains
  /// an authorized cryptographic verification signature.
  bool get isAuthenticated => jwtToken.isNotEmpty && userRole != UserRole.guest;
}