import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/fitness/fitness_snapshot_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/user-goal/user_goal_dart_cubit.dart';

import 'package:vital_metrics/logic/home/home_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/theme_cubit.dart';
import 'package:vital_metrics/logic/home/locale_cubit.dart';
import 'package:vital_metrics/logic/home/sleep_cubit.dart';

import 'package:vital_metrics/logic/home/settings/personal_info_cubit.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/logic/notifications/notifications_cubit.dart';
import 'package:vital_metrics/logic/tips/tips_cubit.dart';

import 'package:vital_metrics/data/models/activity_level.dart';
import 'package:vital_metrics/data/models/user_goal.dart';

import 'package:vital_metrics/services/steps_sync_service.dart';
import 'package:vital_metrics/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    DevicePreview(
      enabled: false,
      builder: (context) => const MyApp(),
    ),
  );
}

extension GoalTypeString on GoalType {
  String toGoalString() {
    switch (this) {
      case GoalType.loseWeight:
        return 'lose_weight';
      case GoalType.gainWeight:
        return 'gain_weight';
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit               _authCubit;
  late final OnboardingGoalCubit     _onboardingGoalCubit;
  late final OnboardingCubitAllData  _onboardingDataCubit;
  late final HomeCubit               _homeCubit;
  late final WaterCubit              _waterCubit;
  late final CalorieCubit            _calorieCubit;
  late final ThemeCubit              _themeCubit;
  late final LocaleCubit _localeCubit;
  late final SleepCubit              _sleepCubit;
  late final PersonalInfoCubit       _personalInfoCubit;
  late final ProgressCubit           _progressCubit;
  late final FitnessSnapshotCubit    _fitnessSnapshotCubit;
  late final ActivityCubit           _activityCubit;
  late final NotificationsCubit      _notificationsCubit;
  late final TipsCubit               _tipsCubit;
  late final StepsSyncService        _stepsSyncService;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _goalString() {
    final goal = _onboardingDataCubit.currentData.goal;
    if (goal == null) return 'maintain';
    return goal.type.toGoalString();
  }

  void _pushProfileToOnboarding() {
    final info = _personalInfoCubit.state;
    _onboardingDataCubit.setWeight(info.weight);
    _onboardingDataCubit.setHeight(info.height);
    _onboardingDataCubit.setGender(info.gender);
    _onboardingDataCubit.setAge(
      (DateTime.now().year - info.yearOfBirth).toDouble(),
    );
  }

  void _syncProfileToHome() {
    _pushProfileToOnboarding();

    final info          = _personalInfoCubit.state;
    final activityLevel =
        _onboardingDataCubit.currentData.activityLevel ?? ActivityLevel.moderate;
    final activityLevelStr =
        activityLevel == ActivityLevel.moderate ? 'medium' : activityLevel.name;

    _calorieCubit.calculateAndSetBudget(
      weight:        info.weight,
      height:        info.height,
      age:           info.age.toDouble(),
      gender:        info.gender,
      goal:          _goalString(),
      activityLevel: activityLevelStr,
    );

    _waterCubit.setGoalFromProfile(
      weight:        info.weight,
      activityLevel: activityLevel,
    );

    print('[main] syncProfileToHome: level=${activityLevel.name} '
        'weight=${info.weight} goal=${_goalString()}');
  }

  void _syncActivityLevel(ActivityLevel level) {
    _pushProfileToOnboarding();

    final info             = _personalInfoCubit.state;
    final activityLevelStr =
        level == ActivityLevel.moderate ? 'medium' : level.name;

    _calorieCubit.calculateAndSetBudget(
      weight:        info.weight,
      height:        info.height,
      age:           info.age.toDouble(),
      gender:        info.gender,
      goal:          _goalString(),
      activityLevel: activityLevelStr,
    );

    _waterCubit.setGoalFromProfile(
      weight:        info.weight,
      activityLevel: level,
    );

    print('[main] syncActivityLevel => level=$level');
  }

  // ── initState ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _authCubit           = AuthCubit();
    _onboardingGoalCubit = OnboardingGoalCubit();
    _onboardingDataCubit = OnboardingCubitAllData();
    _homeCubit           = HomeCubit();
    _waterCubit          = WaterCubit()..refresh();
    _calorieCubit        = CalorieCubit();
    _themeCubit          = ThemeCubit();
    _localeCubit = LocaleCubit();
    _personalInfoCubit   = PersonalInfoCubit();

    _progressCubit = ProgressCubit(
      calorieCubit: _calorieCubit,
      waterCubit:   _waterCubit,
    );

    _sleepCubit = SleepCubit()
      ..setProgressCubit(_progressCubit)
      ..refresh();

    _notificationsCubit = NotificationsCubit()..loadNotifications();

    _fitnessSnapshotCubit = FitnessSnapshotCubit();

    _activityCubit = ActivityCubit(
      onboardingCubit: _onboardingDataCubit,
    );
    _activityCubit.setProgressCubit(_progressCubit);

    // TipsCubit — يعتمد على باقي الـ cubits
    _tipsCubit = TipsCubit(
      calorieCubit:  _calorieCubit,
      waterCubit:    _waterCubit,
      sleepCubit:    _sleepCubit,
      activityCubit: _activityCubit,
    );

    _stepsSyncService = StepsSyncService(progressCubit: _progressCubit)
      ..start();

    // ── Listeners ────────────────────────────────────────────────────────────

    bool activityLevelSyncedOnStart = false;

    _personalInfoCubit.stream.listen((_) {
      _syncProfileToHome();

      if (!activityLevelSyncedOnStart) {
        activityLevelSyncedOnStart = true;
        final savedLevel = _onboardingDataCubit.currentData.activityLevel;
        if (savedLevel != null) {
          _syncActivityLevel(savedLevel);
          print('[main] startup activity level sync => $savedLevel');
        }
      }
    });

    _waterCubit.stream.listen((_) =>
        _progressCubit.loadWeeklyMetrics(silent: true));

    _calorieCubit.stream.listen((_) =>
        _progressCubit.loadWeeklyMetrics(silent: true));

    ActivityLevel? lastSyncedLevel;
    bool firstLoad = true;

    _activityCubit.stream.listen((activityState) {
      if (activityState is TodayLoaded) {
        final currentLevel = _onboardingDataCubit.currentData.activityLevel;
        if (currentLevel != null &&
            (firstLoad || currentLevel != lastSyncedLevel)) {
          firstLoad        = false;
          lastSyncedLevel  = currentLevel;
          _syncActivityLevel(currentLevel);
        }
      }
    });
  }

  // ── dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _authCubit.close();
    _onboardingGoalCubit.close();
    _onboardingDataCubit.close();
    _homeCubit.close();
    _waterCubit.close();
    _calorieCubit.close();
    _themeCubit.close();
    _localeCubit.close();
    _sleepCubit.close();
    _personalInfoCubit.close();
    _progressCubit.close();
    _fitnessSnapshotCubit.close();
    _activityCubit.close();
    _notificationsCubit.close();
    _tipsCubit.close();
    _stepsSyncService.dispose();
    super.dispose();
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _onboardingGoalCubit),
        BlocProvider.value(value: _onboardingDataCubit),
        BlocProvider.value(value: _homeCubit),
        BlocProvider.value(value: _waterCubit),
        BlocProvider.value(value: _calorieCubit),
        BlocProvider.value(value: _themeCubit),
        BlocProvider.value(value: _localeCubit),
        BlocProvider.value(value: _sleepCubit),
        BlocProvider.value(value: _personalInfoCubit),
        BlocProvider.value(value: _progressCubit),
        BlocProvider.value(value: _fitnessSnapshotCubit),
        BlocProvider.value(value: _activityCubit),
        BlocProvider.value(value: _notificationsCubit),
        BlocProvider.value(value: _tipsCubit),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        bloc: _themeCubit,
        builder: (context, isDark) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp.router(
                routerConfig:              AppRouter.router,
                locale:                    DevicePreview.locale(context),
                builder:                   DevicePreview.appBuilder,
                debugShowCheckedModeBanner: false,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                theme: ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF4361EE),
                  ),
                ),
                darkTheme: ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: const Color(0xFF1A1A2E),
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF4361EE),
                    surface: Color(0xFF16213E),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}