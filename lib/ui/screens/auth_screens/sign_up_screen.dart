import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Show a red SnackBar with the error message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppConstants.paddingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate after short delay so user sees success state
            Future.delayed(
              Duration(milliseconds: AppConstants.authNavigationDelay),
              () => context.go('/gender'),
            );
          } else if (state is AuthError) {
            _showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isSuccess = state is AuthSuccess;

          // Field-level errors come from AuthValidationError
          final nameError     = state is AuthValidationError ? state.nameError     : null;
          final emailError    = state is AuthValidationError ? state.emailError    : null;
          final passwordError = state is AuthValidationError ? state.passwordError : null;

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: AppDecorations.authGradientBackground,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingXXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 80.h),

                    // Title
                    Text(
                      'Sign Up',
                      style: AppTextStyles.authTitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppConstants.spaceS),

                    // Subtitle
                    Text(
                      'Enter your email and password',
                      style: AppTextStyles.authSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 60.h),

                    // Name field
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      prefixIcon: Icons.person_outline,
                      errorText: nameError,
                      isSuccess: isSuccess,
                    ),
                    SizedBox(height: AppConstants.spaceL),

                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                      isSuccess: isSuccess,
                    ),
                    SizedBox(height: AppConstants.spaceL),

                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      errorText: passwordError,
                      isSuccess: isSuccess,
                    ),
                    SizedBox(height: AppConstants.spaceXXL),

                    // Sign up button
                    CustomButton(
                      text: 'Sign Up',
                      onPressed: () {
                        context.read<AuthCubit>().signUp(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                      },
                      isLoading: isLoading,
                    ),
                    SizedBox(height: AppConstants.spaceXXXL),

                    // Social auth
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
          );
        },
      ),
    );
  }
}