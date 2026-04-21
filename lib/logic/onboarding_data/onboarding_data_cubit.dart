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

  void setCredentials({
    required String name,
    required String email,
    required String password,
  }) {
    _name     = name;
    _email    = email;
    _password = password;
  }

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

  Future<void> saveGoal() async {
    if (_data.goal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }
    emit(OnboardingLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(OnboardingDataUpdated(_data));
  }

  /// Complete registration + send all onboarding data
  Future<void> completeSignUpAndOnboarding(AuthCubit authCubit) async {
    // ── Validation ────────────────────────────────────────────────────────────
    if (_name == null || _email == null || _password == null) {
      emit(const OnboardingError('Missing credentials. Please sign up again.'));
      return;
    }
    if (_data.gender == null) {
      emit(const OnboardingError('Please select your gender'));
      return;
    }
    if (_data.age == null) {
      emit(const OnboardingError('Please enter your age'));
      return;
    }
    if (_data.height == null) {
      emit(const OnboardingError('Please enter your height'));
      return;
    }
    if (_data.weight == null) {
      emit(const OnboardingError('Please enter your weight'));
      return;
    }
    if (_data.goal == null) {
      emit(const OnboardingError('Please select your goal'));
      return;
    }
    if (_data.targetWeight == null) {
      emit(const OnboardingError('Please set your target weight'));
      return;
    }

    emit(OnboardingLoading());

    try {
      // ── Step 1: Register user ────────────────────────────────────────────────
      final birthYear   = DateTime.now().year - _data.age!.toInt();
      final dateOfBirth = '$birthYear-01-01';

      await authCubit.signUp(
        name:        _name!,
        email:       _email!,
        password:    _password!,
        gender:      _data.gender!,
        dateOfBirth: dateOfBirth,
        height:      _data.height!,
        weight:      _data.weight!,
      );

      // Check if registration failed
      if (authCubit.state is AuthError) {
        emit(OnboardingError((authCubit.state as AuthError).message));
        return;
      }

      // ── Step 2: Save goal data ──────────────────────────────────────────────
      await _repo.saveGoal(
        goal: _data.goal!,
        targetWeight: _data.targetWeight,
        weightPerWeek: _data.weightPerWeek,
        targetDate: _data.targetDate,
      );

      // ── Step 3: Mark onboarding as complete ────────────────────────────────
      await _repo.completeOnboarding();

      emit(OnboardingComplete(_data));
    } on ApiException catch (e) {
      emit(OnboardingError(e.message));
    } catch (e) {
      emit(OnboardingError('Registration failed. Please try again.'));
    }
  }

  void reset() {
    _data     = OnboardingData();
    _name     = null;
    _email    = null;
    _password = null;
    emit(OnboardingInitial());
  }
}