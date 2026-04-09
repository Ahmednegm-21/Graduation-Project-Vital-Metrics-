import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class OnboardingProgressAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final double progress;
  final Color color;
  final VoidCallback? onBackPressed;

  const OnboardingProgressAppBar({
    super.key,
    required this.progress,
    required this.color,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          // Back button if callback provided
          if (onBackPressed != null)
            IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20.sp),
              color: color,
              onPressed: onBackPressed,
            ),
          
          // Progress bar
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: onBackPressed != null ? 0 : 18.w,
              ).copyWith(right: 18.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4.h,
                  backgroundColor: AppColors.greyLight,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}