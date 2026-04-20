import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/auth/forget_password_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/exceptions/api_exception.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(ForgotPasswordInitial());

  // ── Validation helpers ────────────────────────────────────────────────────

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) => password.length >= 6;

  // ── Step 1: Send reset email ──────────────────────────────────────────────

  Future<void> sendResetEmail({required String email}) async {
    // Local validation first
    if (email.isEmpty) {
      emit(const ForgotPasswordValidationError(
          emailError: 'Email is required'));
      return;
    }
    if (!_isValidEmail(email)) {
      emit(const ForgotPasswordValidationError(
          emailError: 'Invalid email format'));
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      await _authRepository.sendResetEmail(email: email);
      emit(ForgotPasswordEmailSent());
    } on ApiException catch (e) {
      emit(ForgotPasswordError(e.message));
    } catch (_) {
      emit(ForgotPasswordError(
          'An unexpected error occurred. Please try again.'));
    }
  }

  // ── Step 2: Verify OTP ────────────────────────────────────────────────────

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    // Local validation first
    if (otp.length < 5) {
      emit(const ForgotPasswordValidationError(
          otpError: 'Please enter the 5-digit code'));
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      await _authRepository.verifyOtp(email: email, otp: otp);
      emit(ForgotPasswordOtpVerified());
    } on ApiException catch (e) {
      emit(ForgotPasswordError(e.message));
    } catch (_) {
      emit(ForgotPasswordError(
          'An unexpected error occurred. Please try again.'));
    }

// TODO: remove this when backend is ready
// await Future.delayed(const Duration(seconds: 1));
// emit(ForgotPasswordOtpVerified());
  }

  // ── Step 3: Reset password ────────────────────────────────────────────────

  Future<void> resetPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Local validation first
    final passwordError = newPassword.isEmpty
        ? 'Password is required'
        : !_isValidPassword(newPassword)
            ? 'Password must be at least 6 characters'
            : null;

    final confirmError = confirmPassword.isEmpty
        ? 'Please confirm your password'
        : newPassword != confirmPassword
            ? 'Passwords do not match'
            : null;

    if (passwordError != null || confirmError != null) {
      emit(ForgotPasswordValidationError(
        passwordError: passwordError,
        confirmPasswordError: confirmError,
      ));
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      await _authRepository.resetPasswordConfirm(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      emit(ForgotPasswordResetSuccess());
    } on ApiException catch (e) {
      emit(ForgotPasswordError(e.message));
    } catch (_) {
      emit(ForgotPasswordError(
          'An unexpected error occurred. Please try again.'));
    }
  }

  /// Reset state back to initial
  void reset() => emit(ForgotPasswordInitial());
}