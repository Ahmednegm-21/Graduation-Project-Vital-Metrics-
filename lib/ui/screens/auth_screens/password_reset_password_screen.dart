import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: AppDecorations.authGradientBackground,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingXXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // Success icon
                Center(
                  child: Container(
                    width: 90.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: AppConstants.iconXL,
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.spaceXXXL),

                // Title
                Text(
                  'Successful',
                  style: AppTextStyles.authTitle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppConstants.spaceM),

                // Subtitle
                Text(
                  'Congratulations! Your password has been\nchanged. Click continue to login',
                  style: AppTextStyles.authSubtitle,
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                // Continue to login
                CustomButton(
                  text: 'Continue to Login',
                  onPressed: () => context.go('/signin'),
                ),
                SizedBox(height: AppConstants.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}