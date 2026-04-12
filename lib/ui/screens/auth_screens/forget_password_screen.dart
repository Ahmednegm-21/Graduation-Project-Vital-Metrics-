import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/ui/widgets/custom_auth/custom_text_field.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPressed() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _emailError = 'Invalid email format');
      return;
    }

    setState(() => _emailError = null);

    // connect to ForgotPasswordCubit
    context.push('/verify-otp', extra: email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                Text('Forgot\nPassword', style: AppTextStyles.authTitle),
                SizedBox(height: AppConstants.spaceS),

                // Subtitle
                Text(
                  'Please enter your email to reset the password',
                  style: AppTextStyles.authSubtitle,
                ),
                SizedBox(height: AppConstants.spaceXXXL + 8.h),

                // Email label
                Text(
                  'Your Email',
                  style: TextStyle(
                    color: AppColors.white70,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppConstants.spaceS),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                SizedBox(height: AppConstants.spaceXXXL),

                // Reset button
                CustomButton(
                  text: 'Reset Password',
                  onPressed: _onResetPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable back button ──────────────────────────────────────────────────────
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
            border: Border.all(
              color: AppColors.white70,
            ),
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