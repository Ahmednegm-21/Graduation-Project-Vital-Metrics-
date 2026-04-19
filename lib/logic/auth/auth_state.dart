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

/// API call succeeded
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

/// Local form validation failed (no API call made)
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