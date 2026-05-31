import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/repositories/auth_repository.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/services/local_data_clear_service.dart';

const _kLastSignedInEmail = 'auth_last_signed_in_email';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  bool _isSignInFlow = false;
  String? _lastSignedInEmail;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial()) {
    _loadLastEmail();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _loadLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSignedInEmail = prefs.getString(_kLastSignedInEmail);
  }

  Future<void> _saveLastEmail(String email) async {
    _lastSignedInEmail = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastSignedInEmail, email);
  }

  Future<void> _clearLastEmail() async {
    _lastSignedInEmail = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastSignedInEmail);
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  bool _isValidPassword(String password) => password.length >= 8;
  bool _isValidName(String name) =>
      name.trim().isNotEmpty && name.trim().length >= 3;

  // ── Sign In ───────────────────────────────────────────────────────────────

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final emailError = email.isEmpty
        ? 'Email is required'
        : !_isValidEmail(email)
            ? 'Invalid email format'
            : null;

    final passwordError = password.isEmpty
        ? 'Password is required'
        : !_isValidPassword(password)
            ? 'Password must be at least 8 characters'
            : null;

    if (emailError != null || passwordError != null) {
      emit(AuthValidationError(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(AuthLoading());

    try {
      final isVerified = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (isVerified) {
        // لو اليوزر اتغير، امسح الداتا القديمة
        if (_lastSignedInEmail != null && _lastSignedInEmail != email) {
          await LocalDataClearService.clearAll();
          print('[AuthCubit] user changed — local data cleared');
        }
        await _saveLastEmail(email);

        final user = await _authRepository.getUserProfile();
        emit(AuthSuccess(user));
      } else {
        _isSignInFlow = true;
        emit(AuthSignInOTPSent(email));
      }
    } on ValidationException catch (e) {
      final errors = e.errors ?? {};
      emit(AuthValidationError(
        emailError: errors['email']?.toString(),
        passwordError: errors['password']?.toString(),
      ));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,
    required String dateOfBirth,
    required double height,
    required double weight,
  }) async {
    final nameError = name.isEmpty
        ? 'Name is required'
        : !_isValidName(name)
            ? 'Name must be at least 3 characters'
            : null;

    final emailError = email.isEmpty
        ? 'Email is required'
        : !_isValidEmail(email)
            ? 'Invalid email format'
            : null;

    final passwordError = password.isEmpty
        ? 'Password is required'
        : !_isValidPassword(password)
            ? 'Password must be at least 8 characters'
            : null;

    if (nameError != null || emailError != null || passwordError != null) {
      emit(AuthValidationError(
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(AuthLoading());

    try {
      // امسح الداتا القديمة عند تسجيل يوزر جديد
      await LocalDataClearService.clearAll();
      print('[AuthCubit] new user signup — local data cleared');

      final resultEmail = await _authRepository.signUp(
        name:        name,
        email:       email,
        password:    password,
        gender:      gender,
        dateOfBirth: dateOfBirth,
        height:      height,
        weight:      weight,
      );

      _isSignInFlow = false;
      await _saveLastEmail(email);
      emit(AuthRegistrationSuccess(email: resultEmail, tempToken: ''));
    } on ValidationException catch (e) {
      final errors = e.errors ?? {};
      emit(AuthValidationError(
        nameError:     errors['name']?.toString(),
        emailError:    errors['email']?.toString(),
        passwordError: errors['password']?.toString(),
      ));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('Registration failed. Please try again.'));
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────

  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyOTP(
        email:   email,
        otp:     otp,
        purpose: 'verify_email',
      );

      if (_isSignInFlow) {
        if (_lastSignedInEmail != null && _lastSignedInEmail != email) {
          await LocalDataClearService.clearAll();
          print('[AuthCubit] user changed via OTP — local data cleared');
        }
        await _saveLastEmail(email);

        final user = await _authRepository.getUserProfile();
        _isSignInFlow = false;
        emit(AuthSuccess(user));
      } else {
        emit(AuthOTPVerified(email));
      }
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('OTP verification failed. Please try again.'));
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────

  Future<void> resendOTP(String email) async {
    emit(AuthOTPResent(email));
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      await LocalDataClearService.clearAll();
      await _clearLastEmail();
      emit(AuthInitial());
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('Failed to sign out. Please try again.'));
    }
  }

  // ── Check auth status on app start ───────────────────────────────────────

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getUserProfile();
        await _saveLastEmail(user.email);
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    } catch (_) {
      emit(AuthInitial());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthError('Google Sign-In is not implemented yet.'));
  }

  void reset() {
    _isSignInFlow = false;
    emit(AuthInitial());
  }

  @override
  Future<void> close() {
    _authRepository.dispose();
    return super.close();
  }
}