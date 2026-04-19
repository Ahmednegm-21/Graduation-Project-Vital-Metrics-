import 'package:equatable/equatable.dart';
import '../../data/models/user_goal.dart';
import '../../data/models/onboarding_data.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

// Initial state
class OnboardingInitial extends OnboardingState {}

// Loading state
class OnboardingLoading extends OnboardingState {}

// Data updated
class OnboardingDataUpdated extends OnboardingState {
  final OnboardingData data;

  const OnboardingDataUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

// Goal selected
class GoalSelected extends OnboardingState {
  final UserGoal goal;

  const GoalSelected(this.goal);

  @override
  List<Object?> get props => [goal];
}

// All data saved successfully
class OnboardingComplete extends OnboardingState {
  final OnboardingData data;

  const OnboardingComplete(this.data);

  @override
  List<Object?> get props => [data];
}

// Error state
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}