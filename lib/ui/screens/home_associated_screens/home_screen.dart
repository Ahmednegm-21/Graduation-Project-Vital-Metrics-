import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/core/imports.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/sleep_cubit.dart';
import 'package:vital_metrics/logic/fitness/fitness_snapshot_cubit.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/water_details_sheet.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/water_tracker_card.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/meal_section.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  late final AnimationController _particleCtrl;

  static const _meals = [
    {'type': 'breakfast', 'label': 'Breakfast', 'emoji': '☀️'},
    {'type': 'lunch', 'label': 'Lunch', 'emoji': '🌤️'},
    {'type': 'dinner', 'label': 'Dinner', 'emoji': '🌙'},
    {'type': 'snacks', 'label': 'Snacks', 'emoji': '🍎'},
  ];

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnim = Tween(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _floatAnim = Tween(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF050816)
          : const Color(0xFFF3F7FF),
      body: Stack(
        children: [
          // Background top-right glow
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4FC3FF).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Background bottom-left glow
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF4361EE).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Grid background painter
          Positioned.fill(
            child: CustomPaint(painter: _HomeGridPainter()),
          ),

          // Main scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  _buildHeader(context, isDark),
                  const SizedBox(height: 8),
                  _buildCalorieCard(context, isDark),
                  const SizedBox(height: 20),
                  _buildMealRow(context, isDark),
                  const SizedBox(height: 24),

                  // Health badge above Water card
                  _buildHealthBadge(context),
                  const SizedBox(height: 8),
                  const WaterTrackerCard(),

                  const SizedBox(height: 24),
                  _buildSleepCard(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Health Connect badge shown above the water card
  // Green when Health Connect is connected, orange otherwise
  Widget _buildHealthBadge(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: BlocBuilder<FitnessSnapshotCubit, FitnessSnapshotState>(
          builder: (context, fitnessState) {
            final connected = fitnessState is FitnessSnapshotLoaded;

            final color = connected
                ? const Color(0xFF63E6BE)
                : const Color(0xFFFFA94D);

            final label = connected ? 'Health Connected' : 'Local Tracking';

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Top header row with date picker, notifications, and settings
  Widget _buildHeader(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(0.07);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          FadeInDown(
            child: GestureDetector(
              onTap: () async {
                await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF4361EE),
                      ),
                    ),
                    child: child!,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: shadow, blurRadius: 12)],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF4361EE),
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _todayLabel(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          FadeInDown(
            delay: const Duration(milliseconds: 80),
            child: GestureDetector(
              onTap: () => context.push('/notifications'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: shadow, blurRadius: 12)],
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
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1A2340)
                              : Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          FadeInDown(
            delay: const Duration(milliseconds: 140),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: shadow, blurRadius: 12)],
                ),
                child: const Icon(
                  Icons.settings,
                  color: Color(0xFF4361EE),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Calorie ring card with food image, macro bars, and floating particles
  Widget _buildCalorieCard(BuildContext context, bool isDark) {
    return BlocBuilder<CalorieCubit, CalorieState>(
      builder: (context, state) {
        final remaining = state.caloriesRemaining.clamp(0, state.caloriesBudget);
        final progress = (state.totalCaloriesConsumed / state.caloriesBudget)
            .clamp(0.0, 1.0);

        final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
        final cardShadow = isDark
            ? Colors.black54
            : Colors.black.withOpacity(0.10);
        final numColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final subColor = isDark
            ? const Color(0xFFB0B8D0)
            : const Color(0xFF7B8299);

        return FadeInDown(
          delay: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _floatAnim.value),
                    child: child,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(28),
                      border: isDark
                          ? Border.all(
                              color: const Color(0xFF4361EE).withOpacity(0.20),
                              width: 1,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: cardShadow,
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                        if (isDark)
                          BoxShadow(
                            color: const Color(0xFF4361EE).withOpacity(0.07),
                            blurRadius: 40,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Food image on the left side of the card
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: FadeInLeft(
                            duration: const Duration(milliseconds: 600),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(28),
                              ),
                              child: Image.asset(
                                'assets/images/home_food.png',
                                width: 148,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                        // Right side content: calorie ring and macro bars
                        Padding(
                          padding: const EdgeInsets.fromLTRB(156, 16, 14, 16),
                          child: Column(
                            children: [
                              // Pulsing circular calorie progress ring
                              AnimatedBuilder(
                                animation: _pulseAnim,
                                builder: (_, child) => Transform.scale(
                                  scale: _pulseAnim.value,
                                  child: child,
                                ),
                                child: SizedBox(
                                  width: 108,
                                  height: 108,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 108,
                                        height: 108,
                                        child: CircularProgressIndicator(
                                          value: 1,
                                          strokeWidth: 10,
                                          color: isDark
                                              ? const Color(0xFF4361EE).withOpacity(0.30)
                                              : const Color(0xFF4361EE).withOpacity(0.12),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 108,
                                        height: 108,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 10,
                                          backgroundColor: Colors.transparent,
                                          valueColor: const AlwaysStoppedAnimation(
                                            Color(0xFF4361EE),
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            color: isDark
                                                ? const Color(0xFFFFB347)
                                                : Colors.orange,
                                            size: 16,
                                          ),
                                          Text(
                                            '$remaining',
                                            style: TextStyle(
                                              color: numColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            'kcal left',
                                            style: TextStyle(
                                              color: subColor,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              _MacroBar(
                                label: 'Protein',
                                consumed: state.totalProtein,
                                goal: state.proteinGoal,
                                color: const Color(0xFFFF9A3C),
                                isDark: isDark,
                                delay: 200,
                              ),
                              _MacroBar(
                                label: 'Carbs',
                                consumed: state.totalCarbs,
                                goal: state.carbsGoal,
                                color: const Color(0xFF2ECC9A),
                                isDark: isDark,
                                delay: 320,
                              ),
                              _MacroBar(
                                label: 'Fat',
                                consumed: state.totalFat,
                                goal: state.fatGoal,
                                color: const Color(0xFFFF6B6B),
                                isDark: isDark,
                                delay: 440,
                              ),
                            ],
                          ),
                        ),

                        // Budget label badge at the bottom-left over the food image
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            width: 148,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xDD4361EE),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(28),
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              '${state.caloriesBudget} kcal budget',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ..._buildParticles(isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  // Floating animated particles around the calorie card
  List<Widget> _buildParticles(bool isDark) {
    final particles = [
      _Particle(top: -10, right: 28, size: 6.0, speed: 1.00, color: 0xFF4361EE),
      _Particle(top: 18, right: -7, size: 4.5, speed: 0.70, color: 0xFF4CC9F0),
      _Particle(top: -7, left: 55, size: 5.0, speed: 1.20, color: 0xFF7B5EA7),
      _Particle(top: 8, right: -5, size: 5.5, speed: 0.85, color: 0xFF4361EE),
      _Particle(top: -5, left: 72, size: 4.0, speed: 1.05, color: 0xFF4CC9F0),
    ];

    return particles.map<Widget>((p) {
      return AnimatedBuilder(
        animation: _particleCtrl,
        builder: (_, __) {
          final t = _particleCtrl.value;
          final dx = math.sin(t * 2 * math.pi * p.speed) * 4.0;
          final dy = math.cos(t * 2 * math.pi * p.speed) * 4.0;
          final op = (0.25 + math.sin(t * 2 * math.pi * p.speed) * 0.25)
              .clamp(0.0, 1.0);

          return Positioned(
            top: p.top + dy,
            left: p.left != null ? p.left! + dx : null,
            right: p.right != null ? p.right! - dx : null,
            child: Opacity(
              opacity: isDark ? op : op * 0.6,
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(p.color).withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Color(p.color).withOpacity(0.5),
                      blurRadius: p.size * 1.5,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  // 2x2 grid of meal cards (breakfast, lunch, dinner, snacks)
  Widget _buildMealRow(BuildContext context, bool isDark) {
    return BlocBuilder<CalorieCubit, CalorieState>(
      builder: (context, state) {
        return FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 12.w) / 2;
                return Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: itemWidth,
                      child: _buildMealCard(context, state, index),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Single meal card with emoji, calorie badge, macros, and action buttons
  Widget _buildMealCard(BuildContext context, CalorieState state, int index) {
    final isDark = context.isDark;
    final item = _meals[index];
    final type = item['type']!;
    final meals = state.mealsFor(type);

    final totalCalories = meals.fold(0, (s, m) => s + m.calories);
    final protein = meals.fold(0, (s, m) => s + m.protein);
    final carbs = meals.fold(0, (s, m) => s + m.carbs);
    final fat = meals.fold(0, (s, m) => s + m.fat);

    return IntrinsicHeight(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A2340), const Color(0xFF11182D)]
                : [Colors.white, const Color(0xFFF5F7FF)],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item['emoji']!, style: TextStyle(fontSize: 34.sp)),
              SizedBox(height: 4.h),

              Text(
                item['label']!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 8.h),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB84D).withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$totalCalories kcal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFFFFB84D),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              _compactMacro('Protein', protein, const Color(0xFFFF9A3C), isDark),
              SizedBox(height: 4.h),
              _compactMacro('Carbs', carbs, const Color(0xFF2ECC9A), isDark),
              SizedBox(height: 4.h),
              _compactMacro('Fat', fat, const Color(0xFFFF6B6B), isDark),

              SizedBox(height: 10.h),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => MealSection(
                            mealType: type,
                            label: item['label']!,
                            emoji: item['emoji']!,
                            index: index,
                            calories: totalCalories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat,
                          ),
                        );
                      },
                      child: Container(
                        height: 34.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4361EE), Color(0xFF5B7FFF)],
                          ),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Center(
                          child: Text(
                            '+ Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 6.w),

                  GestureDetector(
                    onTap: () => context.read<CalorieCubit>().resetMeal(type),
                    child: Container(
                      width: 36.w,
                      height: 34.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        color: const Color(0xFFFF6B6B),
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact single-line macro row used inside meal cards
  Widget _compactMacro(String label, int value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF4A4A6A),
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            '${value}g',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Sleep insights card with weekly bar chart, slider, and tip section
  Widget _buildSleepCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(0.07);

    return BlocBuilder<SleepCubit, SleepState>(
      builder: (context, sleepState) {
        final hours = sleepState.sleepHours;

        // Week days starting from Saturday to match the app locale
        final days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
        final now = DateTime.now();

        int currentDayIndex;
        switch (now.weekday) {
          case DateTime.saturday:
            currentDayIndex = 0;
            break;
          case DateTime.sunday:
            currentDayIndex = 1;
            break;
          case DateTime.monday:
            currentDayIndex = 2;
            break;
          case DateTime.tuesday:
            currentDayIndex = 3;
            break;
          case DateTime.wednesday:
            currentDayIndex = 4;
            break;
          case DateTime.thursday:
            currentDayIndex = 5;
            break;
          default:
            currentDayIndex = 6;
        }

        final weekData = List.generate(
          7,
          (index) => {'day': days[index], 'hours': 0.0},
        );
        weekData[currentDayIndex]['hours'] = hours;

        // Sleep quality color, emoji, insight text, and tip based on hours slept
        Color mainColor;
        String insight;
        String sleepEmoji;
        String sleepTip;

        if (hours < 6) {
          mainColor = const Color(0xFFFF6B6B);
          insight = '😴 Not enough sleep';
          sleepEmoji = '😴';
          sleepTip = 'Try sleeping earlier tonight for better recovery.';
        } else if (hours < 7) {
          mainColor = const Color(0xFFFFB84D);
          insight = '🌙 Almost there';
          sleepEmoji = '🌙';
          sleepTip = 'You are close to the recommended sleep range.';
        } else if (hours <= 9) {
          mainColor = const Color(0xFF63E6BE);
          insight = '✨ Optimal sleep';
          sleepEmoji = '✨';
          sleepTip = 'Your sleep today looks healthy and balanced.';
        } else {
          mainColor = const Color(0xFF4CC9F0);
          insight = '💤 Too much sleep';
          sleepEmoji = '💤';
          sleepTip = 'You slept longer than usual. Try balancing your sleep schedule.';
        }

        return FadeInUp(
          delay: const Duration(milliseconds: 340),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Connect badge shown above the sleep card
                BlocBuilder<FitnessSnapshotCubit, FitnessSnapshotState>(
                  builder: (context, fitnessState) {
                    final connected = fitnessState is FitnessSnapshotLoaded;
                    final color = connected
                        ? const Color(0xFF63E6BE)
                        : const Color(0xFFFFA94D);
                    final label = connected ? 'Health Connected' : 'Local Tracking';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.w,
                              height: 7.w,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              label,
                              style: TextStyle(
                                color: color,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Sleep card main container
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: isDark
                        ? Border.all(
                            color: mainColor.withOpacity(0.20),
                            width: 1,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: shadow,
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row with emoji icon, title, insight, and hours badge
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: mainColor.withOpacity(0.12),
                            ),
                            child: Center(
                              child: Text(
                                sleepEmoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sleep Insights',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  insight,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: mainColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Hours badge on the right
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: mainColor.withOpacity(0.12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  sleepEmoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${hours.toStringAsFixed(1)}h',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Weekly bar chart showing sleep per day
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: weekData.map((item) {
                          final day = item['day'] as String;
                          final value = item['hours'] as double;
                          final active = value > 0;
                          final height = (value / 10) * 90;

                          return Column(
                            children: [
                              Text(
                                active ? '${value.toStringAsFixed(1)}h' : '--',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: active
                                      ? mainColor
                                      : isDark
                                          ? Colors.white24
                                          : Colors.black26,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 28,
                                height: active ? height.clamp(18, 90) : 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: active
                                      ? LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            mainColor,
                                            mainColor.withOpacity(0.65),
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: isDark
                                              ? [
                                                  Colors.white10,
                                                  Colors.white.withOpacity(0.03),
                                                ]
                                              : [
                                                  Colors.black12,
                                                  Colors.black.withOpacity(0.03),
                                                ],
                                        ),
                                  boxShadow: active
                                      ? [
                                          BoxShadow(
                                            color: mainColor.withOpacity(0.35),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: active
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: active
                                      ? mainColor
                                      : isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 26),

                      Text(
                        'Adjust your sleep',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF4A4A6A),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sleep hours slider from 0 to 12
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 18,
                          ),
                          activeTrackColor: mainColor,
                          inactiveTrackColor: mainColor.withOpacity(0.15),
                          thumbColor: mainColor,
                          overlayColor: mainColor.withOpacity(0.20),
                        ),
                        child: Slider(
                          value: hours,
                          min: 0,
                          max: 12,
                          divisions: 24,
                          label: '${hours.toStringAsFixed(1)}h',
                          onChanged: (v) =>
                              context.read<SleepCubit>().updateHours(v),
                          onChangeEnd: (_) =>
                              context.read<SleepCubit>().saveSleep(),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0h',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white30 : Colors.black38,
                            ),
                          ),
                          Text(
                            '12h',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white30 : Colors.black38,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Bottom tip card with lightbulb emoji and advice text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: mainColor.withOpacity(0.08),
                          border: Border.all(
                            color: mainColor.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              '💡',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                sleepTip,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.5,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF4A4A6A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Returns formatted date label like "Jan 5"
  String _todayLabel() {
    final now = DateTime.now();
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${m[now.month - 1]} ${now.day}';
  }
}

// Particle data model used for the floating dots animation
class _Particle {
  final double top;
  final double? left;
  final double? right;
  final double size;
  final double speed;
  final int color;

  const _Particle({
    required this.top,
    this.left,
    this.right,
    required this.size,
    required this.speed,
    required this.color,
  });
}

// Animated macro progress bar with fill animation and slide-in effect
class _MacroBar extends StatefulWidget {
  final String label;
  final int consumed;
  final int goal;
  final Color color;
  final bool isDark;
  final int delay;

  const _MacroBar({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
    required this.isDark,
    this.delay = 0,
  });

  @override
  State<_MacroBar> createState() => _MacroBarState();
}

class _MacroBarState extends State<_MacroBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fillAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fillAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _slideAnim = Tween(begin: 16.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final color = widget.color;
    final pct = widget.goal > 0
        ? (widget.consumed / widget.goal).clamp(0.0, 1.0)
        : 0.0;

    final labelCol = isDark ? Colors.white : const Color(0xFF2D3142);
    final badgeBg = isDark ? color.withOpacity(0.18) : color;
    final badgeTxt = isDark ? color : Colors.white;
    final trackCol = color.withOpacity(isDark ? 0.22 : 0.18);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fadeAnim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(_slideAnim.value, 0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(isDark ? 0.9 : 0.5),
                                blurRadius: isDark ? 8 : 4,
                                spreadRadius: isDark ? 1 : 0,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: labelCol,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(6),
                        border: isDark
                            ? Border.all(
                                color: color.withOpacity(0.55),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        '${widget.consumed} / ${widget.goal}g',
                        style: TextStyle(
                          color: badgeTxt,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                LayoutBuilder(
                  builder: (_, c) {
                    final fillW = c.maxWidth * pct * _fillAnim.value;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background track
                        Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: trackCol,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // Filled progress bar
                        if (fillW > 2)
                          Container(
                            height: 7,
                            width: fillW,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withOpacity(isDark ? 0.7 : 0.85),
                                  color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(isDark ? 0.6 : 0.35),
                                  blurRadius: isDark ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        // Glowing dot at the end of the filled bar
                        if (fillW > 8)
                          Positioned(
                            left: fillW - 5,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                    isDark ? 0.95 : 0.80,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withOpacity(0.9),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Subtle dot grid painter for the screen background
class _HomeGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    const gap = 32.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}