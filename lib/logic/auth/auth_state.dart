import 'package:equatable/equatable.dart';
import '/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Initial / logged-out state
class AuthInitial extends AuthState {}

/// Waiting for API response
class AuthLoading extends AuthState {}

/// Fully logged in - token saved
class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

/// General API / network error
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Local form validation failed
class AuthValidationError extends AuthState {
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  const AuthValidationError({
    this.nameError,
    this.emailError,
    this.passwordError,
  });
  @override
  List<Object?> get props => [nameError, emailError, passwordError];
}

/// Sign Up: registration done - OTP sent to email
class AuthRegistrationSuccess extends AuthState {
  final String email;
  final String tempToken;
  const AuthRegistrationSuccess({
    required this.email,
    required this.tempToken,
  });
  @override
  List<Object?> get props => [email, tempToken];
}

/// Sign In: credentials correct - OTP sent to email
class AuthSignInOTPSent extends AuthState {
  final String email;
  const AuthSignInOTPSent(this.email);
  @override
  List<Object?> get props => [email];
}

/// OTP verified successfully (both signup & signin flows)
class AuthOTPVerified extends AuthState {
  final String email;
  const AuthOTPVerified(this.email);
  @override
  List<Object?> get props => [email];
}

/// OTP resent — timestamp عشان Equatable يشيل الفرق لو اتبعتت أكتر من مرة
class AuthOTPResent extends AuthState {
  final String email;
  final DateTime timestamp; // ✅ حل مشكلة الـ resend

  AuthOTPResent(this.email) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [email, timestamp];
}