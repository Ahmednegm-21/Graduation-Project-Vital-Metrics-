import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';
import '../../widgets/custom_auth/custom_text_field.dart';
import '../../widgets/custom_auth/social_auth_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  // Local validation errors (before touching Cubit)
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  /// Validate fields locally.
  /// If valid → save credentials in OnboardingCubit and go to onboarding.
  /// The actual API call happens at the END of onboarding.
  void _onNextPressed() {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    final nameError = name.isEmpty
        ? 'Name is required'
        : name.length < 3
            ? 'Name must be at least 3 characters'
            : null;

    final emailError = email.isEmpty
        ? 'Email is required'
        : !_isValidEmail(email)
            ? 'Invalid email format'
            : null;

    final passwordError = password.isEmpty
        ? 'Password is required'
        : password.length < 8
            ? 'Password must be at least 8 characters'
            : null;

    setState(() {
      _nameError     = nameError;
      _emailError    = emailError;
      _passwordError = passwordError;
    });

    if (nameError != null || emailError != null || passwordError != null) return;

    // Save credentials in OnboardingCubit so we can use them at the end
    context.read<OnboardingCubitAllData>().setCredentials(
          name: name,
          email: email,
          password: password,
        );

    // Navigate to onboarding - do NOT call API yet
    context.push('/gender');
  }

  @override
  Widget build(BuildContext context) {
    // Only listen for AuthError (e.g. from Google sign-in)
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(AppConstants.paddingL),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
              ),
            );
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: AppDecorations.authGradientBackground,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.paddingXXL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 80.h),

                  Text(
                    'Sign Up',
                    style: AppTextStyles.authTitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppConstants.spaceS),

                  Text(
                    'Enter your details to create an account',
                    style: AppTextStyles.authSubtitle,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 60.h),

                  // Name
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Name',
                    prefixIcon: Icons.person_outline,
                    errorText: _nameError,
                  ),
                  SizedBox(height: AppConstants.spaceL),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                  ),
                  SizedBox(height: AppConstants.spaceL),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    errorText: _passwordError,
                  ),
                  SizedBox(height: AppConstants.spaceXXL),

                  // Next → goes to onboarding (no API call yet)
                  CustomButton(
                    text: 'Next',
                    onPressed: _onNextPressed,
                  ),
                  SizedBox(height: AppConstants.spaceXXXL),

                  Text(
                    'Sign In with',
                    style: AppTextStyles.authText,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppConstants.spaceXL),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: AppConstants.spaceXL),
                      SocialAuthButton(
                        imagePath: 'google',
                        onPressed: () =>
                            context.read<AuthCubit>().signInWithGoogle(),
                      ),
                    ],
                  ),
                  SizedBox(height: AppConstants.spaceXXXL + 8.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}