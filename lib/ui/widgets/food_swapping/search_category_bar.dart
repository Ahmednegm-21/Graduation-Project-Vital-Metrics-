import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class SearchCategoryBar extends StatefulWidget {
  final String? activeCategory;
  final ValueChanged<String?> onCategoryChanged;
  final bool visible;

  const SearchCategoryBar({
    super.key,
    required this.activeCategory,
    required this.onCategoryChanged,
    required this.visible,
  });

  @override
  State<SearchCategoryBar> createState() => _SearchCategoryBarState();
}

class _SearchCategoryBarState extends State<SearchCategoryBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  static const _cats = [
    _Cat(null,         '🔍', 'All'),
    _Cat('protein',    '🍗', 'Proteins'),
    _Cat('carbs',      '🍚', 'Carbs'),
    _Cat('vegetables', '🥦', 'Veggies'),
    _Cat('fruits',     '🍎', 'Fruits'),
    _Cat('dairy',      '🥛', 'Dairy'),
    _Cat('fats',       '🥑', 'Fats'),
  ];

  // gradients AppColors
  static const Map<String?, List<Color>> _gradients = {
    null:          [Color(0xFF8E8E93), Color(0xFFAEAEB2)],
    'protein':     [AppColors.swapBlue,        AppColors.swapBlueLight],
    'carbs':       [AppColors.swapOrange,       AppColors.swapOrangeLight],
    'vegetables':  [AppColors.swapGreen,        AppColors.swapGreenLight],
    'fruits':      [AppColors.swapRed,          AppColors.swapRedLight],
    'dairy':       [Color(0xFF5AC8FA),          Color(0xFF007AFF)],
    'fats':        [Color(0xFF32D74B),          AppColors.swapGreenLight],
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(
            milliseconds: AppConstants.animationNormal));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    if (widget.visible) _ctrl.forward();
  }

  @override
  void didUpdateWidget(SearchCategoryBar old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible)  _ctrl.forward();
    if (!widget.visible && old.visible)  _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: SizeTransition(
          sizeFactor: _fade,
          axisAlignment: -1,
          child: Padding(
            padding: EdgeInsets.only(
                top: AppConstants.spaceS, bottom: 2.h),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingXL),
                itemCount: _cats.length,
                separatorBuilder: (_, __) =>
                    SizedBox(width: AppConstants.paddingS),
                itemBuilder: (_, i) {
                  final cat      = _cats[i];
                  final isActive = widget.activeCategory == cat.key;
                  final grad     = _gradients[cat.key]!;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onCategoryChanged(cat.key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(
                          milliseconds: AppConstants.animationFast),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(colors: grad)
                            : null,
                        color: isActive ? null : context.colors.card,
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusRound),
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : grad[0].withOpacity(
                                  context.isDark ? 0.3 : 0.2),
                          width: 1.5,
                        ),
                        boxShadow: isActive
                            ? [BoxShadow(
                                color: grad[0].withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3))]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.emoji,
                              style: TextStyle(fontSize: 13.sp)),
                          SizedBox(width: 5.w),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? AppColors.white
                                  : context.colors.subText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cat {
  final String? key;
  final String emoji;
  final String label;
  const _Cat(this.key, this.emoji, this.label);
}