import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/ui/widgets/food_swapping/compare_sheet.dart';

/// Card that shows one swap alternative with actions (save, compare, add to log).
class SwapCard extends StatefulWidget {
  final SwapAlternative alt;
  final FoodItem original; // needed for compare sheet
  final int index;

  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onAddToLog;
  final VoidCallback? onCompare; // optional override; defaults to built-in sheet

  const SwapCard({
    super.key,
    required this.alt,
    required this.original,
    required this.index,
    this.isFavorite,
    this.onFavoriteToggle,
    this.onAddToLog,
    this.onCompare,
  });

  @override
  State<SwapCard> createState() => _SwapCardState();
}

class _SwapCardState extends State<SwapCard>
    with SingleTickerProviderStateMixin {
  // Press-down scale animation
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.animationFast ~/ 2),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = context.isDark;
    // Use AppColors central gradient palette
    final gradient = AppColors.swapGradient(widget.index);
    final score    = widget.alt.matchScore.round();

    return GestureDetector(
      onTapDown:  (_) => _pressCtrl.forward(),
      onTapUp:    (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Main card ──────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: context.colors.card,
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(isDark ? 0.12 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(children: [
                // Top row: emoji + name + benefit badge + match score
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.paddingL,
                    AppConstants.paddingL,
                    AppConstants.paddingL,
                    AppConstants.paddingM,
                  ),
                  child: Row(children: [
                    // Emoji container
                    Container(
                      width: 52.w,
                      height: 52.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          gradient[0].withOpacity(0.15),
                          gradient[1].withOpacity(0.08),
                        ]),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Text(widget.alt.food.emoji,
                            style: TextStyle(fontSize: AppConstants.iconL * 0.8)),
                      ),
                    ),
                    SizedBox(width: AppConstants.paddingM),

                    // Name + benefit badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.alt.food.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: context.colors.text,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          // Benefit tag with gradient background
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppConstants.paddingS,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusRound),
                            ),
                            child: Text(
                              '${widget.alt.benefit.emoji} ${widget.alt.benefit.label}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Match score circle
                    _MatchScoreCircle(score: score, color: gradient[0]),
                  ]),
                ),

                // Divider
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.05),
                ),

                // Macros row + swap reason
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppConstants.paddingL,
                    AppConstants.spaceS,
                    AppConstants.paddingL,
                    AppConstants.spaceM,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 4 macro pills
                      Row(children: [
                        _MacroBar(
                          label: 'Cal',
                          value: widget.alt.food.calories.round(),
                          unit: 'kcal',
                          color: AppColors.protein, // orange — calories
                        ),
                        SizedBox(width: AppConstants.paddingS),
                        _MacroBar(
                          label: 'Prot',
                          value: widget.alt.food.protein.round(),
                          unit: 'g',
                          color: AppColors.swapBlue,
                        ),
                        SizedBox(width: AppConstants.paddingS),
                        _MacroBar(
                          label: 'Carb',
                          value: widget.alt.food.carbs.round(),
                          unit: 'g',
                          color: gradient[0], // matches card accent
                        ),
                        SizedBox(width: AppConstants.paddingS),
                        _MacroBar(
                          label: 'Fat',
                          value: widget.alt.food.fats.round(),
                          unit: 'g',
                          color: AppColors.swapPurple,
                        ),
                      ]),
                      SizedBox(height: AppConstants.spaceS),

                      // Swap reason text
                      Row(children: [
                        Icon(Icons.swap_horiz_rounded,
                            size: AppConstants.iconXS,
                            color: gradient[0]),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: Text(
                            widget.alt.swapReason,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.colors.subText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ]),
            ),

            // ── Action row ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppConstants.paddingXS,
                AppConstants.spaceS,
                AppConstants.paddingXS,
                AppConstants.spaceM,
              ),
              child: Row(children: [
                // Save / Saved button
                if (widget.onFavoriteToggle != null) ...[
                  _ActionBtn(
                    label:       widget.isFavorite == true ? 'Saved' : 'Save',
                    icon:        widget.isFavorite == true
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color:       widget.isFavorite == true
                        ? AppColors.favoriteOrange
                        : context.colors.subText,
                    bgColor:     widget.isFavorite == true
                        ? AppColors.favoriteOrange.withOpacity(0.12)
                        : context.colors.card,
                    borderColor: widget.isFavorite == true
                        ? AppColors.favoriteOrange.withOpacity(0.4)
                        : isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.06),
                    onTap: widget.onFavoriteToggle!,
                  ),
                  SizedBox(width: AppConstants.spaceS),
                ],

                // Compare button — uses gradient accent color
                _ActionBtn(
                  label:       'Compare',
                  icon:        Icons.compare_arrows_rounded,
                  color:       gradient[0],
                  bgColor:     gradient[0].withOpacity(0.10),
                  borderColor: gradient[0].withOpacity(0.25),
                  onTap: widget.onCompare ??
                      () => showCompareSheet(
                            context,
                            original:    widget.original,
                            alternative: widget.alt.food,
                            altGradient: gradient,
                          ),
                ),

                // Add to Log button (gradient filled)
                if (widget.onAddToLog != null) ...[
                  SizedBox(width: AppConstants.spaceS),
                  _ActionBtn(
                    label:      'Add to Log',
                    icon:       Icons.add_circle_outline_rounded,
                    color:      AppColors.white,
                    bgColor:    gradient[0],
                    isGradient: true,
                    gradient:   gradient,
                    onTap:      widget.onAddToLog!,
                  ),
                ],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
/// Reusable pill button used in the action row below each swap card.
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color? borderColor;
  final bool isGradient;
  final List<Color>? gradient;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.borderColor,
    this.isGradient = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppConstants.animationFast),
          padding: EdgeInsets.symmetric(vertical: AppConstants.spaceS + 2.h),
          decoration: BoxDecoration(
            gradient: isGradient && gradient != null
                ? LinearGradient(colors: gradient!)
                : null,
            color:      isGradient ? null : bgColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: borderColor != null && !isGradient
                ? Border.all(color: borderColor!)
                : null,
            boxShadow: isGradient
                ? [BoxShadow(
                    color:      gradient![0].withOpacity(0.30),
                    blurRadius: 8,
                    offset:     const Offset(0, 3),
                  )]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: AppConstants.iconXS),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Match score circle ────────────────────────────────────────────────────────
/// Circular progress indicator showing how well the alternative matches the goal.
class _MatchScoreCircle extends StatelessWidget {
  final int score;
  final Color color;
  const _MatchScoreCircle({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 44.w,
          height: 44.h,
          child: CircularProgressIndicator(
            value:           score / 100,
            strokeWidth:     3,
            backgroundColor: color.withOpacity(0.15),
            valueColor:      AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Text(
          '$score%',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ]),
    );
  }
}

// ── Macro bar ─────────────────────────────────────────────────────────────────
/// Small pill showing one macro value (cal / protein / carbs / fat).
class _MacroBar extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;

  const _MacroBar({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusS + 2.r),
        ),
        child: Column(children: [
          Text(
            '$value$unit',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: context.colors.subText,
            ),
          ),
        ]),
      ),
    );
  }
}