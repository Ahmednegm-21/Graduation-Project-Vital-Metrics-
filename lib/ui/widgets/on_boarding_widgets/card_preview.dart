import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class ProfilePreviewCard extends StatelessWidget {
  final Color accent;
  final String imagePath;
  final IconData fallbackIcon;
  final double? width;
  final double? height;

  const ProfilePreviewCard({
    super.key,
    required this.accent,
    required this.imagePath,
    required this.fallbackIcon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = width ?? mq.size.width * AppConstants.previewWidthRatio;
    final h = height ?? mq.size.height * AppConstants.previewHeightRatioOther;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tilted background
          Transform.rotate(
            angle: -0.05,
            child: Container(
              width: w * 0.86,
              height: h * 0.86,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ),
          
          // White card
          Container(
            width: w * 0.86,
            height: h * 0.92,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            padding: EdgeInsets.all(12.w),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(fallbackIcon, size: 160.sp, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}