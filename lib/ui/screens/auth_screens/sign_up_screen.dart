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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Future.delayed(
              Duration(milliseconds: AppConstants.authNavigationDelay),
              () => context.go('/gender'),
            );
          }
        },
        builder: (context, state) {
          // Extract errors
          String? nameError;
          String? emailError;
          String? passwordError;
          bool isSuccess = false;

          if (state is AuthValidationError) {
            nameError = state.nameError;
            emailError = state.emailError;
            passwordError = state.passwordError;
          } else if (state is AuthSuccess) {
            isSuccess = true;
          }

          final isLoading = state is AuthLoading;

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

                    // Sign in with text
                    Text(
                      'Sign In with',
                      style: AppTextStyles.authText,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppConstants.spaceXL),

                    // Social auth buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: AppConstants.spaceXL),
                        SocialAuthButton(
                          imagePath: 'google',
                          onPressed: () {
                            context.read<AuthCubit>().signInWithGoogle();
                          },
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