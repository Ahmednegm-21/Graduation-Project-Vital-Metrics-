import 'package:flutter/material.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/logic/home/settings/personal_info_cubit.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Progress',
            style: TextStyle(
                color: context.colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 8)],
                ),
                child: const Icon(Icons.settings, color: Color(0xFF4361EE), size: 20),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PersonalInfoCubit, PersonalInfoState>(
        builder: (context, info) =>
            BlocBuilder<CalorieCubit, CalorieState>(
          builder: (context, cal) =>
              BlocBuilder<WaterCubit, WaterState>(
            builder: (context, water) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 4),

                  // ── BMI Card ────────────────────────────────────────────
                  FadeInDown(child: _BmiCard(info: info)),
                  const SizedBox(height: 16),

                  // ── Weekly Goal Graph ───────────────────────────────────
                  FadeInDown(
                    delay: const Duration(milliseconds: 80),
                    child: _WeeklyGoalGraph(cal: cal),
                  ),
                  const SizedBox(height: 16),

                  // ── Body Stats ──────────────────────────────────────────
                  FadeInDown(
                    delay: const Duration(milliseconds: 130),
                    child: _SectionTitle(title: 'Body Stats'),
                  ),
                  FadeInDown(
                    delay: const Duration(milliseconds: 160),
                    child: Row(children: [
                      Expanded(child: _StatCard(label: 'Weight', value: '${info.weight.toStringAsFixed(1)} kg', icon: Icons.monitor_weight_outlined, color: const Color(0xFF4361EE))),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Height', value: '${info.height.toStringAsFixed(0)} cm', icon: Icons.height, color: const Color(0xFF7B5EA7))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Row(children: [
                      Expanded(child: _StatCard(label: 'Age',    value: '${info.age} yrs', icon: Icons.cake_outlined,   color: const Color(0xFFFFA94D))),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Gender', value: info.gender == 'male' ? '♂ Male' : '♀ Female', icon: Icons.person_outline, color: const Color(0xFF4CC9F0))),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // ── Nutrition ───────────────────────────────────────────
                  FadeInDown(delay: const Duration(milliseconds: 250), child: _SectionTitle(title: "Today's Nutrition")),
                  FadeInDown(delay: const Duration(milliseconds: 280), child: _NutritionCard(cal: cal)),

                  const SizedBox(height: 20),

                  // ── Water ───────────────────────────────────────────────
                  FadeInDown(delay: const Duration(milliseconds: 320), child: _SectionTitle(title: 'Water Progress')),
                  FadeInDown(delay: const Duration(milliseconds: 350), child: _WaterProgressCard(water: water)),

                  const SizedBox(height: 20),

                  // ── Macros ──────────────────────────────────────────────
                  FadeInDown(delay: const Duration(milliseconds: 380), child: _SectionTitle(title: 'Macros Breakdown')),
                  FadeInDown(delay: const Duration(milliseconds: 400), child: _MacrosCard(cal: cal)),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Weekly Goal Graph
// ═══════════════════════════════════════════════════════════════════════════════
class _WeeklyGoalGraph extends StatelessWidget {
  final CalorieState cal;
  const _WeeklyGoalGraph({required this.cal});

  // بيانات وهمية للأسبوع — في التطبيق الحقيقي تيجي من الـ DB
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _consumed = [2100, 2800, 1950, 3100, 2600, 2200, 0]; // 0 = today (live)
  static const _goal = 3245;

  @override
  Widget build(BuildContext context) {
    // اليوم الأخير يكون الـ live data
    final todayConsumed = cal.totalCaloriesConsumed;
    final data = [..._consumed.sublist(0, 6), todayConsumed];
    final todayIndex = 6;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: context.colors.shadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Goal',
                  style: TextStyle(
                      color: context.colors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4361EE).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Goal: $_goal kcal',
                    style: const TextStyle(
                        color: Color(0xFF4361EE),
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Graph
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final v       = data[i];
                final pct     = (v / _goal).clamp(0.0, 1.0);
                final isToday = i == todayIndex;
                final overGoal = v > _goal;
                final barColor = overGoal
                    ? const Color(0xFFFF8787)
                    : isToday
                        ? const Color(0xFF4361EE)
                        : const Color(0xFF4361EE).withOpacity(0.4);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // value label
                        if (v > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : '$v',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isToday
                                    ? const Color(0xFF4361EE)
                                    : context.colors.subText,
                              ),
                            ),
                          ),
                        // bar
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // track
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? Colors.white10
                                    : const Color(0xFFF0F0F8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            // goal line marker
                            Positioned(
                              bottom: 100 * 1.0, // top of track = goal
                              left: 0, right: 0,
                              child: Container(
                                height: 1.5,
                                color: const Color(0xFFFF8787).withOpacity(0.5),
                              ),
                            ),
                            // filled
                            AnimatedContainer(
                              duration: Duration(milliseconds: 500 + i * 80),
                              curve: Curves.easeOut,
                              height: 100 * pct,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isToday
                                    ? [BoxShadow(
                                        color: const Color(0xFF4361EE).withOpacity(0.4),
                                        blurRadius: 8, offset: const Offset(0, 3))]
                                    : [],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // day label
                        Text(_days[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: isToday
                                  ? const Color(0xFF4361EE)
                                  : context.colors.subText,
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 14),

          // Legend
          Row(
            children: [
              _LegendDot(color: const Color(0xFF4361EE), label: 'Consumed'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFFFF8787), label: 'Over goal'),
              const SizedBox(width: 16),
              _LegendDot(color: const Color(0xFF4361EE).withOpacity(0.3), label: 'Past days'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(color: context.colors.subText, fontSize: 10)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BMI Card
// ═══════════════════════════════════════════════════════════════════════════════
class _BmiCard extends StatelessWidget {
  final PersonalInfoState info;
  const _BmiCard({required this.info});

  Color get _bmiColor {
    final b = info.bmi;
    if (b < 18.5) return const Color(0xFF4CC9F0);
    if (b < 25)   return const Color(0xFF63E6BE);
    if (b < 30)   return const Color(0xFFFFA94D);
    return const Color(0xFFFF8787);
  }

  @override
  Widget build(BuildContext context) {
    final bmi      = info.bmi;
    final progress = ((bmi - 10) / 30).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4361EE), Color(0xFF7B5EA7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF4361EE).withOpacity(0.35),
              blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // BMI circle
              SizedBox(
                width: 90, height: 90,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: 90, height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(_bmiColor),
                    ),
                  ),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(bmi.toStringAsFixed(1),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                    const Text('BMI',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ]),
                ]),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _bmiColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(info.bmiCategory,
                          style: TextStyle(
                              color: _bmiColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                    const SizedBox(height: 10),
                    const Text('BMI Scale',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: [
                            Expanded(child: Container(color: const Color(0xFF4CC9F0))),
                            Expanded(child: Container(color: const Color(0xFF63E6BE))),
                            Expanded(child: Container(color: const Color(0xFFFFA94D))),
                            Expanded(child: Container(color: const Color(0xFFFF8787))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('10',  style: TextStyle(color: Colors.white54, fontSize: 9)),
                        Text('18.5',style: TextStyle(color: Colors.white54, fontSize: 9)),
                        Text('25',  style: TextStyle(color: Colors.white54, fontSize: 9)),
                        Text('30+', style: TextStyle(color: Colors.white54, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 14),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'BMI calculated from your weight & height in Personal Information',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/settings'),
                  child: const Text('Update →',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Small reusable cards
// ═══════════════════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(title,
              style: TextStyle(
                  color: context.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ),
      );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: context.colors.subText, fontSize: 11)),
              Text(value, style: TextStyle(color: context.colors.text, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final CalorieState cal;
  const _NutritionCard({required this.cal});

  @override
  Widget build(BuildContext context) {
    final progress = (cal.totalCaloriesConsumed / cal.caloriesBudget).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calories',
                  style: TextStyle(color: context.colors.text, fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4361EE).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${cal.totalCaloriesConsumed} / ${cal.caloriesBudget} kcal',
                    style: const TextStyle(color: Color(0xFF4361EE), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF4361EE).withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4361EE)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(label: 'Protein', value: '${cal.totalProtein}g', color: const Color(0xFFFFA94D)),
              _MacroChip(label: 'Carbs',   value: '${cal.totalCarbs}g',   color: const Color(0xFF63E6BE)),
              _MacroChip(label: 'Fat',     value: '${cal.totalFat}g',     color: const Color(0xFFFF8787)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MacroChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value,
                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: context.colors.subText, fontSize: 11)),
        ],
      );
}

class _WaterProgressCard extends StatelessWidget {
  final WaterState water;
  const _WaterProgressCard({required this.water});

  @override
  Widget build(BuildContext context) {
    final progress = water.progress;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Water Intake',
                  style: TextStyle(color: context.colors.text, fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${water.consumedInUnit.toStringAsFixed(0)} / ${water.goalInUnit.toStringAsFixed(0)} ${water.unit}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.blue.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4CC9F0)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: Color(0xFF4CC9F0), fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacrosCard extends StatelessWidget {
  final CalorieState cal;
  const _MacrosCard({required this.cal});

  @override
  Widget build(BuildContext context) {
    final macros = [
      {'label': 'Protein', 'consumed': cal.totalProtein, 'goal': cal.proteinGoal, 'color': const Color(0xFFFFA94D)},
      {'label': 'Carbs',   'consumed': cal.totalCarbs,   'goal': cal.carbsGoal,   'color': const Color(0xFF63E6BE)},
      {'label': 'Fat',     'consumed': cal.totalFat,     'goal': cal.fatGoal,     'color': const Color(0xFFFF8787)},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: macros.map((m) {
          final consumed = m['consumed'] as int;
          final goal     = m['goal'] as int;
          final color    = m['color'] as Color;
          final pct      = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(width: 10, height: 10,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(m['label'] as String,
                          style: TextStyle(color: context.colors.text, fontWeight: FontWeight.w600, fontSize: 13)),
                    ]),
                    Text('$consumed / ${goal}g',
                        style: TextStyle(color: context.colors.subText, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(builder: (_, c) => Stack(
                  children: [
                    Container(height: 8,
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4))),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      height: 8,
                      width: c.maxWidth * pct,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
                      ),
                    ),
                  ],
                )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}