import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/onboarding_data.dart';
import 'package:vital_metrics/data/models/user_goal.dart';

import 'package:vital_metrics/data/repositories/onboarding_repository.dart';

import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';

import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';

const _kActivityLevelKey = 'onboarding_activity_level';
const _kGoalKey = 'onboarding_goal_type';

class OnboardingCubitAllData extends Cubit<OnboardingState> {
  OnboardingData _data = OnboardingData(activityLevel: ActivityLevel.low);

  String? _name;
  String? _email;
  String? _password;

  final OnboardingRepository _repo;

  OnboardingCubitAllData({OnboardingRepository? repo})
      : _repo = repo ?? OnboardingRepository(),
        super(OnboardingInitial()) {
    _loadPersistedData();
  }

  // =====================================================
  // LOAD PERSISTED DATA ON STARTUP
  // Loads both activity level and goal type from SharedPreferences
  // so _goalString() in main.dart never falls back to 'maintain'
  // after the first onboarding is completed
  // =====================================================

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load activity level
      final savedLevel = prefs.getString(_kActivityLevelKey);
      if (savedLevel != null) {
        final level = ActivityLevel.values.firstWhere(
          (e) => e.name == savedLevel,
          orElse: () => ActivityLevel.low,
        );
        _data = _data.copyWith(activityLevel: level);
        print('[OnboardingCubit] loaded activityLevel=$level');
      }

      // Load goal type
      final savedGoal = prefs.getString(_kGoalKey);
      if (savedGoal != null) {
        final matchingGoal = UserGoal.allGoals.firstWhere(
          (g) => g.type.name == savedGoal,
          orElse: () => UserGoal.allGoals.first,
        );
        _data = _data.copyWith(goal: matchingGoal);
        print('[OnboardingCubit] loaded goal=${matchingGoal.type.name}');
      }

