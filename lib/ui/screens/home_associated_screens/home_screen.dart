import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/water_tracker_card.dart';
import 'package:vital_metrics/ui/widgets/home_widgets/meal_section.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _meals = [
    {'type': 'breakfast', 'label': 'Breakfast', 'emoji': '☀️'},
    {'type': 'lunch',     'label': 'Lunch',     'emoji': '🌤️'},
    {'type': 'dinner',    'label': 'Dinner',     'emoji': '🌙'},
    {'type': 'snacks',    'label': 'Snacks',     'emoji': '🍎'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              _buildCalorieCard(context),
              const SizedBox(height: 14),
              _buildMealRow(),
              const SizedBox(height: 20),
              const WaterTrackerCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeInDown(
            child: GestureDetector(
              onTap: () => _showDatePicker(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 12)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Color(0xFF4361EE), size: 18),
                    const SizedBox(width: 7),
                    Text(
                      _todayLabel(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: context.colors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 12)],
                ),
                child: const Icon(Icons.settings, color: Color(0xFF4361EE), size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Calorie card ──────────────────────────────────────────────────────────
  Widget _buildCalorieCard(BuildContext context) {
    return BlocBuilder<CalorieCubit, CalorieState>(
      builder: (context, state) {
        final remaining = state.caloriesRemaining.clamp(0, state.caloriesBudget);
        final progress  = (state.totalCaloriesConsumed / state.caloriesBudget).clamp(0.0, 1.0);

        return FadeInDown(
          delay: const Duration(milliseconds: 150),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // صورة الأكل على اليسار
                Positioned(
                  left: 0, bottom: 0, top: 0,
                  child: FadeInLeft(
                    duration: const Duration(milliseconds: 700),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)),
                      child: Image.asset(
                        'assets/images/home_food.png',
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Ring + Macros على اليمين
                Padding(
                  padding: const EdgeInsets.fromLTRB(158, 18, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Ring
                      SizedBox(
                        width: 110, height: 110,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 110, height: 110,
                              child: CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 10,
                                color: const Color(0xFF4361EE).withOpacity(0.12),
                              ),
                            ),
                            SizedBox(
                              width: 110, height: 110,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 10,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF4361EE)),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_fire_department,
                                    color: Colors.orange, size: 16),
                                Text(
                                  '$remaining',
                                  style: TextStyle(
                                    color: context.colors.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text('kcal left',
                                    style: TextStyle(
                                        color: context.colors.subText, fontSize: 9)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Macros
                      _MacroRow(label: 'Protein', consumed: state.totalProtein, goal: state.proteinGoal, color: const Color(0xFFFFA94D), context: context),
                      _MacroRow(label: 'Carbs',   consumed: state.totalCarbs,   goal: state.carbsGoal,   color: const Color(0xFF63E6BE), context: context),
                      _MacroRow(label: 'Fat',     consumed: state.totalFat,     goal: state.fatGoal,     color: const Color(0xFFFF8787), context: context),
                    ],
                  ),
                ),

                // Budget label أسفل الصورة
                Positioned(
                  left: 0, bottom: 0,
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xD94361EE),
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
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Meal row ──────────────────────────────────────────────────────────────
  Widget _buildMealRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _meals.asMap().entries.map((e) => MealSection(
          mealType: e.value['type']!,
          label:    e.value['label']!,
          emoji:    e.value['emoji']!,
          index:    e.key,
        )).toList(),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[now.month - 1]} ${now.day}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF4361EE)),
        ),
        child: child!,
      ),
    );
  }
}

// ── Macro row ─────────────────────────────────────────────────────────────────
class _MacroRow extends StatelessWidget {
  final String label;
  final int consumed;
  final int goal;
  final Color color;
  final BuildContext context;

  const _MacroRow({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final pct        = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final labelColor = context.isDark ? Colors.white : Colors.black;
    final badgeBg    = context.isDark ? color.withOpacity(0.35) : color;

    return Padding(
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
                    width: 9, height: 9,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(label,
                      style: TextStyle(
                          color: labelColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$consumed / ${goal}g',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LayoutBuilder(
            builder: (_, constraints) {
              final barWidth = constraints.maxWidth * pct;
              return Stack(
                children: [
                  Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? Colors.white12
                          : color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: 7,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: color.withOpacity(0.4), blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}