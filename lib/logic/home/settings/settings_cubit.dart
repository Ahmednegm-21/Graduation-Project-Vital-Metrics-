import 'package:bloc/bloc.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit()
      : super(SettingsState(
          darkMode: false,
          notifications: true,
          dailyCalories: 2000,
          waterGoal: 3000,
        ));

  void toggleDarkMode() => emit(state.copyWith(darkMode: !state.darkMode));

  void toggleNotifications() =>
      emit(state.copyWith(notifications: !state.notifications));

  void updateDailyCalories(int value) =>
      emit(state.copyWith(dailyCalories: value));

  void updateWaterGoal(int value) => emit(state.copyWith(waterGoal: value));
}
