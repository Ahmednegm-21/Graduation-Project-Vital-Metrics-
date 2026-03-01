import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/services/food_swap_service.dart';

class CategoryExplorer extends StatefulWidget {
  final ValueChanged<FoodItem> onSelect;
  const CategoryExplorer({super.key, required this.onSelect});

  @override
  State<CategoryExplorer> createState() => _CategoryExplorerState();
}

class _CategoryExplorerState extends State<CategoryExplorer>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  String? _selectedCategory;
  late AnimationController _gridCtrl;
  late Animation<double> _gridScale;
  late Animation<double> _gridFade;
  List<FoodItem> _categoryFoods = [];
  late AnimationController _itemCtrl;

  static const _categories = [
    _CatMeta('protein',    '🍗', 'Proteins',
        [AppColors.swapBlue,       AppColors.swapBlueLight]),
    _CatMeta('carbs',      '🍚', 'Carbs',
        [AppColors.swapOrange,     AppColors.swapOrangeLight]),
    _CatMeta('vegetables', '🥦', 'Vegetables',
        [AppColors.swapGreen,      AppColors.swapGreenLight]),
    _CatMeta('fruits',     '🍎', 'Fruits',
        [AppColors.swapRed,        AppColors.swapRedLight]),
    _CatMeta('dairy',      '🥛', 'Dairy',
        [Color(0xFF5AC8FA),        Color(0xFF007AFF)]),
    _CatMeta('fats',       '🥑', 'Healthy Fats',
        [Color(0xFF32D74B),        AppColors.swapGreenLight]),
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900))
      ..forward();

    _gridCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: AppConstants.animationNormal));
    _gridScale = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: _gridCtrl, curve: Curves.easeOutBack));
    _gridFade =
        CurvedAnimation(parent: _gridCtrl, curve: Curves.easeOut);

    _itemCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: AppConstants.animationSlow));
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _gridCtrl.dispose();
    _itemCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectCategory(String key) async {
    HapticFeedback.selectionClick();
    if (_selectedCategory == key) {
      await _gridCtrl.reverse();
      setState(() => _selectedCategory = null);
      return;
    }
    if (_selectedCategory != null) await _gridCtrl.reverse();

    setState(() {
      _selectedCategory = key;
      _categoryFoods    = FoodSwapService().byCategory(key);
    });
    _itemCtrl.reset();
    _gridCtrl
      ..reset()
      ..forward();
    _itemCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tip banner
          _EntranceItem(ctrl: _entranceCtrl, index: 0, total: 8,
            child: Container(
              padding: EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.swapGreen.withOpacity(0.12),
                  AppColors.swapGreenLight.withOpacity(0.04),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                border: Border.all(
                    color: AppColors.swapGreen.withOpacity(0.2)),
              ),
              child: Row(children: [
                Text('💡', style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: AppConstants.spaceS),
                Expanded(
                  child: Text(
                    'Pick a category or search above to find smarter swaps',
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colors.text,
                        height: 1.4),
                  ),
                ),
              ]),
            ),
          ),
          SizedBox(height: AppConstants.spaceXXL),

          // Section title
          _EntranceItem(ctrl: _entranceCtrl, index: 1, total: 8,
            child: Text('Explore by Category',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: context.colors.text)),
          ),
          SizedBox(height: AppConstants.spaceM),

          // Category grid
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.paddingM,
              mainAxisSpacing: AppConstants.paddingM,
              mainAxisExtent: 72.h,
            ),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat      = _categories[i];
              final isActive = _selectedCategory == cat.key;
              return _EntranceItem(
                ctrl: _entranceCtrl, index: i + 2, total: 8,
                child: _CategoryCard(
                  meta:     cat,
                  isActive: isActive,
                  count:    FoodSwapService().byCategory(cat.key).length,
                  onTap:    () => _selectCategory(cat.key),
                ),
              );
            },
          ),

          // Expanded food grid
          AnimatedSize(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            child: _selectedCategory == null
                ? const SizedBox.shrink()
                : FadeTransition(
                    opacity: _gridFade,
                    child: ScaleTransition(
                      scale: _gridScale,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppConstants.spaceXL),
                          Row(children: [
                            Text(
                              _categories
                                  .firstWhere((c) =>
                                      c.key == _selectedCategory)
                                  .emoji,
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            SizedBox(width: AppConstants.paddingS),
                            Text(
                              _categories
                                  .firstWhere((c) =>
                                      c.key == _selectedCategory)
                                  .label,
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: context.colors.text),
                            ),
                            const Spacer(),
                            Text('${_categoryFoods.length} items',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: context.colors.subText)),
                          ]),
                          SizedBox(height: AppConstants.paddingM),
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: AppConstants.spaceS,
                              mainAxisSpacing: AppConstants.spaceS,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: _categoryFoods.length,
                            itemBuilder: (_, i) {
                              final food  = _categoryFoods[i];
                              final delay = i * 0.12;
                              final anim  = CurvedAnimation(
                                parent: _itemCtrl,
                                curve: Interval(
                                    delay,
                                    (delay + 0.45).clamp(0.0, 1.0),
                                    curve: Curves.easeOutBack),
                              );
                              final fadeAnim = CurvedAnimation(
                                parent: _itemCtrl,
                                curve: Interval(
                                    delay,
                                    (delay + 0.35).clamp(0.0, 1.0),
                                    curve: Curves.easeOut),
                              );
                              return FadeTransition(
                                opacity: fadeAnim,
                                child: ScaleTransition(
                                  scale: anim,
                                  child: _FoodTile(
                                    food:     food,
                                    gradient: _categories
                                        .firstWhere((c) =>
                                            c.key == _selectedCategory)
                                        .gradient,
                                    onTap: () => widget.onSelect(food),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          SizedBox(height: AppConstants.spaceXXL),
        ],
      ),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final _CatMeta meta;
  final bool isActive;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.meta,
    required this.isActive,
    required this.count,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 90));
    _pressScale = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final grad   = widget.meta.gradient;
    final active = widget.isActive;

    return GestureDetector(
      onTapDown:  (_) => _pressCtrl.forward(),
      onTapUp:    (_) { _pressCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(
              milliseconds: AppConstants.animationNormal),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.spaceS),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: grad,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : LinearGradient(colors: [
                    grad[0].withOpacity(isDark ? 0.12 : 0.08),
                    grad[1].withOpacity(isDark ? 0.06 : 0.04),
                  ]),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: active
                  ? Colors.transparent
                  : grad[0].withOpacity(isDark ? 0.3 : 0.25),
              width: 1.5,
            ),
            boxShadow: active
                ? [BoxShadow(
                    color: grad[0].withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6))]
                : [BoxShadow(
                    color: grad[0].withOpacity(isDark ? 0.08 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3))],
          ),
          child: Row(children: [
            Text(widget.meta.emoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: AppConstants.paddingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.meta.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        color: active ? AppColors.white : context.colors.text,
                      )),
                  SizedBox(height: 2.h),
                  Text('${widget.count} foods',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: active
                            ? Colors.white.withOpacity(0.75)
                            : context.colors.subText,
                      )),
                ],
              ),
            ),
            AnimatedRotation(
              turns: active ? 0.25 : 0.0,
              duration:
                  const Duration(milliseconds: AppConstants.animationNormal),
              curve: Curves.easeOutCubic,
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 12.sp,
                  color: active
                      ? Colors.white.withOpacity(0.8)
                      : grad[0].withOpacity(0.7)),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Food tile ─────────────────────────────────────────────────────────────────
