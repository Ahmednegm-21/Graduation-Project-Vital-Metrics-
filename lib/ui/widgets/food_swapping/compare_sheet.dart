// lib/ui/widgets/food_swapping/compare_sheet.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/food_item.dart';

void showCompareSheet(
  BuildContext context, {
  required FoodItem original,
  required FoodItem alternative,
  required List<Color> altGradient,
  required bool isArabic,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    builder: (_) => _CompareSheet(
      original:    original,
      alternative: alternative,
      altGradient: altGradient,
      isArabic:    isArabic,
    ),
  );
}

class _CompareSheet extends StatefulWidget {
  final FoodItem original;
  final FoodItem alternative;
  final List<Color> altGradient;
  final bool isArabic;
  const _CompareSheet({
    required this.original,
    required this.alternative,
    required this.altGradient,
    required this.isArabic,
  });

  @override
  State<_CompareSheet> createState() => _CompareSheetState();
}

class _CompareSheetState extends State<_CompareSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _barAnim  = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = context.isDark;
    final isArabic = widget.isArabic;
    final orig     = widget.original;
    final alt      = widget.alternative;

    // DraggableScrollableSheet handles dragging together with the scroll view
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize:     0.4,
      maxChildSize:     0.95,
      snap:             true,
      snapSizes:        const [0.4, 0.85],
      builder: (_, scrollCtrl) => FadeTransition(
        opacity: _fadeAnim,
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1E35).withOpacity(0.97)
                    : Colors.white.withOpacity(0.97),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.fromLTRB(
                    20.w, 12.h, 20.w,
                    MediaQuery.of(context).padding.bottom + 24.h),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w, height: 4.h,
                      decoration: BoxDecoration(
                        color: context.colors.subText.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  Text(
                    'Side-by-Side Comparison',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: context.colors.text,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Per 100g serving',
                    style: TextStyle(
                        fontSize: 12.sp, color: context.colors.subText),
                  ),
                  SizedBox(height: 20.h),

                  // Food headers
                  Row(children: [
                    Expanded(
                      child: _FoodHeader(
                        food: orig,
                        isArabic: isArabic,
                        gradient: const [
                          Color(0xFF8E8E93),
                          Color(0xFFAEAEB2),
                        ],
                        label: 'Original',
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _FoodHeader(
                        food: alt,
                        isArabic: isArabic,
                        gradient: widget.altGradient,
                        label: 'Alternative',
                      ),
                    ),
                  ]),
                  SizedBox(height: 24.h),

                  // Macro rows
                  ..._macros(orig, alt).map((m) => AnimatedBuilder(
                        animation: _barAnim,
                        builder: (_, __) => _MacroCompareRow(
                          label:       m.label,
                          origValue:   m.origValue,
                          altValue:    m.altValue,
                          unit:        m.unit,
                          color:       m.color,
                          altGradient: widget.altGradient,
                          progress:    _barAnim.value,
                        ),
                      )),

                  SizedBox(height: 20.h),

                  _WinnerSummary(
                    original:    orig,
                    alternative: alt,
                    altGradient: widget.altGradient,
                  ),

                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_MacroData> _macros(FoodItem orig, FoodItem alt) => [
        _MacroData('Calories', orig.calories, alt.calories, 'kcal', Colors.orange),
        _MacroData('Protein',  orig.protein,  alt.protein,  'g', const Color(0xFF4361EE)),
        _MacroData('Carbs',    orig.carbs,    alt.carbs,    'g', const Color(0xFF34C759)),
        _MacroData('Fats',     orig.fats,     alt.fats,     'g', Colors.purple),
      ];
}

// Food header card
class _FoodHeader extends StatelessWidget {
  final FoodItem food;
  final bool isArabic;
  final List<Color> gradient;
  final String label;
  const _FoodHeader({
    required this.food,
    required this.isArabic,
    required this.gradient,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient[0].withOpacity(0.15),
            gradient[1].withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: gradient[0].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
          SizedBox(height: 10.h),
          Text(food.emoji, style: TextStyle(fontSize: 30.sp)),
          SizedBox(height: 6.h),
          Text(food.displayName(isArabic: isArabic),
              maxLines: 2,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: context.colors.text)),
          SizedBox(height: 4.h),
          Text('${food.calories.round()} kcal',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: gradient[0],
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// Macro row
class _MacroCompareRow extends StatelessWidget {
  final String label;
  final double origValue;
  final double altValue;
  final String unit;
  final Color color;
  final List<Color> altGradient;
  final double progress;

  const _MacroCompareRow({
    required this.label,    required this.origValue,
    required this.altValue, required this.unit,
    required this.color,    required this.altGradient,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark   = context.isDark;
    final maxVal   = [origValue, altValue, 1.0].reduce((a, b) => a > b ? a : b);
    final origFrac = progress * (origValue / maxVal).clamp(0.0, 1.0);
    final altFrac  = progress * (altValue  / maxVal).clamp(0.0, 1.0);

    final higherIsBetter = label == 'Protein';
    final altWins = higherIsBetter ? altValue > origValue : altValue < origValue;
    final diff    = (altValue - origValue).abs();
    final diffStr = diff < 0.5
        ? '≈ same'
        : (altWins ? '▼' : '▲') + ' ${diff.round()}$unit';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 8.w, height: 8.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.w),
            Text(label,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.text)),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: diff < 0.5
                    ? context.colors.subText.withOpacity(0.1)
                    : altWins
                        ? const Color(0xFF34C759).withOpacity(0.15)
                        : const Color(0xFFFF3B30).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(diffStr,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: diff < 0.5
                        ? context.colors.subText
                        : altWins
                            ? const Color(0xFF34C759)
                            : const Color(0xFFFF3B30),
                  )),
            ),
          ]),
          SizedBox(height: 8.h),
          _BarRow(label: 'Original', value: origValue, unit: unit,
              fraction: origFrac, color: color.withOpacity(0.5), isDark: isDark),
          SizedBox(height: 5.h),
          _BarRow(label: 'Alt', value: altValue, unit: unit,
              fraction: altFrac, color: altGradient[0], isDark: isDark, isAlt: true),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double fraction;
  final Color color;
  final bool isDark;
  final bool isAlt;

  const _BarRow({
    required this.label, required this.value, required this.unit,
    required this.fraction, required this.color, required this.isDark,
    this.isAlt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 36.w,
        child: Text(label,
            style: TextStyle(
                fontSize: 9.sp,
                color: context.colors.subText,
                fontWeight: FontWeight.w600)),
      ),
      Expanded(
        child: Stack(children: [
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0.0, 1.0),
            child: Container(
              height: 8.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)]),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2))],
              ),
            ),
          ),
        ]),
      ),
      SizedBox(width: 8.w),
      SizedBox(
        width: 42.w,
        child: Text('${value.round()}$unit',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: color)),
      ),
    ]);
  }
}

