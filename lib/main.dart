import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/fitness/fitness_snapshot_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import 'package:vital_metrics/logic/user-goal/user_goal_dart_cubit.dart';

import 'package:vital_metrics/logic/home/home_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/theme_cubit.dart';
import 'package:vital_metrics/logic/home/sleep_cubit.dart';

import 'package:vital_metrics/logic/home/settings/personal_info_cubit.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
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

// =====================================================
// Extension على GoalType يحوّله لـ string مناسب
// للـ CalorieCubit.calculateAndSetBudget
// =====================================================

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
  late final AuthCubit _authCubit;
  late final OnboardingGoalCubit _onboardingGoalCubit;
  late final OnboardingCubitAllData _onboardingDataCubit;
  late final HomeCubit _homeCubit;
  late final WaterCubit _waterCubit;
  late final CalorieCubit _calorieCubit;
  late final ThemeCubit _themeCubit;
  late final SleepCubit _sleepCubit;
  late final PersonalInfoCubit _personalInfoCubit;
  late final ProgressCubit _progressCubit;
  late final FitnessSnapshotCubit _fitnessSnapshotCubit;
  late final ActivityCubit _activityCubit;
  late final StepsSyncService _stepsSyncService;

  // =====================================================
  // هيلبر: يحوّل الـ UserGoal لـ string
  // لو مفيش goal → 'maintain'
  // =====================================================

  String _goalString() {
    final goal = _onboardingDataCubit.currentData.goal;
    if (goal == null) return 'maintain';
    return goal.type.toGoalString(); // ← extension بدل .toLowerCase()
  }

  // =====================================================
  // هيلبر: يحدّث الـ calories + water بناءً على البيانات الشخصية
  // =====================================================

  void _syncProfileToHome() {
    final info = _personalInfoCubit.state;
    final onboardingData = _onboardingDataCubit.currentData;
    final activityLevel = onboardingData.activityLevel ?? ActivityLevel.moderate;

    // ── Calories ──
    _calorieCubit.calculateAndSetBudget(
      weight: info.weight,
      height: info.height,
      age: info.age.toDouble(),
      gender: info.gender,
      goal: _goalString(),
      activityLevel: activityLevel.name, // 'low' | 'moderate' | 'high'
    );

    // ── Water ──
    _waterCubit.setGoalFromProfile(
      weight: info.weight,
      activityLevel: activityLevel,
    );
  }

  @override
  void initState() {
    super.initState();

    // ───────────────── AUTH ─────────────────

    _authCubit = AuthCubit();

    // ─────────────── ONBOARDING ─────────────

    _onboardingGoalCubit = OnboardingGoalCubit();
    _onboardingDataCubit = OnboardingCubitAllData();

    // ───────────────── HOME ─────────────────

    _homeCubit = HomeCubit();
    _waterCubit = WaterCubit()..refresh();
    _calorieCubit = CalorieCubit();
    _themeCubit = ThemeCubit();
    _personalInfoCubit = PersonalInfoCubit();

    // ─────────────── PROGRESS ───────────────

    _progressCubit = ProgressCubit(
      calorieCubit: _calorieCubit,
      waterCubit: _waterCubit,
    );

    // ─────────────── SLEEP ──────────────────

    _sleepCubit = SleepCubit()
      ..setProgressCubit(_progressCubit)
      ..refresh();

    // =====================================================
    // SYNC PROFILE → HOME (Calories + Water)
    // =====================================================

    // لما البيانات الشخصية تتحمّل أول مرة
    _personalInfoCubit.stream.listen((_) {
      _syncProfileToHome();
    });

    // لما المستخدم يغيّر الـ activity level أو الـ goal
    _onboardingDataCubit.stream.listen((onboardingState) {
      if (onboardingState is OnboardingDataUpdated) {
        _syncProfileToHome();
      }
    });

    // =====================================================
    // LISTEN WATER CHANGES → PROGRESS
    // =====================================================

    _waterCubit.stream.listen((_) {
      _progressCubit.loadWeeklyMetrics(silent: true);
    });

    // =====================================================
    // LISTEN CALORIES CHANGES → PROGRESS
    // =====================================================

    _calorieCubit.stream.listen((_) {
      _progressCubit.loadWeeklyMetrics(silent: true);
    });

    // ───────────── FITNESS SNAPSHOT ─────────

    _fitnessSnapshotCubit = FitnessSnapshotCubit();

    // ─────────────── ACTIVITY ───────────────

    _activityCubit = ActivityCubit(
      onboardingCubit: _onboardingDataCubit,
    );

    _activityCubit.setProgressCubit(_progressCubit);

    // ─────────────── STEP SYNC ──────────────

    _stepsSyncService = StepsSyncService(
      progressCubit: _progressCubit,
    );

    _stepsSyncService.start();
  }

  @override
  void dispose() {
    _authCubit.close();
    _onboardingGoalCubit.close();
    _onboardingDataCubit.close();
    _homeCubit.close();
    _waterCubit.close();
    _calorieCubit.close();
    _themeCubit.close();
    _sleepCubit.close();
    _personalInfoCubit.close();
    _progressCubit.close();
    _fitnessSnapshotCubit.close();
    _activityCubit.close();
    _stepsSyncService.dispose();
    super.dispose();
  }

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
        BlocProvider.value(value: _sleepCubit),
        BlocProvider.value(value: _personalInfoCubit),
        BlocProvider.value(value: _progressCubit),
        BlocProvider.value(value: _fitnessSnapshotCubit),
        BlocProvider.value(value: _activityCubit),
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
                routerConfig: AppRouter.router,
                locale: DevicePreview.locale(context),
                builder: DevicePreview.appBuilder,
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