import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/logic/food_swapping/food_swapping_cubit.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _searchCtrl = TextEditingController();
  String _query  = '';
  bool _loading  = true;

  @override
  void initState() {
    super.initState();
    context.read<FoodSwapCubit>().loadFavorites().then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Column(children: [
        _buildHeader(context),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
          child: _buildSearchBar(context),
        ),
        SizedBox(height: AppConstants.spaceL),
        Expanded(child: _buildBody(context)),
      ]),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
            color: AppColors.favoriteOrange),
      );
    }

    final items = context.read<FoodSwapCubit>().getFavoriteItems();
    final filtered = _query.isEmpty
        ? items
        : items
            .where((f) =>
                f.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    if (items.isEmpty)    return _buildEmpty(context);
    if (filtered.isEmpty) return _buildNoResults(context);

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _FavoriteCard(
        food:       filtered[i],
        index:      i,
        onRemove:   () async {
          await context
              .read<FoodSwapCubit>()
              .toggleFavorite(filtered[i].id);
          setState(() {});
        },
        onAddToLog: () => _showAddToLogSheet(context, filtered[i]),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final count = _loading
        ? 0
        : context.read<FoodSwapCubit>().getFavoriteItems().length;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppConstants.paddingXL,
          MediaQuery.of(context).padding.top + AppConstants.paddingM,
          AppConstants.paddingXL, AppConstants.paddingXL),
      child: Row(children: [
        // Back
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                  color: context.isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.06)),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: AppConstants.iconXS, color: context.colors.text),
          ),
        ),
        SizedBox(width: AppConstants.paddingM),

        // Title
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text('Saved Foods',
                style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: context.colors.text,
                    letterSpacing: -0.5)),
            Text('Your favorite alternatives',
                style: TextStyle(
                    fontSize: 12.sp, color: context.colors.subText)),
          ]),
        ),

        // Count badge
        Container(
          width: 40.w, height: 40.h,
          decoration: BoxDecoration(
            gradient: AppColors.favoriteGradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            boxShadow: [BoxShadow(
                color: AppColors.favoriteOrange.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4))],
          ),
          child: Center(
            child: Text('$count',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white)),
          ),
        ),
      ]),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
            color: context.isDark
                ? Colors.white.withOpacity(0.10)
                : Colors.black.withOpacity(0.07)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        style: TextStyle(
            fontSize: 15.sp,
            color: context.colors.text,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search saved foods...',
          hintStyle: TextStyle(
              fontSize: 14.sp,
              color: context.colors.subText.withOpacity(0.45)),
          prefixIcon: Icon(Icons.search_rounded,
              color: AppColors.favoriteOrange, size: 22.sp),
          suffixIcon: _query.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() {
                    _searchCtrl.clear();
                    _query = '';
                  }),
                  child: Icon(Icons.close_rounded,
                      color: context.colors.subText, size: 18.sp))
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingXS,
              vertical: 15.h),
        ),
      ),
    );
  }

  // ── Empty states ─────────────────────────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🔖', style: TextStyle(fontSize: 56.sp)),
        SizedBox(height: AppConstants.spaceL),
        Text('No saved foods yet',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: context.colors.text)),
        SizedBox(height: AppConstants.spaceS),
        Text('Tap the bookmark icon on any\nalternative to save it here',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp,
                color: context.colors.subText,
                height: 1.5)),
      ]),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('😕', style: TextStyle(fontSize: 44.sp)),
        SizedBox(height: AppConstants.spaceM),
        Text('No results for "$_query"',
            style: TextStyle(
                fontSize: 14.sp, color: context.colors.subText)),
      ]),
    );
  }

  // ── Add to log sheet ─────────────────────────────────────────────────────────
  void _showAddToLogSheet(BuildContext context, FoodItem food) {
    String selectedMeal = 'lunch';
    double grams        = AppConstants.portionDefault;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(AppConstants.paddingXL),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppConstants.paddingXXL)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Handle
              Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                    color: context.colors.subText.withOpacity(0.3),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusS / 2)),
              ),
              SizedBox(height: AppConstants.spaceXL),
              Text('Add to Meal Log',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: context.colors.text)),
              SizedBox(height: 6.h),
              Text('${food.emoji} ${food.name}',
                  style: TextStyle(
                      fontSize: 14.sp, color: context.colors.subText)),
              SizedBox(height: AppConstants.spaceXL),

              // Portion slider
              Row(children: [
                Icon(Icons.scale_rounded,
                    size: 14.sp, color: AppColors.swapBlue),
                SizedBox(width: 6.w),
                Text('Portion',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: context.colors.text)),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceS,
                      vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.swapBlue, AppColors.swapBlueLight]),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Text('${grams.round()}g',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white)),
                ),
              ]),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.swapBlue,
                  inactiveTrackColor: AppColors.swapBlue.withOpacity(0.15),
                  thumbColor: AppColors.swapBlue,
                  overlayColor: AppColors.swapBlue.withOpacity(0.12),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: grams,
                  min: AppConstants.portionMin,
                  max: AppConstants.portionMax,
                  divisions: AppConstants.portionDivisions,
                  onChanged: (v) => setS(() => grams = v),
                ),
              ),

              // Meal type
              Row(
                children:
                    ['breakfast', 'lunch', 'dinner', 'snacks'].map((m) {
                  final on = selectedMeal == m;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setS(() => selectedMeal = m),
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: AppConstants.animationFast),
                        margin: EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingXS),
                        padding: EdgeInsets.symmetric(
                            vertical: AppConstants.spaceS),
                        decoration: BoxDecoration(
                          gradient: on
                              ? AppColors.favoriteGradient
                              : null,
                          color: on ? null : context.colors.bg,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusM),
                          border: Border.all(
                              color: on
                                  ? Colors.transparent
                                  : context.colors.subText.withOpacity(0.2)),
                        ),
                        child: Text(_mealEmoji(m),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.sp)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: AppConstants.spaceS),
              Row(
                children: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                    .map((m) => Expanded(
                          child: Text(m,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 9.sp,
                                  color: context.colors.subText,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
              SizedBox(height: AppConstants.spaceXXL),

              // Confirm button
              GestureDetector(
                onTap: () {
                  final scaled = food.scaledTo(grams);
                  context.read<CalorieCubit>().addMeal(MealEntry(
                    name:     food.name,
                    calories: scaled.calories.round(),
                    protein:  scaled.protein.round(),
                    carbs:    scaled.carbs.round(),
                    fat:      scaled.fats.round(),
                    mealType: selectedMeal,
                  ));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${food.emoji} ${food.name} added to $selectedMeal!',
                        style: const TextStyle(color: AppColors.white)),
                    backgroundColor: AppColors.favoriteOrange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusM)),
                    duration: const Duration(seconds: 2),
                  ));
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  decoration: BoxDecoration(
                    gradient: AppColors.favoriteGradient,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusL),
                    boxShadow: [BoxShadow(
                        color: AppColors.favoriteOrange.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))],
                  ),
                  child: Text('Add to Log',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white)),
                ),
              ),
              SizedBox(height: AppConstants.spaceS),
            ]),
          ),
        ),
      ),
    );
  }

  String _mealEmoji(String meal) {
    switch (meal) {
      case 'breakfast': return '🌅';
      case 'lunch':     return '☀️';
      case 'dinner':    return '🌙';
      case 'snacks':    return '🍎';
      default:          return '🍽️';
    }
  }
}

