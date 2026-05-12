import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/logic/fitness/fitness_snapshot_cubit.dart';
import 'package:vital_metrics/logic/home/settings/personal_info_cubit.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'package:vital_metrics/logic/progress/progress_cubit.dart';
import 'package:vital_metrics/services/google_fit_service.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/data/models/user_goal.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';

const _blue = Color(0xFF4361EE);
const _green = Color(0xFF63E6BE);
const _cyan = Color(0xFF4CC9F0);
const _orange = Color(0xFFFFA94D);
const _red = Color(0xFFFF8787);
const _purple = Color(0xFF7B5EA7);

// Returns the grid index (0=Sat ... 6=Fri) for today
// Dart weekday: Mon=1 Tue=2 Wed=3 Thu=4 Fri=5 Sat=6 Sun=7
int _todayIndex() {
  switch (DateTime.now().weekday) {
    case 6:
      return 0; // Saturday
    case 7:
      return 1; // Sunday
    case 1:
      return 2; // Monday
    case 2:
      return 3; // Tuesday
    case 3:
      return 4; // Wednesday
    case 4:
      return 5; // Thursday
    case 5:
      return 6; // Friday
    default:
      return 0;
  }
}

int _stepsGoalFor(OnboardingCubitAllData onboarding) {
  final goal = onboarding.currentData.goal;
  if (goal == null) return 10000;
  switch (goal.type) {
    case GoalType.loseWeight:
      return 12000;
    case GoalType.gainWeight:
      return 8000;
  }
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _chartPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProgressCubit>().loadWeeklyMetrics();
    context.read<FitnessSnapshotCubit>().load();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Progress',
          style: TextStyle(
            color: context.colors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          _BellButton(isDark: context.isDark),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: context.colors.shadow, blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.settings, color: _blue, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<PersonalInfoCubit, PersonalInfoState>(
        builder: (context, info) => BlocBuilder<CalorieCubit, CalorieState>(
          builder: (context, cal) => BlocBuilder<WaterCubit, WaterState>(
            builder: (context, water) => BlocBuilder<ProgressCubit, ProgressState>(
              builder: (context, progress) =>
                  BlocBuilder<FitnessSnapshotCubit, FitnessSnapshotState>(
                    builder: (context, fitness) {
                      final isLoading = progress is ProgressLoading;
                      final loaded = progress is ProgressLoaded
                          ? progress as ProgressLoaded
                          : null;
                      return RefreshIndicator(
                        color: _blue,
                        onRefresh: () async => Future.wait([
                          context.read<ProgressCubit>().loadWeeklyMetrics(),
                          context.read<FitnessSnapshotCubit>().load(),
                        ]),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: FadeInDown(child: _BmiCard(info: info)),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: FadeInDown(
                                  delay: const Duration(milliseconds: 70),
                                  child: _ActivitySummaryCard(fitness: fitness),
                                ),
                              ),
                              const SizedBox(height: 20),
                              FadeInDown(
                                delay: const Duration(milliseconds: 120),
                                child: _ChartsSection(
                                  pageCtrl: _pageCtrl,
                                  chartPage: _chartPage,
                                  onPageChanged: (i) =>
                                      setState(() => _chartPage = i),
                                  isLoading: isLoading,
                                  loaded: loaded,
                                  cal: cal,
                                  stepsGoal: _stepsGoalFor(
                                    context.read<OnboardingCubitAllData>(),
                                  ),
                                  todayIndex: _todayIndex(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 200),
                                      child: const _SectionTitle(
                                        title: 'Body Stats',
                                      ),
                                    ),
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 220),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _StatCard(
                                              label: 'Weight',
                                              value:
                                                  '${info.weight.toStringAsFixed(1)} kg',
                                              icon:
                                                  Icons.monitor_weight_outlined,
                                              color: _blue,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _StatCard(
                                              label: 'Height',
                                              value:
                                                  '${info.height.toStringAsFixed(0)} cm',
                                              icon: Icons.height,
                                              color: _purple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 240),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _StatCard(
                                              label: 'Age',
                                              value: '${info.age} yrs',
                                              icon: Icons.cake_outlined,
                                              color: _orange,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _StatCard(
                                              label: 'Gender',
                                              value: info.gender == 'male'
                                                  ? 'Male'
                                                  : 'Female',
                                              icon: Icons.person_outline,
                                              color: _cyan,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 260),
                                      child: const _SectionTitle(
                                        title: "Today's Nutrition",
                                      ),
                                    ),
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 280),
                                      child: _NutritionCard(cal: cal),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 300),
                                      child: const _SectionTitle(
                                        title: 'Water Progress',
                                      ),
                                    ),
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 320),
                                      child: _WaterProgressCard(water: water),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: [
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 340),
                                      child: const _SectionTitle(
                                        title: 'Macros Breakdown',
                                      ),
                                    ),
                                    FadeInDown(
                                      delay: const Duration(milliseconds: 360),
                                      child: _MacrosCard(cal: cal),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
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

// ---------------------------------------------------------------------------
// Charts section
// ---------------------------------------------------------------------------

class _ChartsSection extends StatelessWidget {
  final PageController pageCtrl;
  final int chartPage;
  final ValueChanged<int> onPageChanged;
  final bool isLoading;
  final ProgressLoaded? loaded;
  final CalorieState cal;
  final int stepsGoal;
  final int todayIndex;

  static const _days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const _charts = [
    _ChartMeta('Calories', '🔥', _blue),
    _ChartMeta('Steps', '👟', _green),
    _ChartMeta('Burned', '⚡', _red),
    _ChartMeta('Water', '💧', _cyan),
    _ChartMeta('Sleep', '🌙', _purple),
  ];

  const _ChartsSection({
    required this.pageCtrl,
    required this.chartPage,
    required this.onPageChanged,
    required this.isLoading,
    required this.loaded,
    required this.cal,
    this.stepsGoal = 10000,
    this.todayIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab strip
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _charts.length,
            itemBuilder: (_, i) {
              final active = i == chartPage;
              return GestureDetector(
                onTap: () => pageCtrl.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? _charts[i].color
                        : _charts[i].color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_charts[i].emoji} ${_charts[i].title}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.white : _charts[i].color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Chart pages
        SizedBox(
          height: 240,
          child: PageView(
            controller: pageCtrl,
            onPageChanged: onPageChanged,
            children: [
              _pad(
                _CaloriesBarChart(
                  values:
                      loaded?.calories.map((v) => v.toDouble()).toList() ??
                      List.filled(7, 0),
                  goal: cal.caloriesBudget.toDouble(),
                  days: _days,
                  isLoading: isLoading,
                  todayIndex: todayIndex,
                ),
              ),
              _pad(
                _StepsLineChart(
                  values:
                      loaded?.steps.map((v) => v.toDouble()).toList() ??
                      List.filled(7, 0),
                  days: _days,
                  isLoading: isLoading,
                  stepsGoal: stepsGoal,
                  todayIndex: todayIndex,
                ),
              ),
              _pad(
                _BurnedHorizontalChart(
                  values:
                      loaded?.burned.map((v) => v.toDouble()).toList() ??
                      List.filled(7, 0),
                  days: _days,
                  isLoading: isLoading,
                  todayIndex: todayIndex,
                ),
              ),
              _pad(
                _WaterAreaChart(
                  values:
                      loaded?.waterMl.map((v) => v / 1000.0).toList() ??
                      List.filled(7, 0),
                  days: _days,
                  isLoading: isLoading,
                  todayIndex: todayIndex,
                ),
              ),
              _pad(
                _SleepBarChart(
                  values: loaded?.sleepHrs ?? List.filled(7, 0),
                  days: _days,
                  isLoading: isLoading,
                  todayIndex: todayIndex,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_charts.length, (i) {
            final active = i == chartPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? _charts[i].color
                    : _charts[i].color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _pad(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: child);
}

class _ChartMeta {
  final String title, emoji;
  final Color color;
  const _ChartMeta(this.title, this.emoji, this.color);
}

// ---------------------------------------------------------------------------
// Shared card wrapper
// ---------------------------------------------------------------------------

class _ChartCard extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  final bool isLoading;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: context.colors.shadow,
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: context.colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: color,
                    strokeWidth: 2,
                  ),
                )
              : child,
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Calories bar chart
// ---------------------------------------------------------------------------

class _CaloriesBarChart extends StatelessWidget {
  final List<double> values;
  final double goal;
  final List<String> days;
  final bool isLoading;
  final int todayIndex;

  const _CaloriesBarChart({
    required this.values,
    required this.goal,
    required this.days,
    required this.isLoading,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) => _ChartCard(
    title: 'Weekly Calories',
    subtitle: 'Goal: ${goal.toInt()} kcal',
    color: _blue,
    isLoading: isLoading,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final v = values[i];
        final pct = goal > 0 ? (v / goal).clamp(0.0, 1.0) : 0.0;
        final isToday = i == todayIndex;
        final color = v > goal
            ? _red
            : isToday
            ? _blue
            : _blue.withOpacity(0.45);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (v > 0)
                  Text(
                    v >= 1000
                        ? '${(v / 1000).toStringAsFixed(1)}k'
                        : '${v.toInt()}',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: isToday ? _blue : context.colors.subText,
                    ),
                  ),
                const SizedBox(height: 3),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 90,
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? Colors.white.withOpacity(0.07)
                            : const Color(0xFFF0F0F8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500 + i * 80),
                      curve: Curves.easeOut,
                      height: 90 * pct,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: _blue.withOpacity(0.4),
                                  blurRadius: 6,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? _blue : context.colors.subText,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

// ---------------------------------------------------------------------------
// Steps line chart
// ---------------------------------------------------------------------------

class _StepsLineChart extends StatelessWidget {
  final List<double> values;
  final List<String> days;
  final bool isLoading;
  final int stepsGoal;
  final int todayIndex;

  const _StepsLineChart({
    required this.values,
    required this.days,
    required this.isLoading,
    this.stepsGoal = 10000,
    this.todayIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty
        ? stepsGoal.toDouble()
        : values.reduce(math.max);
    final goalLabel = stepsGoal >= 1000
        ? '${(stepsGoal / 1000).toStringAsFixed(0)}k'
        : '$stepsGoal';

    return _ChartCard(
      title: 'Weekly Steps',
      subtitle: 'Goal: $goalLabel / day',
      color: _green,
      isLoading: isLoading,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _LinePainter(
                values: values,
                maxValue: maxV > 0 ? maxV : 10000,
                color: _green,
                isDark: context.isDark,
                todayIndex: todayIndex,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isToday = i == todayIndex;
              final steps = values[i].toInt();
              final label = steps >= 1000
                  ? '${(steps / 1000).toStringAsFixed(1)}k'
                  : steps > 0
                  ? '$steps'
                  : '';
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                      color: isToday ? _green : context.colors.subText,
                    ),
                  ),
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 9,
                      color: isToday ? _green : context.colors.subText,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color color;
  final bool isDark;
  final int todayIndex;

  const _LinePainter({
    required this.values,
    required this.maxValue,
    required this.color,
    required this.isDark,
    required this.todayIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.every((v) => v == 0)) return;

    final pts = List.generate(
      values.length,
      (i) => Offset(
        i / (values.length - 1) * size.width,
        size.height - (values[i] / maxValue).clamp(0, 1) * size.height,
      ),
    );

    final fill = Path()..moveTo(pts.first.dx, size.height);
    for (int i = 0; i < pts.length; i++) {
      if (i == 0) {
        fill.lineTo(pts[i].dx, pts[i].dy);
      } else {
        final cp = Offset(
          (pts[i - 1].dx + pts[i].dx) / 2,
          (pts[i - 1].dy + pts[i].dy) / 2,
        );
        fill.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
      }
    }
    fill
      ..lineTo(pts.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.35), color.withOpacity(0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      line.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    line.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    for (int i = 0; i < pts.length; i++) {
      final isToday = i == todayIndex;
      canvas.drawCircle(
        pts[i],
        isToday ? 5 : 3.5,
        Paint()..color = isToday ? color : color.withOpacity(0.6),
      );
      canvas.drawCircle(
        pts[i],
        isToday ? 3 : 2,
        Paint()..color = isDark ? const Color(0xFF1A1A2E) : Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) =>
      o.values != values || o.todayIndex != todayIndex;
}

// ---------------------------------------------------------------------------
// Burned horizontal chart
// ---------------------------------------------------------------------------

class _BurnedHorizontalChart extends StatelessWidget {
  final List<double> values;
  final List<String> days;
  final bool isLoading;
  final int todayIndex;

  const _BurnedHorizontalChart({
    required this.values,
    required this.days,
    required this.isLoading,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1.0 : values.reduce(math.max);
    return _ChartCard(
      title: 'Calories Burned',
      subtitle: 'This week',
      color: _red,
      isLoading: isLoading,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (i) {
          final pct = maxV > 0 ? (values[i] / maxV).clamp(0.0, 1.0) : 0.0;
          final isToday = i == todayIndex;
          return Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 9,
                    color: isToday ? _red : context.colors.subText,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? Colors.white.withOpacity(0.07)
                            : const Color(0xFFF0F0F8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedFractionallySizedBox(
                      duration: Duration(milliseconds: 500 + i * 80),
                      curve: Curves.easeOut,
                      widthFactor: pct,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _red.withOpacity(isToday ? 1 : 0.55),
                              _orange.withOpacity(isToday ? 1 : 0.55),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isToday
                              ? [
                                  BoxShadow(
                                    color: _red.withOpacity(0.4),
                                    blurRadius: 4,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 30,
                child: Text(
                  '${values[i].toInt()}',
                  style: TextStyle(
                    fontSize: 9,
                    color: isToday ? _red : context.colors.subText,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Water area chart
// ---------------------------------------------------------------------------

class _WaterAreaChart extends StatelessWidget {
  final List<double> values;
  final List<String> days;
  final bool isLoading;
  final int todayIndex;

  const _WaterAreaChart({
    required this.values,
    required this.days,
    required this.isLoading,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) => _ChartCard(
    title: 'Weekly Water',
    subtitle: 'Goal: 2.5L / day',
    color: _cyan,
    isLoading: isLoading,
    child: Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: _AreaPainter(
              values: values,
              maxValue: 3.5,
              color: _cyan,
              isDark: context.isDark,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isToday = i == todayIndex;
            return Column(
              children: [
                if (values[i] > 0)
                  Text(
                    '${values[i].toStringAsFixed(1)}L',
                    style: TextStyle(
                      fontSize: 7,
                      color: isToday ? _cyan : context.colors.subText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 9,
                    color: isToday ? _cyan : context.colors.subText,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    ),
  );
}

class _AreaPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color color;
  final bool isDark;

  const _AreaPainter({
    required this.values,
    required this.maxValue,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.every((v) => v == 0)) return;
    final pts = List.generate(
      values.length,
      (i) => Offset(
        i / (values.length - 1) * size.width,
        size.height - (values[i] / maxValue).clamp(0, 1) * size.height,
      ),
    );

    final fill = Path()
      ..moveTo(0, size.height)
      ..lineTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      fill.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.5), color.withOpacity(0.04)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final stroke = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      stroke.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    stroke.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(
      stroke,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dashed goal line at 2.5L
    final goalY = size.height - (2.5 / maxValue) * size.height;
    final dash = Paint()
      ..color = color.withOpacity(0.45)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, goalY),
        Offset(math.min(x + 6, size.width), goalY),
        dash,
      );
      x += 10;
    }
  }

  @override
  bool shouldRepaint(_AreaPainter o) => o.values != values;
}

// ---------------------------------------------------------------------------
// Sleep bar chart — replaced radial with simple bars, easier to read
// ---------------------------------------------------------------------------

class _SleepBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> days;
  final bool isLoading;
  final int todayIndex;

  const _SleepBarChart({
    required this.values,
    required this.days,
    required this.isLoading,
    required this.todayIndex,
  });

  @override
  Widget build(BuildContext context) {
    const goal = 8.0;
    // Cap each day at 12h max since backend can accumulate duplicate sessions
    final capped = values.map((v) => v.clamp(0.0, 12.0)).toList();
    final total = capped.fold(0.0, (a, b) => a + b);

    return _ChartCard(
      title: 'Weekly Sleep',
      subtitle: 'Goal: 8h / night',
      color: _purple,
      isLoading: isLoading,
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final pct = (capped[i] / goal).clamp(0.0, 1.0);
                final isToday = i == todayIndex;
                return Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        days[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday ? _purple : context.colors.subText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: context.isDark
                                  ? Colors.white.withOpacity(0.07)
                                  : const Color(0xFFF0F0F8),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          AnimatedFractionallySizedBox(
                            duration: Duration(milliseconds: 500 + i * 80),
                            curve: Curves.easeOut,
                            widthFactor: pct,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _purple.withOpacity(isToday ? 1.0 : 0.5),
                                    _cyan.withOpacity(isToday ? 0.9 : 0.35),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color: _purple.withOpacity(0.4),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 34,
                      child: Text(
                        capped[i] > 0
                            ? '${capped[i].toStringAsFixed(1)}h'
                            : '-',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday ? _purple : context.colors.subText,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple.withOpacity(0.12),
                  border: Border.all(
                    color: _purple.withOpacity(0.35),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${total.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _purple,
                      ),
                    ),
                    Text(
                      'total',
                      style: TextStyle(
                        fontSize: 9,
                        color: _purple.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Activity summary card
// ---------------------------------------------------------------------------

class _ActivitySummaryCard extends StatelessWidget {
  final FitnessSnapshotState fitness;
  final int stepsGoal;

  const _ActivitySummaryCard({required this.fitness, this.stepsGoal = 10000});

  @override
  Widget build(BuildContext context) {
    final isLoading =
        fitness is FitnessSnapshotLoading || fitness is FitnessSnapshotInitial;

    int steps = 0;
    int calories = 0;
    int workoutMins = 0;

    if (fitness is FitnessSnapshotLoaded) {
      final snap = (fitness as FitnessSnapshotLoaded).snapshot;
      steps = snap.steps;
      calories = snap.caloriesBurned;
      workoutMins = snap.workoutMinutes;
    }

    final stepPct = (steps / stepsGoal).clamp(0.0, 1.0);
    final stepsLabel = steps >= 1000
        ? '${(steps / 1000).toStringAsFixed(1)}k'
        : '$steps';
    final goalLabel = stepsGoal >= 1000
        ? '${(stepsGoal / 1000).toStringAsFixed(0)}k'
        : '$stepsGoal';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _green.withOpacity(0.18)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(color: _green, strokeWidth: 2),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Activity",
                      style: TextStyle(
                        color: context.colors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _green.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: _green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Health Connect',
                            style: TextStyle(
                              color: _green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CircularProgressIndicator(
                              value: stepPct,
                              strokeWidth: 7,
                              backgroundColor: _green.withOpacity(0.12),
                              valueColor: const AlwaysStoppedAnimation(_green),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                stepsLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: context.colors.text,
                                ),
                              ),
                              Text(
                                'steps',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: context.colors.subText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _StatChip(
                            icon: Icons.local_fire_department_rounded,
                            color: _red,
                            value: '$calories kcal',
                            label: 'Burned',
                          ),
                          const SizedBox(height: 10),
                          _StatChip(
                            icon: Icons.fitness_center_rounded,
                            color: _orange,
                            value: '${workoutMins}m',
                            label: 'Workout',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step goal',
                      style: TextStyle(
                        fontSize: 11,
                        color: context.colors.subText,
                      ),
                    ),
                    Text(
                      '$steps / $goalLabel',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: stepPct,
                    minHeight: 7,
                    backgroundColor: _green.withOpacity(0.10),
                    valueColor: const AlwaysStoppedAnimation(_green),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value, label;

  const _StatChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.18)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: context.colors.text,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: context.colors.subText),
            ),
          ],
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Misc widgets
// ---------------------------------------------------------------------------

class _BellButton extends StatelessWidget {
  final bool isDark;
  const _BellButton({required this.isDark});
  static const int _unread = 3;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/notifications'),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: context.colors.shadow, blurRadius: 8)],
          ),
          child: Icon(
            CupertinoIcons.bell_fill,
            color: isDark ? _orange : _blue,
            size: 20,
          ),
        ),
        if (_unread > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4757),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF0F1221)
                      : const Color(0xFFF0F3FF),
                  width: 1.5,
                ),
              ),
              child: Text(
                '$_unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: context.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: context.colors.shadow,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
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
            Text(
              label,
              style: TextStyle(color: context.colors.subText, fontSize: 11),
            ),
            Text(
              value,
              style: TextStyle(
                color: context.colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _BmiCard extends StatelessWidget {
  final PersonalInfoState info;
  const _BmiCard({required this.info});

  Color get _bmiColor {
    final b = info.bmi;
    if (b < 18.5) return _cyan;
    if (b < 25) return _green;
    if (b < 30) return _orange;
    return _red;
  }

  @override
  Widget build(BuildContext context) {
    final bmi = info.bmi;
    final progress = ((bmi - 10) / 30).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blue, _purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(_bmiColor),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const Text(
                          'BMI',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _bmiColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        info.bmiCategory,
                        style: TextStyle(
                          color: _bmiColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'BMI Scale',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 8,
                        child: Row(
                          children: [
                            Expanded(child: Container(color: _cyan)),
                            Expanded(child: Container(color: _green)),
                            Expanded(child: Container(color: _orange)),
                            Expanded(child: Container(color: _red)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '10',
                          style: TextStyle(color: Colors.white54, fontSize: 9),
                        ),
                        Text(
                          '18.5',
                          style: TextStyle(color: Colors.white54, fontSize: 9),
                        ),
                        Text(
                          '25',
                          style: TextStyle(color: Colors.white54, fontSize: 9),
                        ),
                        Text(
                          '30+',
                          style: TextStyle(color: Colors.white54, fontSize: 9),
                        ),
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
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
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
    final progress = (cal.totalCaloriesConsumed / cal.caloriesBudget).clamp(
      0.0,
      1.0,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories',
                style: TextStyle(
                  color: context.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${cal.totalCaloriesConsumed} / ${cal.caloriesBudget} kcal',
                  style: const TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: _blue.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(_blue),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(
                label: 'Protein',
                value: '${cal.totalProtein}g',
                color: _orange,
              ),
              _MacroChip(
                label: 'Carbs',
                value: '${cal.totalCarbs}g',
                color: _green,
              ),
              _MacroChip(label: 'Fat', value: '${cal.totalFat}g', color: _red),
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

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(color: context.colors.subText, fontSize: 11),
      ),
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
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Intake',
                style: TextStyle(
                  color: context.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${water.consumedInUnit.toStringAsFixed(0)} / ${water.goalInUnit.toStringAsFixed(0)} ${water.unit}',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
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
                    valueColor: const AlwaysStoppedAnimation(_cyan),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: _cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
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
      {
        'label': 'Protein',
        'consumed': cal.totalProtein,
        'goal': cal.proteinGoal,
        'color': _orange,
      },
      {
        'label': 'Carbs',
        'consumed': cal.totalCarbs,
        'goal': cal.carbsGoal,
        'color': _green,
      },
      {
        'label': 'Fat',
        'consumed': cal.totalFat,
        'goal': cal.fatGoal,
        'color': _red,
      },
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: macros.map((m) {
          final consumed = m['consumed'] as int;
          final goal = m['goal'] as int;
          final color = m['color'] as Color;
          final pct = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          m['label'] as String,
                          style: TextStyle(
                            color: context.colors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$consumed / ${goal}g',
                      style: TextStyle(
                        color: context.colors.subText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (_, c) => Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOut,
                        height: 8,
                        width: c.maxWidth * pct,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
