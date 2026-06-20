// lib/ui/screens/.../meal_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';
import 'package:vital_metrics/data/models/recipe.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';

class MealDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isArabic;
  final String? mealType;
  final bool initiallySelected;

  const MealDetailScreen({
    super.key,
    required this.recipe,
    required this.isArabic,
    this.mealType,
    this.initiallySelected = false,
  });

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen>
    with TickerProviderStateMixin {
  // Idle: emoji floating
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // Idle: pulse rings
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Macro bars entrance
  late final AnimationController _barsCtrl;

  // Serving size multiplier (1.0 = original)
  double _servingMultiplier = 1.0;

  // Added / selected states
  bool _added = false;
  late bool _selected; // deselect from the detail screen

  @override
  void initState() {
    super.initState();
    _selected = widget.initiallySelected;

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnim = Tween(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween(
      begin: 0.92,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _barsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _barsCtrl.dispose();
    super.dispose();
  }

  // Scaled values based on multiplier
  int get _scaledCalories =>
      (widget.recipe.calories * _servingMultiplier).round();
  int get _scaledProtein =>
      (widget.recipe.protein * _servingMultiplier).round();
  int get _scaledCarbs => (widget.recipe.carbs * _servingMultiplier).round();
  int get _scaledFat => (widget.recipe.fat * _servingMultiplier).round();

  String get _servingLabel {
    final mult = _servingMultiplier;
    if (mult == 1.0) return widget.recipe.servingSize;
    if (mult == 0.5) return '½ × ${widget.recipe.servingSize}';
    if (mult == 0.25) return '¼ × ${widget.recipe.servingSize}';
    if (mult == 2.0) return '2× ${widget.recipe.servingSize}';
    if (mult == 3.0) return '3× ${widget.recipe.servingSize}';
    return '${mult.toStringAsFixed(1)}× ${widget.recipe.servingSize}';
  }

  // Add to log
  void _addMeal() {
    final displayName = widget.recipe.displayName(isArabic: widget.isArabic);
    context.read<CalorieCubit>().addMeal(
      MealEntry(
        name: displayName,
        calories: _scaledCalories,
        protein: _scaledProtein,
        carbs: _scaledCarbs,
        fat: _scaledFat,
        mealType: widget.mealType ?? widget.recipe.category,
      ),
    );
    setState(() => _added = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$displayName added! +$_scaledCalories kcal'),
        backgroundColor: const Color(0xFF4361EE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Toggle selection (deselect/select)
  void _toggleSelected() {
    setState(() => _selected = !_selected);
    // return the result to RecipesScreen via Navigator.pop
    Navigator.of(context).pop({
      'action': _selected ? 'select' : 'deselect',
      'id': widget.recipe.id,
    });
  }

  // Edit serving sheet
  void _showServingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ServingSheet(
        recipe: widget.recipe,
        isArabic: widget.isArabic,
        initialMultiplier: _servingMultiplier,
        onConfirm: (v) {
          setState(() {
            _servingMultiplier = v;
            // reset add state if serving changed
            _added = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final r = widget.recipe;
    final scaledTotal = (_scaledProtein + _scaledCarbs + _scaledFat).clamp(
      1,
      99999,
    );

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: context.colors.shadow, blurRadius: 8),
              ],
            ),
            child: const Icon(
              CupertinoIcons.chevron_left,
              color: Color(0xFF4361EE),
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: FadeInDown(
          child: Text(
            'Meal Details',
            style: TextStyle(
              color: context.colors.text,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          // Category badge
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FadeInDown(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _categoryColor(r.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  r.category.toUpperCase(),
                  style: TextStyle(
                    color: _categoryColor(r.category),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Hero card
            FadeInDown(
              duration: const Duration(milliseconds: 550),
              child: _HeroCard(
                recipe: r,
                isArabic: widget.isArabic,
                floatAnim: _floatAnim,
                pulseAnim: _pulseAnim,
                serving: _servingLabel,
                isDark: isDark,
                onEditServing: _showServingSheet,
              ),
            ),

            const SizedBox(height: 20),

            // Select / Deselect pill
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _SelectTogglePill(
                isSelected: _selected,
                onTap: _toggleSelected,
              ),
            ),

            const SizedBox(height: 20),

            // Calories banner
            FadeInUp(
              delay: const Duration(milliseconds: 160),
              child: _CalorieBanner(
                calories: _scaledCalories,
                multiplier: _servingMultiplier,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 20),

            // Macros breakdown
            FadeInUp(
              delay: const Duration(milliseconds: 220),
              child: _MacroBreakdownCard(
                protein: _scaledProtein,
                carbs: _scaledCarbs,
                fat: _scaledFat,
                total: scaledTotal,
                barsCtrl: _barsCtrl,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 20),

            // Nutrition table
            FadeInUp(
              delay: const Duration(milliseconds: 280),
              child: _NutritionTable(
                recipe: r,
                calories: _scaledCalories,
                protein: _scaledProtein,
                carbs: _scaledCarbs,
                fat: _scaledFat,
                serving: _servingLabel,
                isDark: isDark,
              ),
            ),

            const SizedBox(height: 28),

            // Add button
            FadeInUp(
              delay: const Duration(milliseconds: 340),
              child: _AddButton(added: _added, onTap: _added ? null : _addMeal),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'breakfast':
        return const Color(0xFFFFA94D);
      case 'lunch':
        return const Color(0xFF63E6BE);
      case 'dinner':
        return const Color(0xFF7B5EA7);
      case 'snacks':
        return const Color(0xFF4CC9F0);
      default:
        return const Color(0xFF4361EE);
    }
  }
}

// Select/Deselect Pill
class _SelectTogglePill extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectTogglePill({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(
                  0xFFFF8787,
                ).withOpacity(context.isDark ? 0.18 : 0.10)
              : const Color(
                  0xFF4361EE,
                ).withOpacity(context.isDark ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8787).withOpacity(0.5)
                : const Color(0xFF4361EE).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected
                    ? CupertinoIcons.minus_circle_fill
                    : CupertinoIcons.checkmark_circle_fill,
                key: ValueKey(isSelected),
                color: isSelected
                    ? const Color(0xFFFF8787)
                    : const Color(0xFF4361EE),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                isSelected ? 'Deselect Meal' : 'Select Meal',
                key: ValueKey(isSelected),
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFF8787)
                      : const Color(0xFF4361EE),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Serving Edit Bottom Sheet
class _ServingSheet extends StatefulWidget {
  final Recipe recipe;
  final bool isArabic;
  final double initialMultiplier;
  final void Function(double) onConfirm;

  const _ServingSheet({
    required this.recipe,
    required this.isArabic,
    required this.initialMultiplier,
    required this.onConfirm,
  });

  @override
  State<_ServingSheet> createState() => _ServingSheetState();
}

class _ServingSheetState extends State<_ServingSheet> {
  late double _mult;
  final _presets = [0.25, 0.5, 1.0, 1.5, 2.0, 3.0];

  @override
  void initState() {
    super.initState();
    _mult = widget.initialMultiplier;
  }

  int get _cal => (widget.recipe.calories * _mult).round();
  int get _prot => (widget.recipe.protein * _mult).round();
  int get _carb => (widget.recipe.carbs * _mult).round();
  int get _fat => (widget.recipe.fat * _mult).round();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bg = isDark ? const Color(0xFF16213E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.colors.subText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // title
          Row(
            children: [
              Text(widget.recipe.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Serving Size',
                      style: TextStyle(
                        color: context.colors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Base: ${widget.recipe.servingSize}',
                      style: TextStyle(
                        color: context.colors.subText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // live calorie badge
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Container(
                  key: ValueKey(_cal),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_cal kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Slider
          Row(
            children: [
              Text(
                '¼×',
                style: TextStyle(color: context.colors.subText, fontSize: 11),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF4361EE),
                    inactiveTrackColor: const Color(
                      0xFF4361EE,
                    ).withOpacity(0.15),
                    thumbColor: const Color(0xFF4361EE),
                    overlayColor: const Color(0xFF4361EE).withOpacity(0.15),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: _mult.clamp(0.25, 3.0),
                    min: 0.25,
                    max: 3.0,
                    divisions: 11,
                    onChanged: (v) {
                      // snap to nearest preset
                      final snapped = _presets.reduce(
                        (a, b) => (a - v).abs() < (b - v).abs() ? a : b,
                      );
                      setState(() => _mult = snapped);
                    },
                  ),
                ),
              ),
              Text(
                '3×',
                style: TextStyle(color: context.colors.subText, fontSize: 11),
              ),
            ],
          ),

          // Preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _presets.map((p) {
              final isActive = (_mult - p).abs() < 0.01;
              return GestureDetector(
                onTap: () => setState(() => _mult = p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF4361EE)
                        : context.colors.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF4361EE)
                          : context.colors.divider,
                    ),
                    boxShadow: const [],
                  ),
                  child: Text(
                    p == 0.25
                        ? '¼×'
                        : p == 0.5
                        ? '½×'
                        : '${p.toStringAsFixed(p % 1 == 0 ? 0 : 1)}×',
                    style: TextStyle(
                      color: isActive ? Colors.white : context.colors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Live macros preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniMacro(
                  label: 'Protein',
                  value: '$_prot g',
                  color: const Color(0xFFFFA94D),
                ),
                _MiniMacro(
                  label: 'Carbs',
                  value: '$_carb g',
                  color: const Color(0xFF63E6BE),
                ),
                _MiniMacro(
                  label: 'Fat',
                  value: '$_fat g',
                  color: const Color(0xFFFF8787),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Confirm button
          GestureDetector(
            onTap: () {
              widget.onConfirm(_mult);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4361EE).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMacro extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniMacro({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: context.colors.subText, fontSize: 10),
        ),
      ],
    );
  }
}

// Hero Card
class _HeroCard extends StatelessWidget {
  final Recipe recipe;
  final bool isArabic;
  final Animation<double> floatAnim;
  final Animation<double> pulseAnim;
  final String serving;
  final bool isDark;
  final VoidCallback onEditServing;

  const _HeroCard({
    required this.recipe,
    required this.isArabic,
    required this.floatAnim,
    required this.pulseAnim,
    required this.serving,
    required this.isDark,
    required this.onEditServing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF16213E), const Color(0xFF1A1A2E)]
              : [Colors.white, const Color(0xFFF0F3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4361EE).withOpacity(0.10),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // pulse rings + floating emoji
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: pulseAnim.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4361EE).withOpacity(0.10),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: 1.0 + (pulseAnim.value - 0.92) * 0.5,
                    child: Container(
                      width: 116,
                      height: 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4361EE).withOpacity(0.06),
                        border: Border.all(
                          color: const Color(0xFF4361EE).withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4361EE), Color(0xFF7B5EA7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4361EE).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: floatAnim,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, floatAnim.value),
                    child: Text(
                      recipe.emoji,
                      style: const TextStyle(fontSize: 44),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              recipe.displayName(isArabic: isArabic),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: -0.3,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Serving pill — tappable
          GestureDetector(
            onTap: onEditServing,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF4361EE).withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4361EE).withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.cube_box,
                    color: Color(0xFF4361EE),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    serving,
                    style: const TextStyle(
                      color: Color(0xFF4361EE),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    CupertinoIcons.pencil,
                    color: Color(0xFF4361EE),
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Calories Banner
class _CalorieBanner extends StatelessWidget {
  final int calories;
  final double multiplier;
  final bool isDark;

  const _CalorieBanner({
    required this.calories,
    required this.multiplier,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4361EE).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Calories',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text(
                      '$calories',
                      key: ValueKey(calories),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 38,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'kcal',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              if (multiplier != 1.0)
                Text(
                  '${multiplier.toStringAsFixed(multiplier % 1 == 0 ? 0 : 1)}× serving',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.flame_fill,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

// Macro Breakdown Card
class _MacroBreakdownCard extends StatelessWidget {
  final int protein, carbs, fat, total;
  final AnimationController barsCtrl;
  final bool isDark;

  const _MacroBreakdownCard({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.total,
    required this.barsCtrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final macros = [
      {
        'label': 'Protein',
        'value': protein,
        'color': const Color(0xFFFFA94D),
        'icon': '💪',
      },
      {
        'label': 'Carbs',
        'value': carbs,
        'color': const Color(0xFF63E6BE),
        'icon': '⚡',
      },
      {
        'label': 'Fat',
        'value': fat,
        'color': const Color(0xFFFF8787),
        'icon': '🫧',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
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
                'Macros Breakdown',
                style: TextStyle(
                  color: context.colors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'per serving',
                style: TextStyle(color: context.colors.subText, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // stacked bar — min flex = 1 so a bar never disappears entirely
          _StackedBar(
            protein: protein,
            carbs: carbs,
            fat: fat,
            total: total,
            barsCtrl: barsCtrl,
          ),
          const SizedBox(height: 6),

          // legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: macros.map((m) {
              final v = m['value'] as int;
              final pct = total > 0 ? (v / total * 100).round() : 0;
              final c = m['color'] as Color;
              return Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${m['label']} $pct%',
                    style: TextStyle(
                      color: context.colors.subText,
                      fontSize: 10,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          ...macros.asMap().entries.map((e) {
            final m = e.value;
            final v = m['value'] as int;
            final c = m['color'] as Color;
            final pct = total > 0 ? v / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _MacroBar(
                label: m['label'] as String,
                icon: m['icon'] as String,
                value: v,
                pct: pct,
                color: c,
                isDark: isDark,
                context: context,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Stacked Bar
class _StackedBar extends StatelessWidget {
  final int protein, carbs, fat, total;
  final AnimationController barsCtrl;

  const _StackedBar({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.total,
    required this.barsCtrl,
  });

  @override
  Widget build(BuildContext context) {
    // if total = 0, return an empty container
    if (total <= 0) return const SizedBox(height: 14);

    return AnimatedBuilder(
      animation: barsCtrl,
      builder: (_, __) {
        final t = Curves.easeOutCubic.transform(barsCtrl.value);
        // use Row with Expanded with a correct flex value
        final pFlex = ((protein / total) * 100 * t).round().clamp(1, 200);
        final cFlex = ((carbs / total) * 100 * t).round().clamp(1, 200);
        final fFlex = ((fat / total) * 100 * t).round().clamp(1, 200);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 14,
            child: Row(
              children: [
                Expanded(
                  flex: pFlex,
                  child: Container(color: const Color(0xFFFFA94D)),
                ),
                Expanded(
                  flex: cFlex,
                  child: Container(color: const Color(0xFF63E6BE)),
                ),
                Expanded(
                  flex: fFlex,
                  child: Container(color: const Color(0xFFFF8787)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Macro Bar
class _MacroBar extends StatelessWidget {
  final String label, icon;
  final int value;
  final double pct;
  final Color color;
  final bool isDark;
  final BuildContext context;

  const _MacroBar({
    required this.label,
    required this.icon,
    required this.value,
    required this.pct,
    required this.color,
    required this.isDark,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: context.colors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value}g',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: pct.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    color: isDark ? Colors.white10 : color.withOpacity(0.12),
                  ),
                  FractionallySizedBox(
                    widthFactor: v.clamp(0.0, 1.0),
                    child: v > 0.01
                        ? Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Nutrition Table
class _NutritionTable extends StatelessWidget {
  final Recipe recipe;
  final int calories, protein, carbs, fat;
  final String serving;
  final bool isDark;

  const _NutritionTable({
    required this.recipe,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.serving,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      {
        'label': 'Calories',
        'value': '$calories kcal',
        'icon': CupertinoIcons.flame_fill,
        'color': Colors.orange,
      },
      {
        'label': 'Protein',
        'value': '${protein}g',
        'icon': CupertinoIcons.bolt_fill,
        'color': const Color(0xFFFFA94D),
      },
      {
        'label': 'Carbohydrates',
        'value': '${carbs}g',
        'icon': CupertinoIcons.circle_grid_hex,
        'color': const Color(0xFF63E6BE),
      },
      {
        'label': 'Fat',
        'value': '${fat}g',
        'icon': CupertinoIcons.drop_fill,
        'color': const Color(0xFFFF8787),
      },
      {
        'label': 'Serving Size',
        'value': serving,
        'icon': CupertinoIcons.cube_box_fill,
        'color': const Color(0xFF4361EE),
      },
    ];

    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.list_bullet,
                  color: Color(0xFF4361EE),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nutrition Facts',
                  style: TextStyle(
                    color: context.colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.divider),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            final row = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: (row['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          row['icon'] as IconData,
                          color: row['color'] as Color,
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        row['label'] as String,
                        style: TextStyle(
                          color: context.colors.text,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        row['value'] as String,
                        style: TextStyle(
                          color: context.colors.subText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 52,
                    endIndent: 18,
                    color: context.colors.divider,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// Add Button
class _AddButton extends StatelessWidget {
  final bool added;
  final VoidCallback? onTap;
  const _AddButton({required this.added, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: added
              ? const LinearGradient(
                  colors: [Color(0xFF63E6BE), Color(0xFF20C997)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (added ? const Color(0xFF63E6BE) : const Color(0xFF4361EE))
                  .withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                added
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.add_circled_solid,
                key: ValueKey(added),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                added ? 'Added to Log ✓' : 'Add to Meal Log',
                key: ValueKey(added),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}