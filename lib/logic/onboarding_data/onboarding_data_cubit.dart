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

  // ── Save credentials from SignUpScreen ────────────────────────────────────
  void setCredentials({
    required String name,
    required String email,
    required String password,
  }) {
    _name     = name;
    _email    = email;
    _password = password;
    
    print('✅ Credentials saved:');
    print('  Name: $_name');
    print('  Email: $_email');
    print('  Password: ${_password?.isNotEmpty == true ? "Set" : "Not set"}');
  }

  // ── Gender ────────────────────────────────────────────────────────────────
  void setGender(String gender) {
    _data = _data.copyWith(gender: gender);
    print('✅ Gender set: $gender');
    emit(OnboardingDataUpdated(_data));
  }

  // ── Height ────────────────────────────────────────────────────────────────
  void setHeight(double height) {
    _data = _data.copyWith(height: height);
    print('✅ Height set: $height cm');
    emit(OnboardingDataUpdated(_data));
  }

  // ── Weight ────────────────────────────────────────────────────────────────
  void setWeight(double weight) {
    _data = _data.copyWith(weight: weight);
    print('✅ Weight set: $weight kg');
    emit(OnboardingDataUpdated(_data));
  }

  // ── Age ───────────────────────────────────────────────────────────────────
  void setAge(double age) {
    _data = _data.copyWith(age: age);
    print('✅ Age set: $age years');
    emit(OnboardingDataUpdated(_data));
  }

  // ── Goal ──────────────────────────────────────────────────────────────────
  void selectGoal(UserGoal goal) {
    _data = _data.copyWith(goal: goal);
    print('✅ Goal selected: ${goal.type}');
    emit(GoalSelected(goal));
  }

  // ── Weight per week ───────────────────────────────────────────────────────
  void setWeightPerWeek(double weightPerWeek) {
    _data = _data.copyWith(weightPerWeek: weightPerWeek);
    print('✅ Weight per week set: $weightPerWeek kg/week');
    emit(OnboardingDataUpdated(_data));
  }

  // ── Target weight ─────────────────────────────────────────────────────────
  void setTargetWeight(double targetWeight) {
    final currentWeight = _data.weight ?? 0;
    final weeklyRate    = _data.weightPerWeek ?? 0.75;
    final diff          = (targetWeight - currentWeight).abs();
    final weeksNeeded   = weeklyRate > 0 ? diff / weeklyRate : 0;
    final targetDate    = DateTime.now().add(
      Duration(days: (weeksNeeded * 7).round()),
    );
    
    _data = _data.copyWith(
      targetWeight: targetWeight,
      targetDate: targetDate,
    );
    
    print('✅ Target weight set: $targetWeight kg');
    print('✅ Target date calculated: $targetDate');
    
    emit(OnboardingDataUpdated(_data));
  }

  // ── Save goal (just local, no backend) ────────────────────────────────────
  Future<void> saveGoal() async {
    if (_data.goal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }
    emit(OnboardingLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(OnboardingDataUpdated(_data));
  }

  // ── ✅ MAIN METHOD: Complete Sign Up + Onboarding ─────────────────────────
  Future<void> completeSignUpAndOnboarding(AuthCubit authCubit) async {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🚀 STARTING COMPLETE SIGN UP PROCESS');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    // ── Step 1: Validate all required data ────────────────────────────────────
    print('\n📋 STEP 1: Validating all data...');
    
    final List<String> missingFields = [];
    
    if (_name == null || _name!.isEmpty) {
      missingFields.add('Name');
    }
    if (_email == null || _email!.isEmpty) {
      missingFields.add('Email');
    }
    if (_password == null || _password!.isEmpty) {
      missingFields.add('Password');
    }
    if (_data.gender == null) {
      missingFields.add('Gender');
    }
    if (_data.age == null) {
      missingFields.add('Age');
    }
    if (_data.height == null) {
      missingFields.add('Height');
    }
    if (_data.weight == null) {
      missingFields.add('Weight');
    }
    if (_data.goal == null) {
      missingFields.add('Goal');
    }
    if (_data.targetWeight == null) {
      missingFields.add('Target Weight');
    }
    if (_data.weightPerWeek == null) {
      missingFields.add('Weight per Week');
    }
    
    if (missingFields.isNotEmpty) {
      final errorMsg = 'Missing required fields: ${missingFields.join(", ")}';
      print('❌ VALIDATION FAILED: $errorMsg');
      emit(OnboardingError(errorMsg));
      return;
    }
    
    print('✅ All required data is present');
    
    // ── Step 2: Display all data ──────────────────────────────────────────────
    print('\n📊 STEP 2: Complete data summary:');
    print('┌─────────────────────────────────────────┐');
    print('│ ACCOUNT CREDENTIALS                     │');
    print('├─────────────────────────────────────────┤');
    print('│ Name:           $_name');
    print('│ Email:          $_email');
    print('│ Password:       ${_password!.length} characters');
    print('├─────────────────────────────────────────┤');
    print('│ PERSONAL INFO                           │');
    print('├─────────────────────────────────────────┤');
    print('│ Gender:         ${_data.gender}');
    print('│ Age:            ${_data.age} years');
    print('│ Height:         ${_data.height} cm');
    print('│ Weight:         ${_data.weight} kg');
    print('├─────────────────────────────────────────┤');
    print('│ GOALS                                   │');
    print('├─────────────────────────────────────────┤');
    print('│ Goal:           ${_data.goal?.type}');
    print('│ Target Weight:  ${_data.targetWeight} kg');
    print('│ Weekly Rate:    ${_data.weightPerWeek} kg/week');
    print('│ Target Date:    ${_data.targetDate}');
    print('└─────────────────────────────────────────┘');

    emit(OnboardingLoading());

    try {
      // ── Step 3: Prepare registration data ─────────────────────────────────
      print('\n🔧 STEP 3: Preparing registration data...');
      
      final birthYear   = DateTime.now().year - _data.age!.toInt();
      final dateOfBirth = '$birthYear-01-01';
      
      print('  Date of Birth: $dateOfBirth');
      print('  Gender (lowercase): ${_data.gender!.toLowerCase()}');

      // ── Step 4: Register user ─────────────────────────────────────────────
      print('\n📤 STEP 4: Sending registration request to backend...');
      print('  Endpoint: POST /auth/register');
      
      await authCubit.signUp(
        name:        _name!,
        email:       _email!,
        password:    _password!,
        gender:      _data.gender!.toLowerCase(),
        dateOfBirth: dateOfBirth,
        height:      _data.height!,
        weight:      _data.weight!,
      );

      // Check if registration failed
      await Future.delayed(const Duration(milliseconds: 500)); // Wait for auth state
      
      if (authCubit.state is AuthError) {
        final errorMessage = (authCubit.state as AuthError).message;
        print('❌ REGISTRATION FAILED: $errorMessage');
        emit(OnboardingError(errorMessage));
        return;
      } else if (authCubit.state is AuthValidationError) {
        final validationState = authCubit.state as AuthValidationError;
        final errors = [
          validationState.nameError,
          validationState.emailError,
          validationState.passwordError,
        ].where((e) => e != null).join(', ');
        print('❌ VALIDATION ERROR: $errors');
        emit(OnboardingError(errors));
        return;
      }
      
      print('✅ Registration successful!');

      // ── Step 5: Save goal data ────────────────────────────────────────────
      print('\n📤 STEP 5: Saving goal data to backend...');
      
      await _repo.saveGoal(
        goal: _data.goal!,
        targetWeight: _data.targetWeight,
        weightPerWeek: _data.weightPerWeek,
        targetDate: _data.targetDate,
      );
      
      print('✅ Goal data saved successfully!');

      // ── Step 6: Mark onboarding as complete ───────────────────────────────
      print('\n📤 STEP 6: Marking onboarding as complete...');
      
      await _repo.completeOnboarding();
      
      print('✅ Onboarding marked as complete!');

      // ── Step 7: Refresh user profile ──────────────────────────────────────
      print('\n📤 STEP 7: Refreshing user profile...');
      
      await authCubit.checkAuthStatus();
      
      print('✅ Profile refreshed!');
      
      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🎉 SIGN UP PROCESS COMPLETED SUCCESSFULLY!');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      emit(OnboardingComplete(_data));
      
    } on ApiException catch (e) {
      print('\n❌ API EXCEPTION:');
      print('  Message: ${e.message}');
      print('  Type: ${e.runtimeType}');
      emit(OnboardingError(e.message));
    } catch (e, stackTrace) {
      print('\n❌ UNKNOWN ERROR:');
      print('  Error: $e');
      print('  Stack trace: $stackTrace');
      emit(OnboardingError('Registration failed. Please try again.'));
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    print('🔄 Resetting onboarding data...');
    _data     = OnboardingData();
    _name     = null;
    _email    = null;
    _password = null;
    emit(OnboardingInitial());
  }
}