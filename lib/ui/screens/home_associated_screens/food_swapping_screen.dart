import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class FoodSwappingScreen extends StatelessWidget {
  const FoodSwappingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 8)],
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF34C759), size: 18.sp),
          ),
        ),
        title: Text(
          'Food Swapping',
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(28.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF34C759).withOpacity(0.15),
                    const Color(0xFF34C759).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.swap_horiz_rounded,
                  size: 64.sp, color: const Color(0xFF34C759)),
            ),
            SizedBox(height: 24.h),
            Text('Food Swapping',
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.text)),
            SizedBox(height: 8.h),
            Text('Coming Soon',
                style: TextStyle(
                    fontSize: 14.sp, color: context.colors.subText)),
          ],
        ),
      ),
    );
  }
}