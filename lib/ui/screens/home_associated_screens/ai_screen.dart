// ui/screens/home_associated_screens/ai_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with TickerProviderStateMixin {
  final TextEditingController _minCalController =
      TextEditingController(text: '200');
  final TextEditingController _maxCalController =
      TextEditingController(text: '600');
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _calMin = 200;
  int _calMax = 600;
  String _selectedMealType = 'all';
  String _searchQuery = '';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<MealSuggestion> _mockMeals = const [
    MealSuggestion(
      id: 1,
      name: 'Grilled Chicken Salad',
      calories: 320,
      mealType: 'lunch',
      protein: 38,
      carbs: 12,
      fat: 9,
      emoji: '🥗',
    ),
    MealSuggestion(
      id: 2,
      name: 'Oats with Berries',
      calories: 280,
      mealType: 'breakfast',
      protein: 9,
      carbs: 48,
      fat: 6,
      emoji: '🥣',
    ),
    MealSuggestion(
      id: 3,
      name: 'Chicken Breast with Veggies',
      calories: 410,
      mealType: 'dinner',
      protein: 45,
      carbs: 18,
      fat: 14,
      emoji: '🍗',
    ),
    MealSuggestion(
      id: 4,
      name: 'Beef Shawarma Wrap',
      calories: 580,
      mealType: 'lunch',
      protein: 32,
      carbs: 52,
      fat: 22,
      emoji: '🌯',
    ),
    MealSuggestion(
      id: 5,
      name: 'Greek Yogurt with Honey',
      calories: 190,
      mealType: 'snack',
      protein: 17,
      carbs: 22,
      fat: 4,
      emoji: '🍯',
    ),
    MealSuggestion(
      id: 6,
      name: 'Scrambled Eggs with Cheese',
      calories: 240,
      mealType: 'breakfast',
      protein: 19,
      carbs: 4,
      fat: 17,
      emoji: '🍳',
    ),
    MealSuggestion(
      id: 7,
      name: 'Brown Rice with Lentils',
      calories: 370,
      mealType: 'lunch',
      protein: 14,
      carbs: 62,
      fat: 3,
      emoji: '🍚',
    ),
    MealSuggestion(
      id: 8,
      name: 'Salmon with Sweet Potato',
      calories: 490,
      mealType: 'dinner',
      protein: 40,
      carbs: 38,
      fat: 16,
      emoji: '🐟',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.trim().toLowerCase(),
      );
    });
  }

  @override
  void dispose() {
    _minCalController.dispose();
    _maxCalController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<MealSuggestion> get _filteredMeals {
    return _mockMeals.where((meal) {
      if (meal.calories < _calMin || meal.calories > _calMax) return false;
      if (_selectedMealType != 'all' && meal.mealType != _selectedMealType) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !meal.name.toLowerCase().contains(_searchQuery)) return false;
      return true;
    }).toList();
  }

  void _onCalorieChanged() {
    setState(() {
      _calMin = int.tryParse(_minCalController.text) ?? 0;
      _calMax = int.tryParse(_maxCalController.text) ?? 9999;
    });
  }

  @override
  Widget build(BuildContext context) {
    final meals = _filteredMeals;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: context.colors.bg,
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    _CalorieInputCard(
                      minController: _minCalController,
                      maxController: _maxCalController,
                      calMax: _calMax,
                      searchController: _searchController,
                      onCalorieChanged: _onCalorieChanged,
                      onSliderChanged: (val) {
                        setState(() {
                          _calMax = val.round();
                          _maxCalController.text = _calMax.toString();
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    _MealTypeFilter(
                      selectedMealType: _selectedMealType,
                      onMealTypeChanged: (type) =>
                          setState(() => _selectedMealType = type),
                    ),
                    SizedBox(height: 16.h),
                    _ResultsHeader(count: meals.length),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
            if (meals.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
                  ),
                  child: const _EmptyState(),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _MealResultCard(
                        meal: meals[index],
                        calMax: _calMax,
                      ),
                    ),
                    childCount: meals.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: context.colors.shadow, blurRadius: 8),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF4361EE),
            size: 18.sp,
          ),
        ),
      ),
      title: Text(
        'AI Assistant',
        style: TextStyle(
          color: context.colors.text,
          fontWeight: FontWeight.w800,
          fontSize: 18.sp,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Data Model
// -----------------------------------------------------------------------------

class MealSuggestion {
  final int id;
  final String name;
  final int calories;
  final String mealType;
  final int protein;
  final int carbs;
  final int fat;
  final String emoji;

  const MealSuggestion({
    required this.id,
    required this.name,
    required this.calories,
    required this.mealType,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.emoji,
  });

  // TODO: fromJson when API is ready
  // factory MealSuggestion.fromJson(Map<String, dynamic> json) => MealSuggestion(
  //   id: json['id'],
  //   name: json['name'],
  //   calories: json['calories'],
  //   mealType: json['meal_type'],
  //   protein: json['protein'] ?? 0,
  //   carbs: json['carbs'] ?? 0,
  //   fat: json['fat'] ?? 0,
  //   emoji: json['emoji'] ?? '🍽️',
  // );
}

// -----------------------------------------------------------------------------
// Match Badge Helper
// -----------------------------------------------------------------------------

// Returns the label text based on how close the meal calories are to calMax
String _matchLabel(int calories, int calMax) {
  final ratio = calories / calMax;
  if (ratio <= 0.6) return 'Great Match';
  if (ratio <= 0.85) return 'Good Match';
  return 'Fair Match';
}

// Returns the color for the match badge based on the ratio
Color _matchColor(int calories, int calMax) {
  final ratio = calories / calMax;
  if (ratio <= 0.6) return const Color(0xFF1D9E75);
  if (ratio <= 0.85) return const Color(0xFFF5A623);
  return const Color(0xFFD85A30);
}

// -----------------------------------------------------------------------------
// Calorie Input Card
// -----------------------------------------------------------------------------

class _CalorieInputCard extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final TextEditingController searchController;
  final int calMax;
  final VoidCallback onCalorieChanged;
  final ValueChanged<double> onSliderChanged;

  const _CalorieInputCard({
    required this.minController,
    required this.maxController,
    required this.searchController,
    required this.calMax,
    required this.onCalorieChanged,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _CalorieField(
                  label: 'Min (kcal)',
                  controller: minController,
                  onChanged: (_) => onCalorieChanged(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _CalorieField(
                  label: 'Max (kcal)',
                  controller: maxController,
                  onChanged: (_) => onCalorieChanged(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text(
                '100',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: context.colors.subText,
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF4361EE),
                    inactiveTrackColor:
                        const Color(0xFF4361EE).withOpacity(0.15),
                    thumbColor: const Color(0xFF4361EE),
                    overlayColor: const Color(0xFF4361EE).withOpacity(0.12),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    min: 100,
                    max: 1200,
                    divisions: 22,
                    value: calMax.clamp(100, 1200).toDouble(),
                    onChanged: onSliderChanged,
                  ),
                ),
              ),
              Text(
                '1200',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: context.colors.subText,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              '<= $calMax kcal',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4361EE),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: searchController,
            style: TextStyle(fontSize: 14.sp, color: context.colors.text),
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle:
                  TextStyle(fontSize: 13.sp, color: context.colors.subText),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: context.colors.subText,
                size: 20.sp,
              ),
              filled: true,
              fillColor: context.colors.bg,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: Color(0xFF4361EE),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CalorieField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: context.colors.subText,
            fontWeight: FontWeight.w500,
            letterSpacing: .4,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.text,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.colors.bg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFF4361EE),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Meal Type Filter
// -----------------------------------------------------------------------------

class _MealTypeFilter extends StatelessWidget {
  final String selectedMealType;
  final ValueChanged<String> onMealTypeChanged;

  const _MealTypeFilter({
    required this.selectedMealType,
    required this.onMealTypeChanged,
  });

  static const _mealTypes = [
    ('all', 'All', Icons.apps_rounded),
    ('breakfast', 'Breakfast', Icons.wb_sunny_rounded),
    ('lunch', 'Lunch', Icons.lunch_dining_rounded),
    ('dinner', 'Dinner', Icons.nightlight_round),
    ('snack', 'Snack', Icons.apple_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEAL TYPE',
            style: TextStyle(
              fontSize: 10.sp,
              color: context.colors.subText,
              fontWeight: FontWeight.w600,
              letterSpacing: .6,
            ),
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _mealTypes.map((type) {
                final isActive = selectedMealType == type.$1;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _FilterChip(
                    label: type.$2,
                    icon: type.$3,
                    isActive: isActive,
                    onTap: () => onMealTypeChanged(type.$1),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4361EE).withOpacity(0.12)
              : context.colors.bg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isActive
                ? const Color(0xFF4361EE).withOpacity(0.5)
                : context.colors.subText.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13.sp,
                color: isActive
                    ? const Color(0xFF4361EE)
                    : context.colors.subText,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? const Color(0xFF4361EE)
                    : context.colors.subText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Results Header
// -----------------------------------------------------------------------------

class _ResultsHeader extends StatelessWidget {
  final int count;

  const _ResultsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count meal${count == 1 ? '' : 's'} found',
          style: TextStyle(
            fontSize: 13.sp,
            color: context.colors.subText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFAEEDA),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 11.sp,
                color: const Color(0xFF854F0B),
              ),
              SizedBox(width: 4.w),
              Text(
                'mock data',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF854F0B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Meal Result Card
// -----------------------------------------------------------------------------

class _MealResultCard extends StatelessWidget {
  final MealSuggestion meal;
  final int calMax;

  const _MealResultCard({
    required this.meal,
    required this.calMax,
  });

  @override
  Widget build(BuildContext context) {
    final barWidth = (meal.calories / 1200).clamp(0.0, 1.0);
    final barColor = meal.calories <= calMax
        ? const Color(0xFF1D9E75)
        : const Color(0xFFD85A30);

    final badgeColor = _matchColor(meal.calories, calMax);
    final badgeLabel = _matchLabel(meal.calories, calMax);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji box
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: context.colors.bg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                meal.emoji,
                style: TextStyle(fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Card content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal name and calorie count
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        meal.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: context.colors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${meal.calories}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: context.colors.text,
                          ),
                        ),
                        Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: context.colors.subText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // Match badge + macros on the same row
                Row(
                  children: [
                    // Match badge with dot indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: badgeColor.withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            badgeLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // Macros
                    Expanded(
                      child: Text(
                        'P:${meal.protein}g  C:${meal.carbs}g  F:${meal.fat}g',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: context.colors.subText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Calorie progress bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          width: constraints.maxWidth,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: context.colors.bg,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        Container(
                          width: constraints.maxWidth * barWidth,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty State
// -----------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFF4361EE).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: const Color(0xFF4361EE).withOpacity(0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No meals found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.text,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting the calorie range\nor changing your filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: context.colors.subText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}