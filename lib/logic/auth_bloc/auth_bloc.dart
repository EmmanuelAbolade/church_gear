// lib/logic/auth_bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user_session.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/secure_storage_service.dart';
import '../../data/models/registration_payload.dart';

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginWithEmailRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailRequestedEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequestedEvent extends AuthEvent {}

// Event Added
class EnterAsGuestEvent extends AuthEvent {
  const EnterAsGuestEvent();
}

class RegisterWithTenantRequestedEvent extends AuthEvent {
  final RegistrationPayload payload;

  const RegisterWithTenantRequestedEvent({required this.payload});

  @override
  List<Object?> get props => [payload];
}

// --- States ---
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final UserSession session;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    required this.session,
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  factory AuthState.initial() =>
      AuthState(session: UserSession.anonymous(), status: AuthStatus.initial);

  // 💡 Factory helper added to cleanly yield an authenticated guest block
  factory AuthState.authenticated(UserSession session) =>
      AuthState(session: session, status: AuthStatus.authenticated);

  AuthState copyWith({
    UserSession? session,
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      session: session ?? this.session,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [session, status, errorMessage];
}

// --- BLoC Controller Engine ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorageService;

  AuthBloc({
    AuthRepository? authRepository,
    SecureStorageService? secureStorageService,
  }) : _authRepository = authRepository ?? SupabaseAuthRepository(),
       _secureStorageService =
           secureStorageService ??
           const SecureStorageService(storage: FlutterSecureStorage()),
       super(AuthState.initial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginWithEmailRequestedEvent>(_onLoginWithEmailRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<EnterAsGuestEvent>(_onEnterAsGuest); // 💡 Listener registered
    on<RegisterWithTenantRequestedEvent>(_onRegisterWithTenantRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final cachedToken = await _secureStorageService.getAuthToken();

      if (cachedToken != null && cachedToken.isNotEmpty) {
        final hydratedSession = UserSession(
          userId: 'cached_verified_user',
          tenantId: 'global_shared',
          userRole: UserRole.member,
          jwtToken: cachedToken,
        );
        emit(
          AuthState(session: hydratedSession, status: AuthStatus.authenticated),
        );
      } else {
        emit(
          AuthState(
            session: UserSession.anonymous(),
            status: AuthStatus.unauthenticated,
          ),
        );
      }
    } catch (e) {
      emit(
        AuthState(
          session: UserSession.anonymous(),
          status: AuthStatus.error,
          errorMessage: 'Failed to evaluate offline device token authenticity.',
        ),
      );
    }
  }

  Future<void> _onLoginWithEmailRequested(
    LoginWithEmailRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final liveSession = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      await _secureStorageService.persistAuthToken(liveSession.jwtToken);

      emit(AuthState(session: liveSession, status: AuthStatus.authenticated));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.signOut();
      await _secureStorageService.deleteAuthToken();

      emit(
        AuthState(
          session: UserSession.anonymous(),
          status: AuthStatus.unauthenticated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage:
              'Network cleanup failed, forced local session destruction applied.',
        ),
      );
    }
  }

  // Worker logic added
  Future<void> _onEnterAsGuest(
    EnterAsGuestEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticated(UserSession.guest()));
  }

  // 🔽 INSERT THE REGISTRATION WORKER LOGIC DIRECTLY BENEATH IT:
  Future<void> _onRegisterWithTenantRequested(
    RegisterWithTenantRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final freshSession = await _authRepository.signUpWithTenant(payload: event.payload);
      
      // Persist the token to secure storage if returned immediately
      if (freshSession.jwtToken != 'awaiting_email_confirmation') {
        await _secureStorageService.persistAuthToken(freshSession.jwtToken);
      }
      
      emit(AuthState(session: freshSession, status: AuthStatus.authenticated));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}