import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/water_tracker_card.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/meal_section.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen
// ─────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── sleep hours ──
  double _sleepHours = 7.0;

  // ── ring pulse ──
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // ── card float ──
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // ── particles ──
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
    _pulseAnim = Tween(
      begin: 0.96,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
    _floatAnim = Tween(
      begin: -5.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

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
          ? const Color(0xFF0F1221)
          : const Color(0xFFF0F3FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context, isDark),
              _buildCalorieCard(context, isDark),
              const SizedBox(height: 16),
              _buildMealRow(context, isDark),
              const SizedBox(height: 20),
              _buildWaterSection(context),
              const SizedBox(height: 16),
              _buildSleepCard(context, isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(0.07);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          // Date pill
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
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // Bell button
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
                  // notification dot
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

          // Settings button
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

  // ── Calorie card ─────────────────────────────────────────────────────────────
  Widget _buildCalorieCard(BuildContext context, bool isDark) {
    return BlocBuilder<CalorieCubit, CalorieState>(
      builder: (context, state) {
        final remaining = state.caloriesRemaining.clamp(
          0,
          state.caloriesBudget,
        );
        final progress = (state.totalCaloriesConsumed / state.caloriesBudget)
            .clamp(0.0, 1.0);

        // card colors — واضحة في الوضعين
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
                // ── floating card ──
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
                        // food image
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

                        // right side: ring + macros
                        Padding(
                          padding: const EdgeInsets.fromLTRB(156, 16, 14, 16),
                          child: Column(
                            children: [
                              // ── pulsing ring ──
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
                                      // track
                                      SizedBox(
                                        width: 108,
                                        height: 108,
                                        child: CircularProgressIndicator(
                                          value: 1,
                                          strokeWidth: 10,
                                          color: isDark
                                              ? const Color(
                                                  0xFF4361EE,
                                                ).withOpacity(0.30)
                                              : const Color(
                                                  0xFF4361EE,
                                                ).withOpacity(0.12),
                                        ),
                                      ),
                                      // fill
                                      SizedBox(
                                        width: 108,
                                        height: 108,
                                        child: CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 10,
                                          backgroundColor: Colors.transparent,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                Color(0xFF4361EE),
                                              ),
                                        ),
                                      ),
                                      // center text
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

                              // ── macros ──
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

                        // budget badge
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

                // ── particles حوالين الكارد ──
                ..._buildParticles(isDark),
              ],
            ),
          ),
        );
      },
    );
  }

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
          final op = (0.25 + math.sin(t * 2 * math.pi * p.speed) * 0.25).clamp(
            0.0,
            1.0,
          );
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

  // ── Meal row ──────────────────────────────────────────────────────────────
  Widget _buildMealRow(BuildContext context, bool isDark) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _meals
              .asMap()
              .entries
              .map(
                (e) => MealSection(
                  mealType: e.value['type']!,
                  label: e.value['label']!,
                  emoji: e.value['emoji']!,
                  index: e.key,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildWaterSection(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 280),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: WaterTrackerCard(),
      ),
    );
  }

  // ── Sleep Card ─────────────────────────────────────────────────────────────
  Widget _buildSleepCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1A2340) : Colors.white;
    final shadow = isDark ? Colors.black38 : Colors.black.withOpacity(0.07);
    final pct = (_sleepHours / 10.0).clamp(0.0, 1.0);

    // لون الشريط حسب ساعات النوم
    Color barColor;
    String statusText;
    String statusEmoji;
    if (_sleepHours < 6) {
      barColor = const Color(0xFFFF6B6B);
      statusText = 'Not enough sleep';
      statusEmoji = '😴';
    } else if (_sleepHours < 7) {
      barColor = const Color(0xFFFFA94D);
      statusText = 'Almost there';
      statusEmoji = '😐';
    } else if (_sleepHours <= 9) {
      barColor = const Color(0xFF63E6BE);
      statusText = 'Optimal sleep';
      statusEmoji = '😊';
    } else {
      barColor = const Color(0xFF4CC9F0);
      statusText = 'Too much sleep';
      statusEmoji = '😮';
    }

    return FadeInUp(
      delay: const Duration(milliseconds: 340),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: isDark
                ? Border.all(
                    color: const Color(0xFF7B5EA7).withOpacity(0.25),
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
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF7B5EA7,
                          ).withOpacity(isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF7B5EA7).withOpacity(0.30),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text('🌙', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sleep Tracker',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Recommended: 7–9 hrs',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white38
                                  : const Color(0xFF9B9B9B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Hours badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(isDark ? 0.20 : 0.13),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: barColor.withOpacity(0.40),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(statusEmoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          '${_sleepHours.toStringAsFixed(1)}h',
                          style: TextStyle(
                            color: barColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status text
              Text(
                statusText,
                style: TextStyle(
                  color: barColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // Progress bar (readonly visual)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 10,
                  color: isDark
                      ? barColor.withOpacity(0.15)
                      : barColor.withOpacity(0.12),
                  child: FractionallySizedBox(
                    widthFactor: pct,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [barColor.withOpacity(0.7), barColor],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 18,
                  ),
                  activeTrackColor: barColor,
                  inactiveTrackColor: isDark
                      ? Colors.white12
                      : barColor.withOpacity(0.15),
                  thumbColor: barColor,
                  overlayColor: barColor.withOpacity(0.20),
                  valueIndicatorColor: barColor,
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: _sleepHours,
                  min: 0,
                  max: 12,
                  divisions: 24, // steps of 0.5
                  label: '${_sleepHours.toStringAsFixed(1)}h',
                  onChanged: (v) => setState(() => _sleepHours = v),
                ),
              ),

              // Min / Max labels
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0h',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white30
                            : const Color(0xFFB0B8CC),
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '12h',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white30
                            : const Color(0xFFB0B8CC),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[now.month - 1]} ${now.day}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Particle data class
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// _MacroBar  — StatefulWidget مع stagger entrance + dark mode واضح
// ─────────────────────────────────────────────────────────────────────────────
class _MacroBar extends StatefulWidget {
  final String label;
  final int consumed, goal;
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
  late final Animation<double> _fillAnim, _fadeAnim, _slideAnim;

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

    // ── ألوان واضحة في الوضعين ──────────────────────────────────────────────
    //  label: أبيض في dark، داكن في light
    final labelCol = isDark ? Colors.white : const Color(0xFF2D3142);

    //  badge bg: في dark — شبه شفاف + border ملوّن
    //            في light — solid بلون الـ macro
    final badgeBg = isDark ? color.withOpacity(0.18) : color;

    //  badge text: في dark — لون الـ macro (يبان على الشفاف)
    //              في light — أبيض على الـ solid
    final badgeTxt = isDark ? color : Colors.white;

    //  track: ملوّن خفيف في الاتنين
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
                // label + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // dot with glow
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

                    // badge
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

                // bar
                LayoutBuilder(
                  builder: (_, c) {
                    final fillW = c.maxWidth * pct * _fillAnim.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // track
                        Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: trackCol,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        // fill
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
                        // spark at end
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
