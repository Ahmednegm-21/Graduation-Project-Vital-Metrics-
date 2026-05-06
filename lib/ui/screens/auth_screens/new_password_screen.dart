import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/forget_password_cubit.dart';
import 'package:vital_metrics/logic/auth/forget_password_state.dart';
import 'package:vital_metrics/ui/widgets/custom_auth/custom_text_field.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordResetSuccess) {
            // Navigate to success screen only after API confirms reset
            context.go('/password-reset-success');
          } else if (state is ForgotPasswordError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading       = state is ForgotPasswordLoading;
          final passwordError   = state is ForgotPasswordValidationError
              ? state.passwordError
              : null;
          final confirmError    = state is ForgotPasswordValidationError
              ? state.confirmPasswordError
              : null;

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: AppDecorations.authGradientBackground,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingXXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppConstants.spaceL),

                    // Back button
                    _BackButton(),
                    SizedBox(height: AppConstants.spaceXXXL),

                    // Title
                    Text('Set a new\npassword', style: AppTextStyles.authTitle),
                    SizedBox(height: AppConstants.spaceS),

                    // Subtitle
                    Text(
                      'Create a new password. Ensure it differs\nfrom previous ones for security',
                      style: AppTextStyles.authSubtitle,
                    ),
                    SizedBox(height: AppConstants.spaceXXXL + 8.h),

                    // Password label
                    Text(
                      'Password',
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceS),

                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Enter your new password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      errorText: passwordError,
                    ),
                    SizedBox(height: AppConstants.spaceL),

                    // Confirm password label
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceS),

                    // Confirm password field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Re-enter password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      errorText: confirmError,
                    ),
                    SizedBox(height: AppConstants.spaceXXXL),

                    // Update button
                    CustomButton(
                      text: 'Update Password',
                      isLoading: isLoading,
                      onPressed: () =>
                          context.read<ForgotPasswordCubit>().resetPasswordConfirm(
                                email: widget.email,
                                otp: widget.otp,
                                newPassword: _passwordController.text,
                                confirmPassword: _confirmPasswordController.text,
                              ),
                    ),
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

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          padding: EdgeInsets.all(AppConstants.paddingS),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white70),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: AppConstants.iconS,
          ),
        ),
      ),
    );
  }
}