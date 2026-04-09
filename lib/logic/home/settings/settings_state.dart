import 'settings_cubit.dart';

class SettingsState {
  final bool darkMode;
  final bool notifications;
  final int dailyCalories;
  final int waterGoal;

  SettingsState({
    required this.darkMode,
    required this.notifications,
    required this.dailyCalories,
    required this.waterGoal,
  });

  SettingsState copyWith({
    bool? darkMode,
    bool? notifications,
    int? dailyCalories,
    int? waterGoal,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      notifications: notifications ?? this.notifications,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      waterGoal: waterGoal ?? this.waterGoal,
    );
  }
}
