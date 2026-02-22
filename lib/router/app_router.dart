// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/auth_screens/sign_in_screen.dart';
import '../ui/screens/auth_screens/sign_up_screen.dart';
import 'package:vital_metrics/ui/screens/onboarding_screens/onboarding_gender_screen.dart';
import 'package:vital_metrics/ui/screens/onboarding_screens/onboarding_height_screen.dart';
import 'package:vital_metrics/ui/screens/onboarding_screens/onboarding_weight_screen.dart';
import 'package:vital_metrics/ui/screens/onboarding_screens/onboarding_age_screen.dart';
import 'package:vital_metrics/ui/screens/onboarding_screens/onboarding_thankyou_screen.dart';
import '../ui/screens/user_target_screens/goal_selection_screen.dart';
import 'package:vital_metrics/ui/screens/user_target_screens/weight_speed_screen.dart';
import 'package:vital_metrics/ui/screens/user_target_screens/target_weight_screen.dart';
import 'package:vital_metrics/ui/screens/user_target_screens/plan_summary_screen.dart';
import 'package:vital_metrics/ui/screens/user_target_screens/get_my_plan_screen.dart';
import '../ui/screens/home_associated_screens/main_shell.dart';
import '../ui/screens/home_associated_screens/settings_screen.dart';
import '../ui/screens/home_associated_screens/recipes_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/gender',
        name: 'gender',
        builder: (context, state) => const OnboardingGender(),
      ),
      GoRoute(
        path: '/height',
        name: 'height',
        builder: (context, state) => const OnboardingHeight(),
      ),
      GoRoute(
        path: '/weight',
        name: 'weight',
        builder: (context, state) => const OnboardingWeight(),
      ),
      GoRoute(
        path: '/age',
        name: 'age',
        builder: (context, state) => const OnboardingAge(),
      ),
      GoRoute(
        path: '/thank-you',
        name: 'thank-you',
        builder: (context, state) => const OnboardingThankYou(),
      ),
      GoRoute(
        path: '/goal-selection',
        name: 'goal-selection',
        builder: (context, state) => const GoalSelectionScreen(),
      ),
      GoRoute(
        path: '/weight-speed',
        name: 'weight-speed',
        builder: (context, state) => const WeightSpeedScreen(),
      ),
      GoRoute(
        path: '/target-weight',
        name: 'target-weight',
        builder: (context, state) => const TargetWeightScreen(),
      ),
      GoRoute(
        path: '/plan-summary',
        name: 'plan-summary',
        builder: (context, state) => const PlanSummaryScreen(),
      ),
      GoRoute(
        path: '/get-my-plan',
        name: 'get-my-plan',
        builder: (context, state) => const GetMyPlanScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ✅ Recipes — يقبل mealType كـ query parameter اختياري
      // للتنقل من صفحة الهوم: context.push('/recipes?mealType=breakfast')
      // للتنقل من الـ bottom nav بدون فلتر: context.push('/recipes')
      GoRoute(
        path: '/recipes',
        name: 'recipes',
        builder: (context, state) {
          final mealType = state.uri.queryParameters['mealType'];
          return RecipesScreen(mealType: mealType);
        },
      ),
    ],

    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}
