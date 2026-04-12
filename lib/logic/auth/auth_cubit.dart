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

  bool _isValidPassword(String password) => password.length >= 6;

  bool _isValidName(String name) =>
      name.trim().isNotEmpty && name.trim().length >= 2;

  // ── Auth actions ──────────────────────────────────────────────────────────

  /// Validate locally then call sign-in API.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Local validation first (no API call)
    final emailError = email.isEmpty
        ? 'Email is required'
        : !_isValidEmail(email)
            ? 'Invalid email format'
            : null;

    final passwordError = password.isEmpty
        ? 'Password is required'
        : !_isValidPassword(password)
            ? 'Password must be at least 6 characters'
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

  /// Validate locally then call sign-up API.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Local validation first (no API call)
    final nameError = name.isEmpty
        ? 'Name is required'
        : !_isValidName(name)
            ? 'Name must be at least 2 characters'
            : null;

    final emailError = email.isEmpty
        ? 'Email is required'
        : !_isValidEmail(email)
            ? 'Invalid email format'
            : null;

    final passwordError = password.isEmpty
        ? 'Password is required'
        : !_isValidPassword(password)
            ? 'Password must be at least 6 characters'
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

  /// Sign out and clear local tokens.
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

  /// Check stored token on app start for auto-login.
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
      // Treat any error as "not logged in"
      emit(AuthInitial());
    }
  }

  /// Placeholder until Google Sign-In is implemented.
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthError('Google Sign-In is not implemented yet.'));
  }

  /// Reset state back to initial.
  void reset() => emit(AuthInitial());

  @override
  Future<void> close() {
    _authRepository.dispose();
    return super.close();
  }
}