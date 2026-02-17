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

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
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
          String? emailError;
          String? passwordError;
          bool isSuccess = false;

          if (state is AuthValidationError) {
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),

                        // Title
                        Text(
                          'Sign in',
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
                        SizedBox(height: AppConstants.spaceXXXL + 8.h),

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

                        // Sign in button
                        CustomButton(
                          text: 'Sign in',
                          onPressed: () {
                            context.read<AuthCubit>().signIn(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                          },
                          isLoading: isLoading,
                        ),
                        SizedBox(height: AppConstants.spaceXXL),

                        // Don't have account
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Dont have an account?  ',
                              style: AppTextStyles.authText,
                            ),
                            GestureDetector(
                              onTap: () => context.push('/signup'),
                              child: Text(
                                'Sign up',
                                style: AppTextStyles.authLink,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppConstants.spaceXXXL + 8.h),

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

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}