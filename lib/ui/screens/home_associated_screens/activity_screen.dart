import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/ui/widgets/activity/activity_level_card.dart';
import 'package:vital_metrics/ui/widgets/activity/activity_stats_row.dart';
import 'package:vital_metrics/ui/widgets/activity/circular_progress_rings.dart';
import 'package:vital_metrics/ui/widgets/activity/empty_state_widget.dart';
import 'package:vital_metrics/ui/widgets/activity/tracked_activity_card.dart';
import 'package:vital_metrics/ui/widgets/activity/log_activity_sheet.dart';
import 'package:vital_metrics/data/models/activity_level.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set ProgressCubit on the global ActivityCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityCubit>().setProgressCubit(
        context.read<ProgressCubit>(),
      );
    });
    return const _TodayScreenView();
  }
}

class _TodayScreenView extends StatelessWidget {
  const _TodayScreenView();

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[now.month - 1]} ${now.day}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF4361EE)),
        ),
        child: child!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: BlocBuilder<ActivityCubit, ActivityState>(
                builder: (context, state) {
                  if (state is TodayLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4361EE),
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is TodayError) {
                    return _buildError(context, state.message);
                  }
                  if (state is TodayLoaded) {
                    return _buildContent(context, state, isDark);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Date pill ──
          FadeInDown(
            child: GestureDetector(
              onTap: () => _showDatePicker(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(color: context.colors.shadow, blurRadius: 12),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF4361EE),
                      size: 18,
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      _todayLabel(),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        color: context.colors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bell + Settings ──
          Row(
            children: [
              FadeInDown(
                delay: const Duration(milliseconds: 80),
                child: GestureDetector(
                  onTap: () => context.push('/notifications'),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: context.colors.card,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.shadow,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.bell_fill,
                          color: isDark
                              ? const Color(0xFFFFA94D)
                              : const Color(0xFF4361EE),
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4757),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF0F1221)
                                  : const Color(0xFFF0F3FF),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              FadeInDown(
                delay: const Duration(milliseconds: 140),
                child: GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: context.colors.card,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(color: context.colors.shadow, blurRadius: 12),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Color(0xFF4361EE),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF3B30).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: const Color(0xFFFF3B30),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFFFF3B30)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () => context.read<ActivityCubit>().refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4361EE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TodayLoaded state, bool isDark) {
    final stats = state.stats;

    // Capture ActivityCubit before entering the scroll tree
    final activityCubit = context.read<ActivityCubit>();

    return RefreshIndicator(
      onRefresh: () => activityCubit.refresh(),
      color: const Color(0xFF4361EE),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: ActivityLevelCard(
                activityLevel: stats.activityLevel,
                onTap: () => _showActivityLevelSheet(
                  context,
                  stats.activityLevel,
                  activityCubit,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            FadeInUp(
              duration: const Duration(milliseconds: 450),
              delay: const Duration(milliseconds: 80),
              child: Column(
                children: [
                  Center(
                    child: _RingsSection(stats: stats, isDark: isDark),
                  ),
                  SizedBox(height: 20.h),
                  ActivityStatsRow(
                    caloriesBurned: stats.caloriesBurned,
                    caloriesGoal: stats.caloriesGoal,
                    steps: stats.steps,
                    stepsGoal: stats.stepsGoal,
                    workoutMinutes: stats.workoutMinutes,
                    workoutGoal: stats.workoutGoal,
                  ),
                ],
              ),
            ),

            // ── Empty state ──
            if (!stats.hasActivity)
              FadeInUp(
                delay: const Duration(milliseconds: 160),
                child: const EmptyStateWidget(),
              ),

            // ── Tracked activities list ──
            if (stats.trackedActivities.isNotEmpty) ...[
              SizedBox(height: 24.h),
              FadeInUp(
                delay: const Duration(milliseconds: 160),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Container(
                        width: 3.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4361EE),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Tracked Activities',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                          color: context.colors.text,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${stats.trackedActivities.length} logged',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colors.subText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.trackedActivities.length,
                itemBuilder: (context, index) {
                  final activity = stats.trackedActivities[index];
                  return TrackedActivityCard(
                    activity: activity,
                    // Use captured cubit to avoid context lookup issues
                    onDelete: () => activityCubit.removeActivity(activity.id),
                  );
                },
              ),
            ],

            SizedBox(height: 28.h),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _LogButton(onTap: () => showLogActivitySheet(context)),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  void _showActivityLevelSheet(
    BuildContext context,
    ActivityLevel currentLevel,
    ActivityCubit cubit,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.all(AppConstants.paddingXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.colors.subText.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Change Activity Level',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: context.colors.text,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'This sets your daily calorie & step goals',
              style: TextStyle(fontSize: 12.sp, color: context.colors.subText),
            ),
            SizedBox(height: 20.h),
            ...ActivityLevel.values.map((level) {
              final isSelected = level == currentLevel;
              return GestureDetector(
                onTap: () {
                  // Use passed cubit directly — no context.read inside sheet
                  cubit.changeActivityLevel(level);
                  Navigator.pop(sheetContext);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(bottom: AppConstants.spaceM),
                  padding: EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4361EE).withOpacity(0.08)
                        : context.colors.bg,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4361EE)
                          : context.colors.subText.withOpacity(0.15),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected
                            ? const Color(0xFF4361EE)
                            : context.colors.subText,
                        size: 22.sp,
                      ),
                      SizedBox(width: AppConstants.paddingL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.label,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: context.colors.text,
                              ),
                            ),
                            SizedBox(height: AppConstants.spaceXS),
                            Text(
                              level.description,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: context.colors.subText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

// ── Rings Section ─────────────────────────────────────────────────────────────
class _RingsSection extends StatelessWidget {
  final dynamic stats;
  final bool isDark;

  const _RingsSection({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      Container(
        width: 230.w,
        height: 230.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4361EE).withOpacity(isDark ? 0.08 : 0.05),
              blurRadius: 60,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
      CircularProgressRings(
        caloriesProgress: stats.caloriesProgress,
        stepsProgress: stats.stepsProgress,
        workoutProgress: stats.workoutProgress,
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${(stats.caloriesProgress * 100).round()}%',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFF9500),
              letterSpacing: -1,
            ),
          ),
          Text(
            'of goal',
            style: TextStyle(
              fontSize: 10.sp,
              color: context.colors.subText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ],
  );
}

// ── Log Button ────────────────────────────────────────────────────────────────
class _LogButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LogButton({required this.onTap});

  @override
  State<_LogButton> createState() => _LogButtonState();
}

class _LogButtonState extends State<_LogButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) {
      _ctrl.reverse();
      widget.onTap();
    },
    onTapCancel: () => _ctrl.reverse(),
    child: ScaleTransition(
      scale: _scale,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4361EE), Color(0xFF738EFF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4361EE).withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
            ),
            SizedBox(width: 10.w),
            Text(
              'Log Activity',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