// Winner summary
class _WinnerSummary extends StatelessWidget {
  final FoodItem original;
  final FoodItem alternative;
  final List<Color> altGradient;

  const _WinnerSummary({
    required this.original,
    required this.alternative,
    required this.altGradient,
  });

  @override
  Widget build(BuildContext context) {
    final wins = <String>[];
    if (alternative.protein > original.protein + 2) {
      wins.add('💪 +${(alternative.protein - original.protein).round()}g protein');
    }
    if (alternative.calories < original.calories - 15) {
      wins.add('🔥 -${(original.calories - alternative.calories).round()} kcal');
    }
    if (alternative.carbs < original.carbs - 5) {
      wins.add('⚡ -${(original.carbs - alternative.carbs).round()}g carbs');
    }
    if (alternative.fats < original.fats - 3) {
      wins.add('✨ -${(original.fats - alternative.fats).round()}g fat');
    }

    if (wins.isEmpty) {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(children: [
          Text('⚖️', style: TextStyle(fontSize: 20.sp)),
          SizedBox(width: 10.w),
          Expanded(
            child: Text('Both foods have a similar nutritional profile.',
                style: TextStyle(
                    fontSize: 12.sp, color: context.colors.subText)),
          ),
        ]),
      );
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            altGradient[0].withOpacity(0.12),
            altGradient[1].withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: altGradient[0].withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('🏆', style: TextStyle(fontSize: 16.sp)),
            SizedBox(width: 6.w),
            Text('Why this swap?',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.text)),
          ]),
          SizedBox(height: 8.h),
          ...wins.map((w) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(w,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colors.text,
                        fontWeight: FontWeight.w600)),
              )),
        ],
      ),
    );
  }
}

class _MacroData {
  final String label;
  final double origValue;
  final double altValue;
  final String unit;
  final Color color;
  const _MacroData(
      this.label, this.origValue, this.altValue, this.unit, this.color);
}