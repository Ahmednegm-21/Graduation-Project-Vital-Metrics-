import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
// Screens
import 'package:vital_metrics/ui/screens/sign_in_screen.dart';
import 'package:vital_metrics/ui/screens/sign_up_screen.dart';
import 'package:vital_metrics/ui/screens/onboarding_gender.dart';
import 'ui/screens/splash_screen.dart';
// Routes
// import 'routes/app_routes.dart';

void main() => runApp(
      DevicePreview(
        enabled: true,
        builder: (context) => const MyApp(),
      ),
    );

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
            // TODO: Add other Cubits/Blocs here when teammate pushes
            // BlocProvider(create: (context) => DashboardBloc()),
            // BlocProvider(create: (context) => ActivityBloc()),
            // BlocProvider(create: (context) => SleepBloc()),
            // BlocProvider(create: (context) => HydrationBloc()),
            // BlocProvider(create: (context) => CoachBloc()),
            // BlocProvider(create: (context) => MemoriesBloc()),
            // BlocProvider(create: (context) => ProfileBloc()),
          ],
          child: MaterialApp(
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            routes: {
              '/signin': (context) => const SignInScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/onboarding-gender': (context) => const OnboardingGender(),
              // TODO: Add other routes when teammate pushes
              // '/home': (context) => const HomeScreen(),
              // '/activity': (context) => const ActivityScreen(),
              // '/sleep': (context) => const SleepScreen(),
              // '/hydration': (context) => const HydrationScreen(),
              // '/coach': (context) => const CoachScreen(),
              // '/memories': (context) => const MemoriesScreen(),
              // '/profile': (context) => const ProfileScreen(),
            },
          ),
        );
      },
    );
  }
}