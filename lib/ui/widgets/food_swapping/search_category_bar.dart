import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/data/models/food_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category filter definition
// ─────────────────────────────────────────────────────────────────────────────
class SearchCatDef {
  final String id;
  final String label;
  final String emoji;
  final Color accent;
  final Color bg;
  final bool Function(FoodItem) matches;

  const SearchCatDef({
    required this.id,
    required this.label,
    required this.emoji,
    required this.accent,
    required this.bg,
    required this.matches,
  });
}

const _kAllId = '__all__';

final _searchCats = <SearchCatDef>[
  SearchCatDef(
    id: _kAllId,
    label: 'All',
    emoji: '🔍',
    accent: Color(0xFF8E8E93),
    bg: Color(0xFF1C1C1E),
    matches: (_) => true,
  ),
  SearchCatDef(
    id: 'high_protein',
    label: 'High Protein',
    emoji: '🍗',
    accent: Color(0xFF4361EE),
    bg: Color(0xFF1A2340),
    matches: (f) => f.protein >= 15,
  ),
  SearchCatDef(
    id: 'low_protein',
    label: 'Low Protein',
    emoji: '🥗',
    accent: Color(0xFF7986CB),
    bg: Color(0xFF151C35),
    matches: (f) => f.protein <= 5,
  ),
  SearchCatDef(
    id: 'high_calorie',
    label: 'High Calorie',
    emoji: '🔥',
    accent: Color(0xFFFF6D00),
    bg: Color(0xFF2A1500),
    matches: (f) => f.calories >= 400,
  ),
  SearchCatDef(
    id: 'low_calorie',
    label: 'Low Calorie',
    emoji: '🥬',
    accent: Color(0xFF2E7D4F),
    bg: Color(0xFF0E2A1A),
    matches: (f) => f.calories <= 200,
  ),
  SearchCatDef(
    id: 'high_carb',
    label: 'High Carb',
    emoji: '🍚',
    accent: Color(0xFFB07D2E),
    bg: Color(0xFF2A1F0E),
    matches: (f) => f.carbs >= 40,
  ),
  SearchCatDef(
    id: 'low_carb',
    label: 'Low Carb',
    emoji: '🥩',
    accent: Color(0xFF8B2E2E),
    bg: Color(0xFF250E0E),
    matches: (f) => f.carbs <= 10,
  ),
  SearchCatDef(
    id: 'high_fat',
    label: 'High Fat',
    emoji: '🧀',
    accent: Color(0xFF00BFA5),
    bg: Color(0xFF0A2420),
    matches: (f) => f.fats >= 15,
  ),
  SearchCatDef(
    id: 'low_fat',
    label: 'Low Fat',
    emoji: '🍎',
    accent: Color(0xFFE57373),
    bg: Color(0xFF2A1010),
    matches: (f) => f.fats <= 5,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SearchCategoryBar
// ─────────────────────────────────────────────────────────────────────────────
class SearchCategoryBar extends StatefulWidget {
  final String? activeId;
  final ValueChanged<String?> onCategoryChanged;

  static List<FoodItem> filterFoods(List<FoodItem> foods, String? activeId) {
    if (activeId == null || activeId == _kAllId) return foods;
    final def = _searchCats.firstWhere(
      (c) => c.id == activeId,
      orElse: () => _searchCats.first,
    );
    return foods.where(def.matches).toList();
  }

  final bool visible;

  const SearchCategoryBar({
    super.key,
    required this.activeId,
    required this.onCategoryChanged,
    this.visible = true,
  });

  @override
  State<SearchCategoryBar> createState() => _SearchCategoryBarState();
}

class _SearchCategoryBarState extends State<SearchCategoryBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: AppConstants.animationNormal),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    if (widget.visible) _ctrl.forward();
  }

  @override
  void didUpdateWidget(SearchCategoryBar old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _ctrl.forward();
    if (!widget.visible && old.visible) _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _activeId => widget.activeId ?? _kAllId;

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
            padding: EdgeInsets.only(top: AppConstants.spaceS, bottom: 4.h),
            child: SizedBox(
              height: 52.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingXL.toDouble()),
                itemCount: _searchCats.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final cat = _searchCats[i];
                  final isActive = _activeId == cat.id;
                  return _MiniCatCard(
                    cat: cat,
                    isActive: isActive,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onCategoryChanged(
                          cat.id == _kAllId ? null : cat.id);
                    },
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

// ─────────────────────────────────────────────────────────────────────────────
// Mini glass card chip
// ─────────────────────────────────────────────────────────────────────────────
class _MiniCatCard extends StatefulWidget {
  final SearchCatDef cat;
  final bool isActive;
  final VoidCallback onTap;

  const _MiniCatCard({
    required this.cat,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_MiniCatCard> createState() => _MiniCatCardState();
}

class _MiniCatCardState extends State<_MiniCatCard>
    with TickerProviderStateMixin {  // ✅ FIX: changed from SingleTickerProviderStateMixin
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _shimmer.repeat();
  }

  @override
  void didUpdateWidget(_MiniCatCard old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _shimmer.repeat();
    } else if (!widget.isActive && old.isActive) {
      _shimmer.stop();
      _shimmer.reset();
    }
  }

  @override
  void dispose() {
    _press.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = widget.cat;
    final accent = cat.accent;
    final isActive = widget.isActive;

    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_press, _shimmer]),
        builder: (_, __) {
          return Transform.scale(
            scale: 1 - _press.value * 0.06,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              constraints: BoxConstraints(
                minWidth: isActive ? 0 : 52.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(.4),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? .3 : .08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isActive ? 12.w : 10.w, vertical: 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      gradient: isActive
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                accent.withOpacity(.85),
                                Color.lerp(accent, cat.bg, .4)!
                                    .withOpacity(.95),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [
                                      Colors.white.withOpacity(.07),
                                      Colors.white.withOpacity(.03),
                                    ]
                                  : [
                                      Colors.white.withOpacity(.7),
                                      Colors.white.withOpacity(.5),
                                    ],
                            ),
                      border: Border.all(
                        color: isActive
                            ? accent.withOpacity(.6)
                            : accent.withOpacity(isDark ? .25 : .2),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isActive)
                          Positioned.fill(
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment(
                                    -1.5 + _shimmer.value * 3.5, -0.5),
                                end: Alignment(
                                    -1.0 + _shimmer.value * 3.5, 0.5),
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(.25),
                                  Colors.transparent,
                                ],
                              ).createShader(bounds),
                              child: Container(color: Colors.white),
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              cat.emoji,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: isActive
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 5.w),
                                        Text(
                                          cat.label,
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: -.2,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}