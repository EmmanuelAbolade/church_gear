// lib/data/models/user_session.dart

import 'package:equatable/equatable.dart';

enum UserRole { superAdmin, admin, member, guest }

class UserSession extends Equatable {
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

  /// Factory constructor matching your exact test-suite fallback expectations
  factory UserSession.guest() {
    return const UserSession(
      userId: 'anonymous_guest', // 🔍 FIXED: Restored to match your test spec
      tenantId: 'global_shared',
      userRole: UserRole.guest,
      jwtToken: '',
    );
  }

  factory UserSession.anonymous() => UserSession.guest();

  /// Deserializer that gracefully parses both full string types and clean enum names
  factory UserSession.fromJson(Map<String, dynamic> json) {
    final rawRole = json['userRole'] as String;

    return UserSession(
      userId: json['userId'] as String,
      tenantId: json['tenantId'] as String,
      userRole: UserRole.values.firstWhere(
        (e) => e.toString() == rawRole || e.name == rawRole,
        orElse: () => UserRole.guest,
      ),
      jwtToken: json['jwtToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tenantId': tenantId,
      'userRole': userRole.toString(),
      'jwtToken': jwtToken,
    };
  }

  bool get isAuthenticated => userRole != UserRole.guest && jwtToken.isNotEmpty;

  // Injected value-comparison property matrix
  @override
  List<Object?> get props => [userId, tenantId, userRole, jwtToken];
}
