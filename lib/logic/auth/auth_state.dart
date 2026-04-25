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

/// API call succeeded - User logged in
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

// ✅ Registration successful - OTP sent to email
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

// ✅ OTP verified successfully - User can continue
class AuthOTPVerified extends AuthState {
  final String email;
  const AuthOTPVerified(this.email);

  @override
  List<Object?> get props => [email];
}

// ✅ OTP resent
class AuthOTPResent extends AuthState {
  final String email;
  const AuthOTPResent(this.email);

  @override
  List<Object?> get props => [email];
}