import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/user-goal/user_goal_dart_cubit.dart';
import 'package:vital_metrics/logic/home/home_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/theme_cubit.dart';
import 'package:vital_metrics/logic/home/settings/personal_info_cubit.dart';

import 'package:vital_metrics/router/app_router.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
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
  late final PersonalInfoCubit _personalInfoCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
    _onboardingGoalCubit = OnboardingGoalCubit();
    _onboardingDataCubit = OnboardingCubitAllData();
    _homeCubit = HomeCubit();
    _waterCubit = WaterCubit();
    _calorieCubit = CalorieCubit();
    _themeCubit = ThemeCubit();
    _personalInfoCubit = PersonalInfoCubit();
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
    _personalInfoCubit.close();
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
        BlocProvider.value(value: _personalInfoCubit),
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
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}