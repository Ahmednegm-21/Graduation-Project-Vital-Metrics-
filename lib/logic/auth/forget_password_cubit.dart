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

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isValidPassword(String password) => password.length >= 8;

  // ── Step 1: Send reset email ──────────────────────────────────────────────
  // POST /auth/reset-password → { email }
  // 200 → OTP sent
  // 404 → email does not exist

  Future<void> sendResetEmail({required String email}) async {
    if (email.isEmpty) {
      emit(const ForgotPasswordValidationError(emailError: 'Email is required'));
      return;
    }
    if (!_isValidEmail(email)) {
      emit(const ForgotPasswordValidationError(emailError: 'Invalid email format'));
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      await _authRepository.sendResetEmail(email: email);
      emit(ForgotPasswordEmailSent());
    } on ApiException catch (e) {
      emit(ForgotPasswordError(e.message));
    } catch (_) {
      emit(ForgotPasswordError('An unexpected error occurred. Please try again.'));
    }
  }

  // ── Step 2: Verify OTP ────────────────────────────────────────────────────
  // POST /auth/verify-otp → { email, code, purpose: "reset_password" }
  // 200 → OTP verified
  // 400 → invalid or expired OTP
  // 404 → email does not exist

  Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (otp.length < 6) {
      emit(const ForgotPasswordValidationError(
          otpError: 'Please enter the 6-digit code'));
      return;
    }

    emit(ForgotPasswordLoading());

    try {
      await _authRepository.verifyOtp(email: email, otp: otp);
      emit(ForgotPasswordOtpVerified());
    } on ApiException catch (e) {
      emit(ForgotPasswordError(e.message));
    } catch (_) {
      emit(ForgotPasswordError('An unexpected error occurred. Please try again.'));
    }
  }

  // ── Step 3: Reset password ────────────────────────────────────────────────
  // POST /auth/reset-password/confirm
  // Body: { email, code, newPassword, confirmPassword }
  // 200 → password reset successfully
  // 400 → invalid OTP, expired OTP, or passwords do not match
  // 404 → email does not exist

  Future<void> resetPasswordConfirm({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final passwordError = newPassword.isEmpty
        ? 'Password is required'
        : !_isValidPassword(newPassword)
            ? 'Password must be at least 8 characters'
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
        email:           email,
        otp:             otp,
        newPassword:     newPassword,
        confirmPassword: confirmPassword,
      );
      emit(ForgotPasswordResetSuccess());
    } on ApiException catch (e) {
      emit(ForgotPasswordError(e.message));
    } catch (_) {
      emit(ForgotPasswordError('An unexpected error occurred. Please try again.'));
    }
  }

  void reset() => emit(ForgotPasswordInitial());
}