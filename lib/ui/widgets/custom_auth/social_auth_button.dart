import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/constants/app_assets.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class SocialAuthButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppConstants.socialButtonSize.w,
        height: AppConstants.socialButtonSize.h,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.socialButtonPadding.w),
          child: _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (imagePath.contains('google')) {
      return Image.asset(
        AppAssets.googleLogo,
        width: AppConstants.socialIconSizeGoogle.w,
        height: AppConstants.socialIconSizeGoogle.h,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.g_mobiledata,
            color: AppColors.error,
            size: AppConstants.iconXL,
          );
        },
      );
    } else if (imagePath.contains('facebook')) {
      return Image.asset(
        AppAssets.facebookLogo,
        width: AppConstants.socialIconSizeFacebook.w,
        height: AppConstants.socialIconSizeFacebook.h,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.facebook,
            color: const Color(0xFF1877F2),
            size: AppConstants.iconXL + 10.sp,
          );
        },
      );
    }
    return Icon(
      Icons.login,
      color: AppColors.grey,
      size: AppConstants.iconL,
    );
  }
}