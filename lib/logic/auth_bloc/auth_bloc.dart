// lib/logic/auth_bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_session.dart';

// ============================================================================
// 1. AUTH BLOC EVENTS (Inputs)
// ============================================================================

/// Base definition for all incoming authentication lifecycle events.
abstract class AuthEvent {
  const AuthEvent();
}

/// Dispatched immediately upon a successful cryptographic validation signature
/// check from our Supabase backend provider.
class LoginSuccessEvent extends AuthEvent {
  final UserSession session;

  const LoginSuccessEvent(this.session);
}

/// Dispatched when a user requests an explicit session termination or 
/// when a JWT token lifespan expiration is caught.
class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}

// ============================================================================
// 2. AUTH BLOC STATES (Outputs)
// ============================================================================

/// Holds the active operational context state of the user session.
class AuthState {
  final UserSession session;

  const AuthState({required this.session});

  /// Factory constructor forcing an unauthenticated anonymous boundary state by default.
  factory AuthState.initial() {
    return AuthState(session: UserSession.anonymous());
  }
}

// ============================================================================
// 3. AUTH BLOC HUB (The Session Vault)
// ============================================================================

/// Manages structural tenant isolation scopes, account session permissions,
/// and tokens across the lifecycle of the Church Gear interface.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthState.initial()) {
    
    // Handler for successful authentication logins
    on<LoginSuccessEvent>((event, emit) {
      emit(AuthState(session: event.session));
    });

    // Handler for wiping tokens and session states cleanly
    on<LogoutRequestedEvent>((event, emit) {
      emit(AuthState(session: UserSession.anonymous()));
    });
  }
}