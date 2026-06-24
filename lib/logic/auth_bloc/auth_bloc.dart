// lib/logic/auth_bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_session.dart';

// ============================================================================
// EVENTS & STATES
// ============================================================================
abstract class AuthEvent {
  const AuthEvent();
}

class LoginSuccessEvent extends AuthEvent {
  final UserSession session;
  const LoginSuccessEvent(this.session);
}

class LogoutRequestedEvent extends AuthEvent {
  const LogoutRequestedEvent();
}

class AuthState {
  final UserSession session;
  const AuthState({required this.session});

  factory AuthState.initial() => AuthState(session: UserSession.anonymous());
}

// ============================================================================
// LOGIC STORAGE INTERACTION HUB
// ============================================================================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _secureStorage;

  // Constructor with dependency injection, defaulting to production hardware instance
  AuthBloc({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
      super(AuthState.initial()) {
    on<LoginSuccessEvent>((event, emit) async {
      // 1. Persist the token payload directly to local device encrypted hardware
      if (event.session.jwtToken.isNotEmpty) {
        await _secureStorage.write(
          key: 'jwt_auth_token',
          value: event.session.jwtToken,
        );
      }
      // 2. Stream out the verified state context down to our user interface
      emit(AuthState(session: event.session));
    });

    on<LogoutRequestedEvent>((event, emit) async {
      // 1. Wipe cached credential history permanently from the local hardware
      await _secureStorage.delete(key: 'jwt_auth_token');
      // 2. Drop the session context frame down to default restricted guest privileges
      emit(AuthState(session: UserSession.anonymous()));
    });
  }
}
