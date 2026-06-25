import 'package:equatable/equatable.dart';
import '/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial           extends AuthState {}
class AuthLoading           extends AuthState {}

class AuthSuccess extends AuthState {
  final UserModel user;
  const AuthSuccess(this.user);
  @override List<Object?> get props => [user];
}

class AuthAdminSuccess extends AuthState {
  final UserModel user;
  const AuthAdminSuccess(this.user);
  @override List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object?> get props => [message];
}

class AuthValidationError extends AuthState {
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  const AuthValidationError({
    this.nameError,
    this.emailError,
    this.passwordError,
  });
  @override List<Object?> get props => [nameError, emailError, passwordError];
}

class AuthRegistrationSuccess extends AuthState {
  final String email;
  final String tempToken;
  const AuthRegistrationSuccess({required this.email, required this.tempToken});
  @override List<Object?> get props => [email, tempToken];
}

class AuthSignInOTPSent extends AuthState {
  final String email;
  const AuthSignInOTPSent(this.email);
  @override List<Object?> get props => [email];
}

class AuthOTPVerified extends AuthState {
  final String email;
  const AuthOTPVerified(this.email);
  @override List<Object?> get props => [email];
}

class AuthOTPResent extends AuthState {
  final String   email;
  final DateTime timestamp;
  AuthOTPResent(this.email) : timestamp = DateTime.now();
  @override List<Object?> get props => [email, timestamp];
}

class AuthGoogleNeedsProfile extends AuthState {
  final String idToken;
  final String displayName;
  final String email;
  const AuthGoogleNeedsProfile({
    required this.idToken,
    required this.displayName,
    required this.email,
  });
  @override List<Object?> get props => [idToken, displayName, email];
}