class _FoodTile extends StatelessWidget {
  final FoodItem food;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FoodTile({
    required this.food,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(
            color: gradient[0]
                .withOpacity(context.isDark ? 0.2 : 0.15),
          ),
          boxShadow: [BoxShadow(
            color: gradient[0].withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42.w, height: 42.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  gradient[0].withOpacity(0.15),
                  gradient[1].withOpacity(0.07),
                ]),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(food.emoji,
                      style: TextStyle(fontSize: 22.sp))),
            ),
            SizedBox(height: 6.h),
            Text(food.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.text)),
            SizedBox(height: 2.h),
            Text('${food.calories.round()} kcal',
                style: TextStyle(
                    fontSize: 9.sp,
                    color: gradient[0],
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Entrance stagger ──────────────────────────────────────────────────────────
class _EntranceItem extends StatelessWidget {
  final AnimationController ctrl;
  final int index;
  final int total;
  final Widget child;

  const _EntranceItem({
    required this.ctrl,
    required this.index,
    required this.total,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = ((index / total) * 0.65).clamp(0.0, 0.7);
    final end   = (start + 0.45).clamp(0.0, 1.0);
    final anim  = CurvedAnimation(
        parent: ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }
}

// ── Category metadata ─────────────────────────────────────────────────────────
class _CatMeta {
  final String key;
  final String emoji;
  final String label;
  final List<Color> gradient;
  const _CatMeta(this.key, this.emoji, this.label, this.gradient);
}