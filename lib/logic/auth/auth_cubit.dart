import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/exceptions/api_exception.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial());

  // ── Validation helpers ────────────────────────────────────────────────────

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Backend requires >= 8 characters
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
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      emit(AuthSuccess(user));
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

  // ── Sign Up - called AFTER onboarding is complete ─────────────────────────
  // Receives all data at once and sends a single API request.

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String gender,       // 'male' | 'female'
    required String dateOfBirth,  // 'YYYY-MM-DD'
    required double height,       // cm
    required double weight,       // kg
  }) async {
    // Local validation
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
      final user = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
      );
      emit(AuthSuccess(user));
    } on ValidationException catch (e) {
      final errors = e.errors ?? {};
      emit(AuthValidationError(
        nameError: errors['name']?.toString(),
        emailError: errors['email']?.toString(),
        passwordError: errors['password']?.toString(),
      ));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthInitial());
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('Failed to sign out. Please try again.'));
    }
  }

  // ── Auto-login on app start ───────────────────────────────────────────────

  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getUserProfile();
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

  void reset() => emit(AuthInitial());

  @override
  Future<void> close() {
    _authRepository.dispose();
    return super.close();
  }
}