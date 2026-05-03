import 'package:equatable/equatable.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ForgotPasswordInitial extends ForgotPasswordState {}

/// Waiting for API response
class ForgotPasswordLoading extends ForgotPasswordState {}

/// Step 1 done - OTP sent to email
class ForgotPasswordEmailSent extends ForgotPasswordState {}

/// Step 2 done - OTP verified successfully
class ForgotPasswordOtpVerified extends ForgotPasswordState {}

/// Step 3 done - Password reset successfully
class ForgotPasswordResetSuccess extends ForgotPasswordState {}

/// General API / network error
class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Local form validation failed
class ForgotPasswordValidationError extends ForgotPasswordState {
  final String? emailError;
  final String? otpError;
  final String? passwordError;
  final String? confirmPasswordError;

  const ForgotPasswordValidationError({
    this.emailError,
    this.otpError,
    this.passwordError,
    this.confirmPasswordError,
  });

  @override
  List<Object?> get props =>
      [emailError, otpError, passwordError, confirmPasswordError];
}