// ── Favorite card ─────────────────────────────────────────────────────────────
class _FavoriteCard extends StatelessWidget {
  final FoodItem food;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onAddToLog;

  const _FavoriteCard({
    required this.food,
    required this.index,
    required this.onRemove,
    required this.onAddToLog,
  });

  @override
  Widget build(BuildContext context) {
    final grad   = AppColors.swapGradient(index);
    final isDark = context.isDark;

    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.spaceM),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(
            color: grad[0].withOpacity(isDark ? 0.10 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        // Top row
        Padding(
          padding: EdgeInsets.fromLTRB(AppConstants.paddingL,
              AppConstants.paddingL, AppConstants.paddingL,
              AppConstants.paddingM),
          child: Row(children: [
            Container(
              width: 52.w, height: 52.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  grad[0].withOpacity(0.15),
                  grad[1].withOpacity(0.08),
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(child: Text(food.emoji,
                  style: TextStyle(fontSize: 26.sp))),
            ),
            SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(food.name,
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: context.colors.text)),
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingS, vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: grad),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound),
                  ),
                  child: Text(food.category,
                      style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white)),
                ),
              ]),
            ),
            // Remove bookmark
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 36.w, height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.favoriteOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(Icons.bookmark_rounded,
                    color: AppColors.favoriteOrange, size: 18.sp),
              ),
            ),
          ]),
        ),

        Divider(height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05)),

        // Macros
        Padding(
          padding: EdgeInsets.fromLTRB(AppConstants.paddingL,
              AppConstants.spaceS, AppConstants.paddingL,
              AppConstants.spaceM),
          child: Row(children: [
            _MacroChip('${food.calories.round()}', 'kcal', AppColors.protein),
            SizedBox(width: AppConstants.paddingS),
            _MacroChip('${food.protein.round()}g', 'Prot', AppColors.swapBlue),
            SizedBox(width: AppConstants.paddingS),
            _MacroChip('${food.carbs.round()}g', 'Carb', grad[0]),
            SizedBox(width: AppConstants.paddingS),
            _MacroChip('${food.fats.round()}g', 'Fat', AppColors.swapPurple),
          ]),
        ),

        // Add to log
        Padding(
          padding: EdgeInsets.fromLTRB(AppConstants.paddingL, 0,
              AppConstants.paddingL, AppConstants.spaceM),
          child: GestureDetector(
            onTap: onAddToLog,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: AppConstants.spaceS),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: grad),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                boxShadow: [BoxShadow(
                    color: grad[0].withOpacity(0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline_rounded,
                      color: AppColors.white, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text('Add to Log',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white)),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MacroChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(AppConstants.radiusS)),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontSize: 9.sp, color: context.colors.subText)),
        ]),
      ),
    );
  }
}