      emit(OnboardingDataUpdated(_data));
    } catch (e) {
      print('[OnboardingCubit] _loadPersistedData error: $e');
    }
  }

  // =====================================================
  // SAVE ACTIVITY LEVEL TO SHARED PREFERENCES
  // =====================================================

  Future<void> _saveActivityLevel(ActivityLevel level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kActivityLevelKey, level.name);
    } catch (e) {
      print('[OnboardingCubit] _saveActivityLevel error: $e');
    }
  }

  // =====================================================
  // SAVE GOAL TO SHARED PREFERENCES
  // =====================================================

  Future<void> _saveGoal(UserGoal goal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kGoalKey, goal.type.name);
    } catch (e) {
      print('[OnboardingCubit] _saveGoal error: $e');
    }
  }

  // =====================================================
  // CURRENT DATA
  // =====================================================

  OnboardingData get currentData => _data;

  // =====================================================
  // CREDENTIALS
  // =====================================================

  void setCredentials({
    required String name,
    required String email,
    required String password,
  }) {
    _name = name;
    _email = email;
    _password = password;
  }

  // =====================================================
  // GENDER
  // =====================================================

  void setGender(String gender) {
    _data = _data.copyWith(gender: gender);
    emit(OnboardingDataUpdated(_data));
  }

  // =====================================================
  // HEIGHT
  // =====================================================

  void setHeight(double height) {
    _data = _data.copyWith(height: height);
    emit(OnboardingDataUpdated(_data));
  }

  // =====================================================
  // WEIGHT
  // =====================================================

  void setWeight(double weight) {
    _data = _data.copyWith(weight: weight);
    emit(OnboardingDataUpdated(_data));
  }

  // =====================================================
  // AGE
  // =====================================================

  void setAge(double age) {
    _data = _data.copyWith(age: age);
    emit(OnboardingDataUpdated(_data));
  }

  // =====================================================
  // ACTIVITY LEVEL
  // Saves to SharedPreferences so it persists across restarts
  // =====================================================

  void updateActivityLevel(ActivityLevel level) {
    _data = _data.copyWith(activityLevel: level);
    emit(OnboardingDataUpdated(_data));
    _saveActivityLevel(level);
  }

  // =====================================================
  // GOAL
  // Also saves to SharedPreferences so the goal survives restarts
  // and _goalString() in main.dart returns the correct value
  // =====================================================

  void selectGoal(UserGoal goal) {
    _data = _data.copyWith(goal: goal);
    emit(GoalSelected(goal));
    _saveGoal(goal);
  }

  // =====================================================
  // WEIGHT PER WEEK
  // =====================================================

  void setWeightPerWeek(double weightPerWeek) {
    _data = _data.copyWith(weightPerWeek: weightPerWeek);
    emit(OnboardingDataUpdated(_data));
  }

  // =====================================================
  // TARGET WEIGHT
  // =====================================================

  void setTargetWeight(double targetWeight) {
    final currentWeight = _data.weight ?? 0;
    final weeklyRate = _data.weightPerWeek ?? 0.75;
    final diff = (targetWeight - currentWeight).abs();
    final weeksNeeded = weeklyRate > 0 ? diff / weeklyRate : 0;
    final targetDate = DateTime.now().add(
      Duration(days: (weeksNeeded * 7).round()),
    );

    _data = _data.copyWith(
      targetWeight: targetWeight,
      targetDate: targetDate,
    );

    emit(OnboardingDataUpdated(_data));
  }

  // =====================================================
  // REGISTER USER
  // =====================================================

  Future<void> registerUser(AuthCubit authCubit) async {
    if (_name == null || _email == null || _password == null) {
      emit(const OnboardingError('Missing credentials. Please sign up again.'));
      return;
    }

    if (_data.gender == null ||
        _data.height == null ||
        _data.weight == null ||
        _data.age == null) {
      emit(const OnboardingError('Please complete all required fields.'));
      return;
    }

    emit(OnboardingLoading());

    try {
      final birthYear = DateTime.now().year - _data.age!.toInt();
      final dateOfBirth = '$birthYear-01-01';

      await authCubit.signUp(
        name: _name!,
        email: _email!,
        password: _password!,
        gender: _data.gender!.toLowerCase(),
        dateOfBirth: dateOfBirth,
        height: _data.height!,
        weight: _data.weight!,
      );

      final authState = authCubit.state;

      if (authState is AuthRegistrationSuccess) {
        emit(OnboardingDataUpdated(_data));
      } else if (authState is AuthError) {
        emit(OnboardingError(authState.message));
      } else if (authState is AuthValidationError) {
        final errors = [
          authState.nameError,
          authState.emailError,
          authState.passwordError,
        ].where((e) => e != null).join(', ');

        emit(OnboardingError(
          errors.isNotEmpty ? errors : 'Validation failed',
        ));
      } else {
        emit(const OnboardingError('Registration failed. Please try again.'));
      }
    } on ApiException catch (e) {
      emit(OnboardingError(e.message));
    } catch (e) {
      emit(OnboardingError('Registration failed: $e'));
    }
  }

  // =====================================================
  // SAVE GOAL
  // =====================================================

  Future<void> saveGoal() async {
    if (_data.goal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }

    emit(OnboardingLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(OnboardingDataUpdated(_data));
  }

  // =====================================================
  // COMPLETE ONBOARDING
  // =====================================================

  Future<void> completeOnboarding() async {
    if (_data.goal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }

    emit(OnboardingLoading());

    try {
      await _repo.saveGoal(
        goal: _data.goal!,
        currentWeight: _data.weight,
        targetWeight: _data.targetWeight,
        weightPerWeek: _data.weightPerWeek,
        targetDate: _data.targetDate,
      );

      // Persist goal locally so it survives app restarts
      await _saveGoal(_data.goal!);

      emit(OnboardingComplete(_data));
    } on ApiException catch (e) {
      if (e.statusCode == 409) {
        try {
          await _repo.updateGoal(
            goal: _data.goal!,
            targetWeight: _data.targetWeight,
            weightPerWeek: _data.weightPerWeek,
          );
        } catch (_) {
          print('[OnboardingCubit] updateGoal failed, proceeding anyway');
        }
        await _saveGoal(_data.goal!);
        emit(OnboardingComplete(_data));
      } else {
        print('[OnboardingCubit] saveGoal error ${e.statusCode}: ${e.message}, proceeding anyway');
        await _saveGoal(_data.goal!);
        emit(OnboardingComplete(_data));
      }
    } catch (e) {
      print('[OnboardingCubit] completeOnboarding unexpected error: $e, proceeding anyway');
      await _saveGoal(_data.goal!);
      emit(OnboardingComplete(_data));
    }
  }

  // =====================================================
  // RESET
  // =====================================================

  void reset() {
    _data = OnboardingData(activityLevel: ActivityLevel.low);
    _name = null;
    _email = null;
    _password = null;
    emit(OnboardingInitial());
  }
}