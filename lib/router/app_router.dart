import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/food_swapping/food_swapping_cubit.dart';
import 'package:vital_metrics/ui/screens/home_associated_screens/ai_screen.dart';
import 'package:vital_metrics/ui/screens/home_associated_screens/fav_screen.dart';
import 'package:vital_metrics/ui/screens/home_associated_screens/food_swapping_screen.dart';
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
      GoRoute(
        path: '/recipes',
        name: 'recipes',
        builder: (context, state) {
          final mealType = state.uri.queryParameters['mealType'];
          return RecipesScreen(mealType: mealType);
        },
      ),

      // Food Swapping Screen
      GoRoute(
        path: '/food-swapping',
        name: 'food-swapping',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FoodSwappingScreen(),
          transitionsBuilder: (context, animation, _, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),

      // Favorites Screen
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => FoodSwapCubit(),
            child: const FavoritesScreen(),
          ),
          transitionsBuilder: (context, animation, _, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),

      // AI Assistant Screen
      GoRoute(
        path: '/ai-assistant',
        name: 'ai-assistant',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AiScreen(),
          transitionsBuilder: (context, animation, _, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
    ],

    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
}