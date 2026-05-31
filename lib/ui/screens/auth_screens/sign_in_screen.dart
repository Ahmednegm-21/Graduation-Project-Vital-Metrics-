// lib/ui/screens/auth_screens/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/services/device_token_manager.dart';
import 'package:vital_metrics/ui/widgets/custom_auth/custom_text_field.dart';
import 'package:vital_metrics/ui/widgets/custom_auth/social_auth_button.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
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
        listener: (context, state) async {
          if (state is AuthAdminSuccess) {
            // ✅ Admin → Admin Panel مباشرةً
            await DeviceTokenManager.instance.registerAfterLogin();
            context.go('/admin-panel');
          } else if (state is AuthSuccess) {
            // ✅ User عادي → Home
            await DeviceTokenManager.instance.registerAfterLogin();
            context.go('/home');
          } else if (state is AuthSignInOTPSent) {
            context.push('/verify-signin-otp', extra: state.email);
          } else if (state is AuthError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isSuccess = state is AuthSuccess;
          final emailError = state is AuthValidationError
              ? state.emailError
              : null;
          final passwordError = state is AuthValidationError
              ? state.passwordError
              : null;

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: AppDecorations.authGradientBackground,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingXXL),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),

                        Text(
                          'Sign in',
                          style: AppTextStyles.authTitle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppConstants.spaceS),

                        Text(
                          'Enter your email and password',
                          style: AppTextStyles.authSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppConstants.spaceXXXL + 8.h),

                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          errorText: emailError,
                          isSuccess: isSuccess,
                        ),
                        SizedBox(height: AppConstants.spaceL),

                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          errorText: passwordError,
                          isSuccess: isSuccess,
                        ),
                        SizedBox(height: AppConstants.spaceS),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => context.push('/forgot-password'),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.authLink,
                            ),
                          ),
                        ),
                        SizedBox(height: AppConstants.spaceXXL),

                        CustomButton(
                          text: 'Sign in',
                          isLoading: isLoading,
                          onPressed: () => context.read<AuthCubit>().signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        ),
                        SizedBox(height: AppConstants.spaceXXL),

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
