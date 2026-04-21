import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;

  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppConstants.splashLogoDuration),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoController.forward();

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppConstants.splashTextDuration),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    Future.delayed(
      Duration(milliseconds: AppConstants.splashTextDelay),
      () {
        if (mounted) _textController.forward();
      },
    );

    // Check auth after splash duration
    Timer(
      Duration(milliseconds: AppConstants.splashNavigationDelay),
      () {
        if (mounted) {
          context.read<AuthCubit>().checkAuthStatus();
        }
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Check if onboarding is complete
          final onboardingComplete = state.user.onboardingComplete ?? false;
          
          if (onboardingComplete) {
            // User finished onboarding go to home
            context.go('/home');
          } else {
            // User registered but didn't finish onboarding go to gender screen
            context.go('/gender');
          }
        } else if (state is AuthInitial) {
          // No token go to sign in
          context.go('/signin');
        } else if (state is AuthError) {
          // Token invalid/expired go to sign in
          context.go('/signin');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.splashBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animation
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: AppConstants.splashLogoWidth.w,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: AppConstants.spaceXXL),

              // Text animation
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Image.asset(
                    'assets/images/vital_metrics_logo.png',
                    width: AppConstants.splashTextWidth.w,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}