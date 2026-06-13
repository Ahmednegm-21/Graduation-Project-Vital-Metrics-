import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/data/models/user_goal.dart';
import 'package:vital_metrics/logic/food_swapping/food_swapping_cubit.dart';
import 'package:vital_metrics/logic/food_swapping/food_swapping_state.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/ui/widgets/food_swapping/category_explorer.dart';
import 'package:vital_metrics/ui/widgets/food_swapping/search_category_bar.dart';
import 'package:vital_metrics/ui/widgets/food_swapping/swap_card.dart';

class FoodSwappingScreen extends StatelessWidget {
  const FoodSwappingScreen({super.key});

  String _mapGoal(UserGoal? goal) {
    if (goal == null) return 'maintain';
    switch (goal.type) {
      case GoalType.gainWeight: return 'build muscle';
      case GoalType.loseWeight: return 'lose weight';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userGoal = _mapGoal(
      context.read<OnboardingCubitAllData>().currentData.goal,
    );
    return BlocProvider(
      create: (_) => FoodSwapCubit(userGoal: userGoal),
      child: const _FoodSwappingView(),
    );
  }
}

class _FoodSwappingView extends StatefulWidget {
  const _FoodSwappingView();
  @override
  State<_FoodSwappingView> createState() => _FoodSwappingViewState();
}

class _FoodSwappingViewState extends State<_FoodSwappingView>
    with TickerProviderStateMixin {
  final _searchCtrl      = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool  _searchFocused   = false;

  late AnimationController _headerCtrl;
  late Animation<double>   _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.animationSlow),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);

    _searchFocusNode.addListener(
      () => setState(() => _searchFocused = _searchFocusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _headerCtrl.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Column(
        children: [
          FadeTransition(
            opacity: _headerFade,
            child: _Header(onBack: () => context.pop()),
          ),

          // ── Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
            child: _SearchBar(
              controller: _searchCtrl,
              focusNode:  _searchFocusNode,
              onChanged:  (q) => context.read<FoodSwapCubit>().search(q),
              onClear: () {
                _searchCtrl.clear();
                context.read<FoodSwapCubit>().reset();
              },
            ),
          ),

          // ── Category filter bar
          BlocBuilder<FoodSwapCubit, FoodSwapState>(
            builder: (ctx, state) {
              final cubit   = ctx.read<FoodSwapCubit>();
              final catId   = cubit.searchCategory;
              // اظهر الـ bar لو: focused أو فيه category مختار
              final visible = _searchFocused || catId != null;
              return SearchCategoryBar(
                visible:           visible,
                activeId:          catId,
                onCategoryChanged: (id) {
                  // ✅ دايماً نستدعي setSearchCategory
                  // الـ cubit هو اللي يقرر يعمل search أو لأ
                  cubit.setSearchCategory(id);
                },
              );
            },
          ),

          SizedBox(height: AppConstants.spaceL),

          Expanded(
            child: BlocBuilder<FoodSwapCubit, FoodSwapState>(
              builder: (ctx, state) {
                // ── Initial: اظهر CategoryExplorer
                if (state is FoodSwapInitial) {
                  return CategoryExplorer(
                    onSelect: (f) {
                      _searchCtrl.text = f.name;
                      _searchFocusNode.unfocus();
                      ctx.read<FoodSwapCubit>().selectFood(f);
                    },
                  );
                }

                // ── Searching: اظهر نتايج البحث
                if (state is FoodSwapSearching) {
                  return _SearchResults(
                    results:  state.results,
                    query:    state.query,
                    onSelect: (f) {
                      _searchCtrl.text = f.name;
                      _searchFocusNode.unfocus();
                      ctx.read<FoodSwapCubit>().selectFood(f);
                    },
                  );
                }

                // ── Loaded: اظهر الـ swaps
                if (state is FoodSwapLoaded) {
                  return _SwapResults(
                    state:   state,
                    onReset: () {
                      _searchCtrl.clear();
                      ctx.read<FoodSwapCubit>().reset();
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingXL,
        MediaQuery.of(context).padding.top + AppConstants.paddingM,
        AppConstants.paddingXL,
        AppConstants.paddingXL,
      ),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size:  AppConstants.iconXS,
              color: context.colors.text,
            ),
          ),
        ),
        SizedBox(width: AppConstants.paddingM),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Food Swapping',
                style: TextStyle(
                  fontSize:   22.sp,
                  fontWeight: FontWeight.w900,
                  color:      context.colors.text,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Find smarter alternatives instantly',
                style: TextStyle(fontSize: 12.sp, color: context.colors.subText),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () => context.push('/favorites'),
          child: Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(
              gradient: AppColors.favoriteGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              boxShadow: [
                BoxShadow(
                  color:      AppColors.favoriteOrange.withOpacity(0.35),
                  blurRadius: 12,
                  offset:     const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.bookmark_rounded,
              color: AppColors.white,
              size:  AppConstants.iconS,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final ValueChanged<String>  onChanged;
  final VoidCallback          onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
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
              : Colors.black.withOpacity(0.07),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode:  focusNode,
        onChanged:  onChanged,
        style: TextStyle(
          fontSize:   15.sp,
          color:      context.colors.text,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText:  'e.g. White Rice, Chicken...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color:    context.colors.subText.withOpacity(0.45),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.swapGreen,
            size:  22.sp,
          ),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, val, __) => val.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      color: context.colors.subText,
                      size:  18.sp,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          border:         InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXS,
            vertical:   15.h,
          ),
        ),
      ),
    );
  }
}

// ── Search results ────────────────────────────────────────────────────────────
class _SearchResults extends StatelessWidget {
  final List<FoodItem>         results;
  final String                 query;
  final ValueChanged<FoodItem> onSelect;

  const _SearchResults({
    required this.results,
    required this.query,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('😕', style: TextStyle(fontSize: 44.sp)),
          SizedBox(height: AppConstants.spaceM),
          Text(
            query.isEmpty
                ? 'No foods in this category'
                : 'No results for "$query"',
            style: TextStyle(fontSize: 14.sp, color: context.colors.subText),
          ),
        ]),
      );
    }

    return ListView.separated(
      padding:          EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
      itemCount:        results.length,
      separatorBuilder: (_, __) => SizedBox(height: AppConstants.spaceS),
      itemBuilder: (_, i) {
        final f = results[i];
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onSelect(f); },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.paddingL,
              vertical:   AppConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color:        context.colors.card,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(
                color: context.isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(children: [
              Container(
                width:  44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color:        AppColors.swapGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Center(child: Text(f.emoji, style: TextStyle(fontSize: 22.sp))),
              ),
              SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name,
                      style: TextStyle(
                        fontSize:   14.sp,
                        fontWeight: FontWeight.w700,
                        color:      context.colors.text,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(children: [
                      _Chip('${f.calories.round()} kcal', AppColors.protein),
                      SizedBox(width: 5.w),
                      _Chip('P ${f.protein.round()}g',    AppColors.swapBlue),
                      SizedBox(width: 5.w),
                      _Chip('C ${f.carbs.round()}g',      AppColors.swapGreen),
                    ]),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size:  13.sp,
                color: context.colors.subText.withOpacity(0.4),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color  color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppConstants.radiusS - 2.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   9.sp,
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
    );
  }
}

// ── Swap results ──────────────────────────────────────────────────────────────
class _SwapResults extends StatefulWidget {
  final FoodSwapLoaded state;
  final VoidCallback   onReset;
  const _SwapResults({required this.state, required this.onReset});

  @override
  State<_SwapResults> createState() => _SwapResultsState();
}

class _SwapResultsState extends State<_SwapResults>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s    = widget.state;
    final orig = s.result.original;
    final alts = s.result.alternatives;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
      children: [
        _OriginalCard(food: orig, onReset: widget.onReset),
        SizedBox(height: AppConstants.spaceL),
        _PortionSlider(grams: s.portionGrams, food: orig),
        SizedBox(height: AppConstants.spaceL),

        Row(children: [
          Container(
            width:  4.w,
            height: 18.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.swapGreen, AppColors.swapGreenLight],
                begin:  Alignment.topCenter,
                end:    Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: AppConstants.paddingS),
          Text(
            'Better Alternatives',
            style: TextStyle(
              fontSize:   16.sp,
              fontWeight: FontWeight.w800,
              color:      context.colors.text,
            ),
          ),
          const Spacer(),
          Text(
            '${alts.length} results',
            style: TextStyle(fontSize: 11.sp, color: context.colors.subText),
          ),
        ]),
        SizedBox(height: AppConstants.spaceM),

        if (alts.isEmpty)
          _EmptyAlts()
        else
          ...List.generate(alts.length, (i) {
            final delay = i * 0.14;
            final anim  = CurvedAnimation(
              parent: _ctrl,
              curve:  Interval(
                delay,
                (delay + 0.5).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            );
            return AnimatedBuilder(
              animation: anim,
              builder: (_, child) => FadeTransition(
                opacity:  anim,
                child:    SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.4, 0),
                    end:   Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: SwapCard(
                alt:              alts[i],
                original:         orig,
                index:            i,
                isFavorite:       s.favoriteIds.contains(alts[i].food.id),
                onFavoriteToggle: () =>
                    context.read<FoodSwapCubit>().toggleFavorite(alts[i].food.id),
                onAddToLog: () =>
                    _showAddToLogSheet(context, alts[i], s.portionGrams),
              ),
            );
          }),

        SizedBox(height: AppConstants.spaceXL),
      ],
    );
  }

  void _showAddToLogSheet(
    BuildContext context,
    SwapAlternative alt,
    double portionGrams,
  ) {
    String selectedMeal = 'lunch';
    final idx  = widget.state.result.alternatives.indexOf(alt);
    final grad = AppColors.swapGradient(idx);

    showModalBottomSheet(
      context:         context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.all(AppConstants.paddingXL),
          decoration: BoxDecoration(
            color:        context.colors.card,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.paddingXXL),
            ),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width:  40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color:        context.colors.subText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: AppConstants.spaceXL),
            Text(
              'Add to Meal Log',
              style: TextStyle(
                fontSize:   18.sp,
                fontWeight: FontWeight.w800,
                color:      context.colors.text,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '${alt.food.emoji} ${alt.food.name}  •  ${portionGrams.round()}g',
              style: TextStyle(fontSize: 13.sp, color: context.colors.subText),
            ),
            SizedBox(height: AppConstants.spaceXL),

            Row(
              children: ['breakfast', 'lunch', 'dinner', 'snacks'].map((m) {
                final on = selectedMeal == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setS(() => selectedMeal = m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: AppConstants.animationFast),
                      margin:  EdgeInsets.symmetric(horizontal: AppConstants.paddingXS),
                      padding: EdgeInsets.symmetric(vertical: AppConstants.spaceS),
                      decoration: BoxDecoration(
                        gradient:     on ? LinearGradient(colors: grad) : null,
                        color:        on ? null : context.colors.bg,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: on
                              ? Colors.transparent
                              : context.colors.subText.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _mealEmoji(m),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: AppConstants.spaceS),

            Row(
              children: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                  .map((m) => Expanded(
                        child: Text(
                          m,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:   9.sp,
                            color:      context.colors.subText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: AppConstants.spaceXXL),

            GestureDetector(
              onTap: () {
                final scaled = alt.food.scaledTo(portionGrams);
                context.read<CalorieCubit>().addMeal(MealEntry(
                  name:     alt.food.name,
                  calories: scaled.calories.round(),
                  protein:  scaled.protein.round(),
                  carbs:    scaled.carbs.round(),
                  fat:      scaled.fats.round(),
                  mealType: selectedMeal,
                ));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    '${alt.food.emoji} ${alt.food.name} added to $selectedMeal!',
                    style: const TextStyle(color: AppColors.white),
                  ),
                  backgroundColor: AppColors.swapGreen,
                  behavior:        SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  duration: const Duration(seconds: 2),
                ));
              },
              child: Container(
                width:   double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                decoration: BoxDecoration(
                  gradient:     LinearGradient(colors: grad),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color:      grad[0].withOpacity(0.35),
                      blurRadius: 12,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Add to Log',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   15.sp,
                    fontWeight: FontWeight.w800,
                    color:      AppColors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppConstants.spaceS),
          ]),
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

// ── Portion slider ────────────────────────────────────────────────────────────
class _PortionSlider extends StatelessWidget {
  final double   grams;
  final FoodItem food;
  const _PortionSlider({required this.grams, required this.food});

  @override
  Widget build(BuildContext context) {
    final scaled = food.scaledTo(grams);
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color:        context.colors.card,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.scale_rounded, size: AppConstants.iconXS, color: AppColors.swapBlue),
            SizedBox(width: 6.w),
            Text(
              'Portion Size',
              style: TextStyle(
                fontSize:   13.sp,
                fontWeight: FontWeight.w700,
                color:      context.colors.text,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spaceS,
                vertical:   3.h,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.swapBlue, AppColors.swapBlueLight],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusRound),
              ),
              child: Text(
                '${grams.round()}g',
                style: TextStyle(
                  fontSize:   12.sp,
                  fontWeight: FontWeight.w700,
                  color:      AppColors.white,
                ),
              ),
            ),
          ]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:   AppColors.swapBlue,
              inactiveTrackColor: AppColors.swapBlue.withOpacity(0.15),
              thumbColor:         AppColors.swapBlue,
              overlayColor:       AppColors.swapBlue.withOpacity(0.12),
              trackHeight:        3,
            ),
            child: Slider(
              value:     grams,
              min:       AppConstants.portionMin,
              max:       AppConstants.portionMax,
              divisions: AppConstants.portionDivisions,
              onChanged: (v) => context.read<FoodSwapCubit>().updatePortion(v),
            ),
          ),
          Row(children: [
            _MiniMacro('${scaled.calories.round()}', 'kcal', AppColors.protein),
            _MiniMacro('${scaled.protein.round()}g',  'P',   AppColors.swapBlue),
            _MiniMacro('${scaled.carbs.round()}g',    'C',   AppColors.swapGreen),
            _MiniMacro('${scaled.fats.round()}g',     'F',   AppColors.swapPurple),
          ]),
        ],
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;
  const _MiniMacro(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        margin:  EdgeInsets.only(right: 6.w),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Column(children: [
          Text(
            value,
            style: TextStyle(
              fontSize:   11.sp,
              fontWeight: FontWeight.w800,
              color:      color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 9.sp, color: context.colors.subText)),
        ]),
      ),
    );
  }
}

