import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';

// ─── EVENTS ──────────────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}
class CheckAuthStatusEvent  extends AuthEvent {}
class SignInWithGoogleEvent extends AuthEvent {}
class SignOutEvent          extends AuthEvent {}

// ─── STATES ──────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}
class AuthInitial       extends AuthState {}
class AuthLoading       extends AuthState {}
class AuthUnauthenticated extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated({required this.user});
  @override List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override List<Object?> get props => [message];
}

// ─── SIMPLE USER MODEL ────────────────────────────────────────────────────────
class UserModel extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        email: map['email'] as String,
        displayName: map['displayName'] as String,
        photoUrl: map['photoUrl'] as String?,
        role: map['role'] as String? ?? 'CUSTOMER',
      );

  @override List<Object?> get props => [id, email];
}

// ─── BLOC ─────────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn;

  AuthBloc({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn,
        super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuth);
    on<SignInWithGoogleEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
  }

  // ── Check if JWT is saved (app relaunch) ──────────────────────────────────
  Future<void> _onCheckAuth(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final hasJwt = await hasToken();
      if (!hasJwt) { emit(AuthUnauthenticated()); return; }

      // Validate token with /auth/me
      final res = await ApiService.instance.dio.get(ApiConstants.me);
      if (res.statusCode == 200 && res.data['success'] == true) {
        final user = UserModel.fromMap(res.data['data'] as Map<String, dynamic>);
        emit(AuthAuthenticated(user: user));
      } else {
        await deleteToken();
        emit(AuthUnauthenticated());
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await deleteToken();
        emit(AuthUnauthenticated());
      } else {
        // Network issue — keep user logged in if we have a token locally
        final hasJwt = await hasToken();
        if (hasJwt) {
          // Can't reach server but token exists — show as authenticated (offline grace)
          emit(const AuthError(message: 'Network error. Some features may be unavailable.'));
        } else {
          emit(AuthUnauthenticated());
        }
      }
    } catch (_) {
      await deleteToken();
      emit(AuthUnauthenticated());
    }
  }

  // ── Google Sign-In → send idToken to backend → save JWT ──────────────────
  Future<void> _onSignIn(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Step 1: Google OAuth
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { emit(AuthUnauthenticated()); return; }

      final googleAuth = await googleUser.authentication;

      // Web only returns accessToken; mobile returns idToken
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        emit(const AuthError(message: 'Could not get Google token'));
        return;
      }

      // Step 2: Send token to backend — prefer idToken (mobile), fall back to accessToken (web)
      final Map<String, dynamic> tokenPayload = kIsWeb && idToken == null
          ? {'accessToken': accessToken}
          : {'idToken': idToken};

      final res = await ApiService.instance.dio.post(
        ApiConstants.googleLogin,
        data: tokenPayload,
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        final jwt = res.data['data']['token'] as String;
        final user = UserModel.fromMap(
            res.data['data']['user'] as Map<String, dynamic>);

        // Step 3: Save JWT — used in every subsequent request
        await saveToken(jwt);

        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthError(message: 'Login failed. Please try again.'));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ??
          'Network error. Please check your connection.';
      emit(AuthError(message: msg));
    } catch (e) {
      emit(AuthError(message: 'Sign in failed: ${e.toString()}'));
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _googleSignIn.signOut();
      await deleteToken();
      emit(AuthUnauthenticated());
    } catch (_) {
      await deleteToken();
      emit(AuthUnauthenticated());
    }
  }
}
