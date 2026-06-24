// lib/data/repositories/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_session.dart';

/// Abstract interface contract defining the required network methods
/// for user authentication and session validation.
abstract class AuthRepository {
  /// Authenticates a user against the cloud database using email credentials.
  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  });

  /// Terminates the remote session network state cleanly.
  Future<void> signOut();
}

/// The production implementation of our authentication contract,
/// wrapping the official cloud Supabase client SDK.
class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabaseClient;

  /// Dependency injection constructor allowing mock or real clients to be passed in.
  SupabaseAuthRepository({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<UserSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // 1. Dispatch network call to Supabase authentication endpoints
    final AuthResponse response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final session = response.session;
    final user = response.user;

    if (session == null || user == null) {
      throw Exception('Authentication failed: Missing remote token payloads.');
    }

    // 2. Extract metadata parameters containing the multi-tenant isolation routing keys
    final tenantId =
        user.userMetadata?['tenant_id'] as String? ?? 'global_shared';
    final userRoleString =
        user.userMetadata?['user_role'] as String? ?? 'member';

    // 3. Map into our verified, stable frontend application schema model
    return UserSession(
      userId: user.id,
      tenantId: tenantId,
      userRole: _mapRole(userRoleString),
      jwtToken: session.accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  /// Internal utility helper to safely transform unstructured database metadata strings
  /// into strongly-typed frontend compilation constraints.
  UserRole _mapRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'member':
        return UserRole.member;
      case 'guest':
      default:
        return UserRole.guest;
    }
  }
}
