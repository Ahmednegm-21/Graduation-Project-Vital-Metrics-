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
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  List<FoodItem> _backendMeals = [];
  bool _loadingBackend = false;

  // All foods merged (backend + local)
  List<FoodItem> get _allFoods {
    final local      = FoodSwapService().allFoods;
    final backendIds = _backendMeals.map((f) => f.id).toSet();
    return [
      ..._backendMeals,
      ...local.where((f) => !backendIds.contains(f.id)),
    ];
  }

  // Popular foods shown as quick picks
  static const _popularIds = [
    'chicken_breast', 'white_rice', 'eggs',
    'salmon', 'oats', 'sweet_potato',
    'broccoli', 'banana', 'beef',
    'greek_yogurt', 'tuna', 'almonds',
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800))
      ..forward();
    _loadBackendMeals();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBackendMeals() async {
    if (!mounted) return;
    setState(() => _loadingBackend = true);
    try {
      final meals = await FoodSwapService().getMealsFromBackend(limit: 100);
      if (mounted) setState(() {
        _backendMeals   = meals;
        _loadingBackend = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingBackend = false);
    }
  }

  List<FoodItem> get _popularFoods {
    final all = _allFoods;
    // First show popular ids, then any backend meals not in popular list
    final popular = _popularIds
        .map((id) {
          try { return all.firstWhere((f) => f.id == id); }
          catch (_) { return null; }
        })
        .whereType<FoodItem>()
        .toList();

    // Add backend meals not already in popular
    final popularIds = popular.map((f) => f.id).toSet();
    final extra = _backendMeals.where((f) => !popularIds.contains(f.id)).toList();

    return [...popular, ...extra];
  }

  @override
  Widget build(BuildContext context) {
    final foods = _popularFoods;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero ────────────────────────────────────────────────────────
          FadeTransition(
            opacity: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
            child: _HeroSection(),
          ),
          SizedBox(height: AppConstants.spaceXXL),

          // ── Section title ────────────────────────────────────────────────
          FadeTransition(
            opacity: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
            child: Row(children: [
              Text('Popular Foods',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.text)),
              const Spacer(),
              if (_loadingBackend)
                SizedBox(
                  width: 14.w, height: 14.h,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.swapGreen),
                ),
            ]),
          ),
          SizedBox(height: 6.h),
          FadeTransition(
            opacity: CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
            child: Text(
              'Tap any food to find smarter alternatives',
              style: TextStyle(
                  fontSize: 12.sp, color: context.colors.subText),
            ),
          ),
          SizedBox(height: AppConstants.spaceL),

          // ── Popular foods grid ───────────────────────────────────────────
          foods.isEmpty
              ? _EmptyState(isLoading: _loadingBackend)
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   3,
                    crossAxisSpacing: AppConstants.spaceS,
                    mainAxisSpacing:  AppConstants.spaceS,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: foods.length,
                  itemBuilder: (_, i) {
                    final food  = foods[i];
                    final delay = (i * 0.05).clamp(0.0, 0.5);
                    final anim  = CurvedAnimation(
                      parent: _entranceCtrl,
                      curve: Interval(
                          0.3 + delay,
                          (0.3 + delay + 0.4).clamp(0.0, 1.0),
                          curve: Curves.easeOutBack),
                    );
                    return ScaleTransition(
                      scale: anim,
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _entranceCtrl,
                          curve: Interval(
                              0.3 + delay,
                              (0.3 + delay + 0.35).clamp(0.0, 1.0),
                              curve: Curves.easeOut),
                        ),
                        child: _FoodTile(
                          food:  food,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onSelect(food);
                          },
                        ),
                      ),
                    );
                  },
                ),

          SizedBox(height: AppConstants.spaceXXL),
        ],
      ),
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.swapGreen.withOpacity(0.15),
            AppColors.swapBlue.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.swapGreen.withOpacity(0.2)),
      ),
      child: Row(children: [
        SizedBox(
          width: 56.w, height: 56.h,
          child: Stack(children: [
            Positioned(top: 0, left: 0,
                child: Text('🍗', style: TextStyle(fontSize: 24.sp))),
            Positioned(bottom: 0, right: 0,
                child: Text('🥦', style: TextStyle(fontSize: 24.sp))),
            Positioned(top: 12.h, left: 14.w,
                child: Text('🔄', style: TextStyle(
                    fontSize: 18.sp,
                    shadows: [Shadow(
                        color: AppColors.swapGreen.withOpacity(0.5),
                        blurRadius: 8)]))),
          ]),
        ),
        SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Smart Food Swaps',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: context.colors.text,
                      letterSpacing: -0.3)),
              SizedBox(height: 4.h),
              Text(
                'Search any food or pick one below to find healthier alternatives',
                style: TextStyle(
                    fontSize: 11.sp,
                    color: context.colors.subText,
                    height: 1.4),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Food tile ─────────────────────────────────────────────────────────────────
class _FoodTile extends StatefulWidget {
  final FoodItem food;
  final VoidCallback onTap;
  const _FoodTile({required this.food, required this.onTap});

  @override
  State<_FoodTile> createState() => _FoodTileState();
}

class _FoodTileState extends State<_FoodTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  // Pick color based on food category
  Color get _color {
    switch (widget.food.category) {
      case 'protein': return AppColors.swapBlue;
      case 'carbs':   return AppColors.swapOrange;
      case 'vegetables': return AppColors.swapGreen;
      case 'fruits':  return AppColors.swapRed;
      case 'dairy':   return const Color(0xFF5AC8FA);
      case 'fats':    return const Color(0xFF32D74B);
      default:        return AppColors.swapGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return GestureDetector(
      onTapDown:   (_) => _press.forward(),
      onTapUp:     (_) { _press.reverse(); widget.onTap(); },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) => Transform.scale(
            scale: 1.0 - (_press.value * 0.05), child: child),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
                color: color.withOpacity(context.isDark ? 0.25 : 0.18)),
            boxShadow: [BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji circle
              Container(
                width: 48.w, height: 48.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    color.withOpacity(0.18),
                    color.withOpacity(0.07),
                  ]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(widget.food.emoji,
                        style: TextStyle(fontSize: 24.sp))),
              ),
              SizedBox(height: 8.h),
              // Name
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(widget.food.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.text)),
              ),
              SizedBox(height: 3.h),
              // Calories badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('${widget.food.calories.round()} kcal',
                    style: TextStyle(
                        fontSize: 9.sp,
                        color: color,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isLoading;
  const _EmptyState({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            SizedBox(
              width: 32.w, height: 32.h,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.swapGreen),
            ),
            SizedBox(height: AppConstants.spaceM),
            Text('Loading foods...',
                style: TextStyle(
                    fontSize: 13.sp, color: context.colors.subText)),
          ] else ...[
            Text('🥗', style: TextStyle(fontSize: 40.sp)),
            SizedBox(height: AppConstants.spaceM),
            Text('No foods available yet',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.text)),
            SizedBox(height: AppConstants.spaceS),
            Text('Try searching for a food above',
                style: TextStyle(
                    fontSize: 12.sp, color: context.colors.subText)),
          ],
        ],
      ),
    );
  }
}