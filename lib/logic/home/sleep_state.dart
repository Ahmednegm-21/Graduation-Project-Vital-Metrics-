import 'package:equatable/equatable.dart';

class SleepState extends Equatable {
  final double sleepHours;
  final int? sleepId;
  final bool isLoading;
  final bool isSaving;

  const SleepState({
    this.sleepHours = 7.0,
    this.sleepId    = null,
    this.isLoading  = false,
    this.isSaving   = false,
  });

  // Duration in minutes for backend
  int get durationMinutes => (sleepHours * 60).round();

  // Quality string derived from hours
  String get quality {
    if (sleepHours < 6)  return 'poor';
    if (sleepHours < 7)  return 'fair';
    if (sleepHours <= 9) return 'good';
    return 'oversleep';
  }

  bool get hasTodaySleep => sleepId != null;

  SleepState copyWith({
    double? sleepHours,
    int? sleepId,
    bool? isLoading,
    bool? isSaving,
  }) {
    return SleepState(
      sleepHours: sleepHours ?? this.sleepHours,
      sleepId:    sleepId    ?? this.sleepId,
      isLoading:  isLoading  ?? this.isLoading,
      isSaving:   isSaving   ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [sleepHours, sleepId, isLoading, isSaving];
}