import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import '../../data/models/user_goal.dart';
import '../../data/models/onboarding_data.dart';

class OnboardingCubitAllData extends Cubit<OnboardingState> {
  OnboardingData _data = OnboardingData();

  OnboardingCubitAllData() : super(OnboardingInitial());

  OnboardingData get currentData => _data;

  void setGender(String gender) {
    _data = _data.copyWith(gender: gender);
    emit(OnboardingDataUpdated(_data));
    print('✅ Gender set: $gender');
  }

  void setHeight(double height) {
    _data = _data.copyWith(height: height);
    emit(OnboardingDataUpdated(_data));
    print('✅ Height set: $height cm');
  }

  void setWeight(double weight) {
    _data = _data.copyWith(weight: weight);
    emit(OnboardingDataUpdated(_data));
    print('✅ Weight set: $weight kg');
  }

  void setAge(double age) {
    _data = _data.copyWith(age: age);
    emit(OnboardingDataUpdated(_data));
    print('✅ Age set: $age years');
  }

  void selectGoal(UserGoal goal) {
    _data = _data.copyWith(goal: goal);
    emit(GoalSelected(goal));
    print('✅ Goal selected: ${goal.type}');
  }
  void setWeightPerWeek(double weightPerWeek) {
    _data = _data.copyWith(weightPerWeek: weightPerWeek);
    emit(OnboardingDataUpdated(_data));
    print('✅ Weight per week set: $weightPerWeek kg');
  }

  void setTargetWeight(double targetWeight) {
    // calc auto target date
    final currentWeight = _data.weight ?? 0;
    final weeklyRate = _data.weightPerWeek ?? 0.75;
    final diff = (targetWeight - currentWeight).abs();
    final weeksNeeded = diff / weeklyRate;
    final targetDate = DateTime.now().add(
      Duration(days: (weeksNeeded * 7).round()),
    );

    _data = _data.copyWith(
      targetWeight: targetWeight,
      targetDate: targetDate,
    );
    emit(OnboardingDataUpdated(_data));
    print('✅ Target weight set: $targetWeight kg');
    print('📅 Target date: $targetDate');
  }

  Future<void> saveGoal() async {
    if (_data.goal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }

    emit(OnboardingLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      print('✅ Goal saved: ${_data.goal!.type}');
      emit(OnboardingDataUpdated(_data));
    } catch (e) {
      emit(OnboardingError('Failed to save goal: $e'));
    }
  }

  Future<void> saveOnboardingData() async {
    if (!_data.isComplete) {
      emit(const OnboardingError('Please complete all fields'));
      return;
    }

    emit(OnboardingLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      print('✅ All data saved!');
      print('📊 Final data: $_data');
      emit(OnboardingComplete(_data));
    } catch (e) {
      emit(OnboardingError('Failed to save data: $e'));
    }
  }

  void reset() {
    _data = OnboardingData();
    emit(OnboardingInitial());
  }
}