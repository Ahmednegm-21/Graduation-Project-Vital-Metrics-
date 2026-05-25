import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/logic/fitness/fitness_snapshot_cubit.dart';

// Replaces the old inline badge — shows Health Connect status
// and allows the user to enable or disable it from the same button
class HealthConnectToggle extends StatelessWidget {
  const HealthConnectToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FitnessSnapshotCubit, FitnessSnapshotState>(
      builder: (context, state) {
        final isLoading = state is FitnessSnapshotLoading;
        final isConnected = state is FitnessSnapshotLoaded;
        final isDisabled = state is FitnessSnapshotDisabled;

        // Color, label, and icon based on current state
        final Color color;
        final String label;
        final IconData icon;

        if (isConnected) {
          color = const Color(0xFF63E6BE); // green
          label = 'Health Connected';
          icon = Icons.favorite_rounded;
        } else if (isDisabled) {
          color = const Color(0xFF8A8A8A); // grey
          label = 'Health Disabled';
          icon = Icons.favorite_border_rounded;
        } else if (isLoading) {
          color = const Color(0xFF4CC9F0); // cyan
          label = 'Connecting...';
          icon = Icons.sync_rounded;
        } else {
          // error or initial state
          color = const Color(0xFFFFA94D); // orange
          label = 'Local Tracking';
          icon = Icons.phone_android_rounded;
        }

        return GestureDetector(
          onTap: isLoading
              ? null
              : () => _showToggleDialog(context, isDisabled || !isConnected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Status dot or loading spinner
                if (isLoading)
                  SizedBox(
                    width: 7.w,
                    height: 7.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: color,
                    ),
                  )
                else
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),

                SizedBox(width: 6.w),

                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(width: 4.w),

                // Small arrow to hint the user this is tappable
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: color,
                  size: 12.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Shows a bottom sheet asking the user to enable or disable Health Connect
  void _showToggleDialog(BuildContext context, bool isCurrentlyOff) {
    final cubit = context.read<FitnessSnapshotCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _HealthConnectSheet(isCurrentlyOff: isCurrentlyOff),
      ),
    );
  }
}

// Bottom sheet widget for enabling or disabling Health Connect
class _HealthConnectSheet extends StatelessWidget {
  final bool isCurrentlyOff;

  const _HealthConnectSheet({required this.isCurrentlyOff});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2340) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Health Connect icon circle
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: const Color(0xFF63E6BE).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              color: const Color(0xFF63E6BE),
              size: 28.sp,
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            'Health Connect',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),

          SizedBox(height: 8.h),

          // Description text changes based on current toggle state
          Text(
            isCurrentlyOff
                ? 'Enable Health Connect to automatically track your steps, calories burned, and workouts from your device.'
                : 'Disable Health Connect if you prefer to track manually. Your existing data will not be deleted.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
              height: 1.5,
            ),
          ),

          SizedBox(height: 24.h),

          // Primary action button — enable or disable
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              if (isCurrentlyOff) {
                await context.read<FitnessSnapshotCubit>().enable();
              } else {
                await context.read<FitnessSnapshotCubit>().disable();
              }
            },
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCurrentlyOff
                      ? [const Color(0xFF63E6BE), const Color(0xFF4CC9F0)]
                      : [const Color(0xFFFF8787), const Color(0xFFFFA94D)],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  isCurrentlyOff
                      ? 'Enable Health Connect'
                      : 'Disable Health Connect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Cancel button dismisses the sheet without any changes
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}