import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import '../../data/models/user_goal.dart';
import '../../data/models/onboarding_data.dart';

class OnboardingCubitAllData extends Cubit<OnboardingState> {
  OnboardingData _data = OnboardingData();

  // Credentials saved from SignUpScreen
  String? _name;
  String? _email;
  String? _password;

  OnboardingCubitAllData() : super(OnboardingInitial());

  OnboardingData get currentData => _data;

  // ── Save credentials from SignUpScreen ────────────────────────────────────

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
    final weeksNeeded   = diff / weeklyRate;
    final targetDate    = DateTime.now().add(
      Duration(days: (weeksNeeded * 7).round()),
    );

    _data = _data.copyWith(
      targetWeight: targetWeight,
      targetDate: targetDate,
    );
    emit(OnboardingDataUpdated(_data));
  }

  // ── Final step: call API ──────────────────────────────────────────────────
  // Called from the last onboarding screen (e.g. PlanSummaryScreen).
  // Delegates the actual HTTP request to AuthCubit.

  Future<void> completeSignUp(AuthCubit authCubit) async {
    // Validate all required data is present
    if (_name == null || _email == null || _password == null) {
      emit(const OnboardingError('Missing account credentials'));
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

    emit(OnboardingLoading());

    // Calculate date_of_birth from age
    final birthYear  = DateTime.now().year - _data.age!.toInt();
    final dateOfBirth = '$birthYear-01-01';

    // Delegate to AuthCubit - it will emit AuthSuccess or AuthError
    await authCubit.signUp(
      name:        _name!,
      email:       _email!,
      password:    _password!,
      gender:      _data.gender!,
      dateOfBirth: dateOfBirth,
      height:      _data.height!,
      weight:      _data.weight!,
    );

    // If AuthCubit emitted AuthSuccess, mark onboarding complete
    emit(OnboardingComplete(_data));
  }

  Future<void> saveGoal() async {
    if (_data.goal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }
    emit(OnboardingLoading());
    await Future.delayed(const Duration(milliseconds: 800));
    emit(OnboardingDataUpdated(_data));
  }

  void reset() {
    _data     = OnboardingData();
    _name     = null;
    _email    = null;
    _password = null;
    emit(OnboardingInitial());
  }
}