import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/user-goal/user_goal_dart_state.dart';
import '../../data/models/user_goal.dart';
// import '../../data/repositories/onboarding_repository.dart';
// import '../../data/exceptions/api_exception.dart';

class OnboardingGoalCubit extends Cubit<OnboardingState> {
  // final OnboardingRepository _repository;
  UserGoal? selectedGoal;

  OnboardingGoalCubit(
    // {OnboardingRepository? repository}
  ) : // _repository = repository ?? OnboardingRepository(),
      super(OnboardingInitial());

  /// Select a goal (just UI , not saved yet)
  void selectGoal(UserGoal goal) {
    selectedGoal = goal;
    emit(GoalSelected(goal));
  }

  /// Save goal to backend
  Future<void> saveGoal() async {
    if (selectedGoal == null) {
      emit(const OnboardingError('Please select a goal first'));
      return;
    }

    emit(OnboardingLoading());

    try {
      // await _repository.saveUserGoal(selectedGoal!);

      // For now, just simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      print('✅ Goal saved: ${selectedGoal!.type}');
      emit(GoalSaved(selectedGoal!));
    } catch (e) {
      print('❌ Error saving goal: $e');
      emit(OnboardingError('Failed to save goal: $e'));
    }
  }

  /// Reset to initial state
  void reset() {
    selectedGoal = null;
    emit(OnboardingInitial());
  }
}