// ── Original card ─────────────────────────────────────────────────────────────
class _OriginalCard extends StatelessWidget {
  final FoodItem     food;
  final VoidCallback onReset;
  const _OriginalCard({required this.food, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.swapGreen.withOpacity(0.12),
          AppColors.swapGreenLight.withOpacity(0.04),
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(color: AppColors.swapGreen.withOpacity(0.25)),
      ),
      child: Row(children: [
        Text(food.emoji, style: TextStyle(fontSize: 36.sp)),
        SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Swapping',
                style: TextStyle(
                  fontSize:   11.sp,
                  color:      AppColors.swapGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                food.name,
                style: TextStyle(
                  fontSize:   18.sp,
                  fontWeight: FontWeight.w900,
                  color:      context.colors.text,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${food.calories.round()} kcal · P${food.protein.round()}g · C${food.carbs.round()}g · F${food.fats.round()}g',
                style: TextStyle(fontSize: 11.sp, color: context.colors.subText),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onReset,
          child: Container(
            padding: EdgeInsets.all(AppConstants.paddingS),
            decoration: BoxDecoration(
              color:        AppColors.swapGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppConstants.radiusS),
            ),
            child: Icon(Icons.refresh_rounded, size: 18.sp, color: AppColors.swapGreen),
          ),
        ),
      ]),
    );
  }
}

// ── Empty alternatives ────────────────────────────────────────────────────────
class _EmptyAlts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppConstants.spaceXXXL),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🔍', style: TextStyle(fontSize: 40.sp)),
          SizedBox(height: AppConstants.spaceM),
          Text(
            'No alternatives found',
            style: TextStyle(fontSize: 14.sp, color: context.colors.subText),
          ),
        ]),
      ),
    );
  }
}