import 'package:equatable/equatable.dart';
import '../../data/models/user_goal.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

// Initial state
class OnboardingInitial extends OnboardingState {}

// Loading state (saving goal to API)
class OnboardingLoading extends OnboardingState {}

// Goal selected (but not saved yet)
class GoalSelected extends OnboardingState {
  final UserGoal goal;

  const GoalSelected(this.goal);

  @override
  List<Object?> get props => [goal];
}

// Goal saved successfully
class GoalSaved extends OnboardingState {
  final UserGoal goal;

  const GoalSaved(this.goal);

  @override
  List<Object?> get props => [goal];
}

// Error state
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}