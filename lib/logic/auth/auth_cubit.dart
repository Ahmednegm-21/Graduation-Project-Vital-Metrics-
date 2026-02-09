import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/exceptions/api_exception.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(AuthInitial());

  /// Email validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Password validation
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Name validation
  bool _isValidName(String name) {
    return name.trim().isNotEmpty && name.length >= 2;
  }

  /// Sign In
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Local validation
    String? emailError;
    String? passwordError;

    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(email)) {
      emailError = 'Invalid email format';
    }

    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (!_isValidPassword(password)) {
      passwordError = 'Password must be at least 6 characters';
    }

    if (emailError != null || passwordError != null) {
      emit(AuthValidationError(
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    // Call API
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
    } on UnauthorizedException catch (e) {
      emit(AuthError(e.message));
    } on NetworkException catch (e) {
      emit(AuthError(e.message));
    } on TimeoutException catch (e) {
      emit(AuthError(e.message));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  /// Sign Up
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Local validation
    String? nameError;
    String? emailError;
    String? passwordError;

    if (name.isEmpty) {
      nameError = 'Name is required';
    } else if (!_isValidName(name)) {
      nameError = 'Name must be at least 2 characters';
    }

    if (email.isEmpty) {
      emailError = 'Email is required';
    } else if (!_isValidEmail(email)) {
      emailError = 'Invalid email format';
    }

    if (password.isEmpty) {
      passwordError = 'Password is required';
    } else if (!_isValidPassword(password)) {
      passwordError = 'Password must be at least 6 characters';
    }

    if (nameError != null || emailError != null || passwordError != null) {
      emit(AuthValidationError(
        nameError: nameError,
        emailError: emailError,
        passwordError: passwordError,
      ));
      return;
    }

    // Call API
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
    } on NetworkException catch (e) {
      emit(AuthError(e.message));
    } on TimeoutException catch (e) {
      emit(AuthError(e.message));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthError('Google Sign-In is not implemented yet.'));
  }

  /// Sign in with Facebook
  Future<void> signInWithFacebook() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthError('Facebook Sign-In is not implemented yet.'));
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authRepository.signOut();
      emit(AuthInitial());
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to sign out. Please try again.'));
    }
  }

  /// Check Auth Status (for auto-login)
  Future<void> checkAuthStatus() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authRepository.getUserProfile();
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  /// Reset to initial state
  void reset() {
    emit(AuthInitial());
  }

  @override
  Future<void> close() {
    _authRepository.dispose();
    return super.close();
  }
}