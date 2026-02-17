import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/core/themes/app_theme.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/user-goal/user_goal_dart_cubit.dart';
import 'package:vital_metrics/router/app_router.dart';

void main() =>
    runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => AuthCubit()),
            BlocProvider(create: (context) => OnboardingGoalCubit()),
            BlocProvider(create: (context) => OnboardingCubitAllData()),
          ],
          child: MaterialApp.router(
            routerConfig: AppRouter.router,
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}