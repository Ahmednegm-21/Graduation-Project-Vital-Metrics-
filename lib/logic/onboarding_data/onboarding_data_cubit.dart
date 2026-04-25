import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/data/repositories/onboarding_repository.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import '../../data/models/user_goal.dart';
import '../../data/models/onboarding_data.dart';

class OnboardingCubitAllData extends Cubit<OnboardingState> {
  OnboardingData _data = OnboardingData();

  String? _name;
  String? _email;
  String? _password;

  final OnboardingRepository _repo;

  OnboardingCubitAllData({OnboardingRepository? repo})
      : _repo = repo ?? OnboardingRepository(),
        super(OnboardingInitial());

  OnboardingData get currentData => _data;

  // ── Credentials ───────────────────────────────────────────────────────────

  void setCredentials({
    required String name,
    required String email,
    required String password,
  }) {
    _name     = name;
    _email    = email;
    _password = password;
  }

  // ── Onboarding setters ────────────────────────────────────────────────────

  void setGender(String gender) {
    _data = _data.copyWith(gender: gender);
    emit(OnboardingDataUpdated(_data));
  }

  void setHeight(double height) {
    _data = _data.copyWith(height: height);
    emit(OnboardingDataUpdated(_data));
  }

  void setWeight(double weight) {
    _data = _data.copyWith(weight: weight);
    emit(OnboardingDataUpdated(_data));
  }

  void setAge(double age) {
    _data = _data.copyWith(age: age);
    emit(OnboardingDataUpdated(_data));
  }

  void selectGoal(UserGoal goal) {
    _data = _data.copyWith(goal: goal);
    emit(GoalSelected(goal));
  }

  void setWeightPerWeek(double weightPerWeek) {
    _data = _data.copyWith(weightPerWeek: weightPerWeek);
    emit(OnboardingDataUpdated(_data));
  }

  void setTargetWeight(double targetWeight) {
    final currentWeight = _data.weight ?? 0;
    final weeklyRate    = _data.weightPerWeek ?? 0.75;
    final diff          = (targetWeight - currentWeight).abs();
    final weeksNeeded   = weeklyRate > 0 ? diff / weeklyRate : 0;
    final targetDate    = DateTime.now().add(
      Duration(days: (weeksNeeded * 7).round()),
    );
    _data = _data.copyWith(targetWeight: targetWeight, targetDate: targetDate);
    emit(OnboardingDataUpdated(_data));
  }

  // ── Step 3: Register user after Age screen ────────────────────────────────
  // Calls signUp API → emits AuthRegistrationSuccess → UI navigates to OTP screen

  Future<void> registerUser(AuthCubit authCubit) async {
    if (_name == null || _email == null || _password == null) {
      emit(const OnboardingError('Missing credentials. Please sign up again.'));
      return;
    }
    if (_data.gender == null || _data.height == null ||
        _data.weight == null   || _data.age == null) {
      emit(const OnboardingError('Please complete all required fields.'));
      return;
    }

    emit(OnboardingLoading());

    try {
      final birthYear   = DateTime.now().year - _data.age!.toInt();
      final dateOfBirth = '$birthYear-01-01';

      await authCubit.signUp(
        name:        _name!,
        email:       _email!,
        password:    _password!,
        gender:      _data.gender!.toLowerCase(),
        dateOfBirth: dateOfBirth,
        height:      _data.height!,
        weight:      _data.weight!,
      );

      // Wait for AuthCubit state
      await Future.delayed(const Duration(milliseconds: 300));

      final authState = authCubit.state;

      if (authState is AuthRegistrationSuccess) {
        // Registration done - OTP sent - UI will navigate to OTP screen
        emit(OnboardingDataUpdated(_data));
      } else if (authState is AuthError) {
        emit(OnboardingError(authState.message));
      } else if (authState is AuthValidationError) {
        final errors = [
          authState.nameError,
          authState.emailError,
          authState.passwordError,
        ].where((e) => e != null).join(', ');
        emit(OnboardingError(errors));
      }
    } on ApiException catch (e) {
      emit(OnboardingError(e.message));
    } catch (e) {
      emit(OnboardingError('Registration failed. Please try again.'));
    }
  }

  // ── saveGoal: local transition only ──────────────────────────────────────

  Future<void> saveGoal() async {
    if (_data.goal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }
    emit(OnboardingLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(OnboardingDataUpdated(_data));
  }

  // ── Step 9: Complete onboarding - save goal data ──────────────────────────
  // Called from GetMyPlanScreen "Get Your Plan" button.

  Future<void> completeOnboarding() async {
    if (_data.goal == null || _data.targetWeight == null) {
      emit(const OnboardingError('Please complete all goal information'));
      return;
    }

    emit(OnboardingLoading());

    try {
      await _repo.saveGoal(
        goal:          _data.goal!,
        targetWeight:  _data.targetWeight,
        weightPerWeek: _data.weightPerWeek,
        targetDate:    _data.targetDate,
      );

      await _repo.completeOnboarding();

      emit(OnboardingComplete(_data));
    } on ApiException catch (e) {
      emit(OnboardingError(e.message));
    } catch (e) {
      emit(OnboardingError('Failed to complete onboarding. Please try again.'));
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    _data     = OnboardingData();
    _name     = null;
    _email    = null;
    _password = null;
    emit(OnboardingInitial());
  }
}