import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'personal_info_state.dart';

export 'personal_info_state.dart';

class PersonalInfoCubit extends Cubit<PersonalInfoState> {
  PersonalInfoCubit() : super(const PersonalInfoState()) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    emit(PersonalInfoState(
      gender:      p.getString('pi_gender') ?? 'male',
      weight:      p.getDouble('pi_weight') ?? 70.0,
      height:      p.getDouble('pi_height') ?? 170.0,
      yearOfBirth: p.getInt('pi_year')      ?? 2000,
    ));
  }

  // Persists the updated profile and immediately propagates the new values
  // to onboardingDataCubit and activityCubit so every goal calculation in
  // the app (home, progress, activity level card) uses the same data.
  Future<void> save({
    required String gender,
    required double weight,
    required double height,
    required int yearOfBirth,
    OnboardingCubitAllData? onboardingCubit,
    ActivityCubit? activityCubit,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('pi_gender', gender);
    await p.setDouble('pi_weight', weight);
    await p.setDouble('pi_height', height);
    await p.setInt('pi_year', yearOfBirth);

    emit(state.copyWith(
      gender:      gender,
      weight:      weight,
      height:      height,
      yearOfBirth: yearOfBirth,
    ));

    // Push the new profile into onboardingDataCubit so ActivityCubit
    // rebuilds DailyStats with the correct weight/height/age/gender.
    // Without this, ActivityCubit keeps the old values until the next
    // app launch, causing the activity level card to show different numbers
    // from the home and progress screens.
    if (onboardingCubit != null) {
      onboardingCubit.setWeight(weight);
      onboardingCubit.setHeight(height);
      onboardingCubit.setGender(gender);
      onboardingCubit.setAge(
        (DateTime.now().year - yearOfBirth).toDouble(),
      );
    }

    // Trigger a DailyStats rebuild so the new goals appear immediately
    // on the home and progress screens without requiring an app restart.
    if (activityCubit != null) {
      activityCubit.refresh();
    }
  }
}