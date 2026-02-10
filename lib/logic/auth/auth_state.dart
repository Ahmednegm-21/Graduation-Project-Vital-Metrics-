import 'package:equatable/equatable.dart';
import '/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// Initial state
class AuthInitial extends AuthState {}

// Loading state
class AuthLoading extends AuthState {}

// Success state with validation
class AuthSuccessWithValidation extends AuthState {
  final UserModel user;

  const AuthSuccessWithValidation(this.user);

  @override
  List<Object?> get props => [user];
}

// Success state
class AuthSuccess extends AuthState {
  final UserModel user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// Form validation error state
class AuthValidationError extends AuthState {
  final String? emailError;
  final String? passwordError;
  final String? nameError;

  const AuthValidationError({
    this.emailError,
    this.passwordError,
    this.nameError,
  });

  @override
  List<Object?> get props => [emailError, passwordError, nameError];
}