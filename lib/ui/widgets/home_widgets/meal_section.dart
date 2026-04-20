import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';

class MealSection extends StatelessWidget {
  final String mealType;
  final String label;
  final String emoji;
  final int index;

  const MealSection({
    super.key,
    required this.mealType,
    required this.label,
    required this.emoji,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final cardBg    = isDark ? const Color(0xFF16213E) : Colors.white;
    final activeBg  = isDark ? const Color(0xFF1E2D50) : const Color(0xFFF1F3FF);
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final shadow    = isDark ? Colors.black45 : Colors.black12;

    return FadeInUp(
      delay: Duration(milliseconds: 100 * index),
      duration: const Duration(milliseconds: 500),
      child: BlocBuilder<CalorieCubit, CalorieState>(
        builder: (context, state) {
          final meals    = state.mealsFor(mealType);
          final hasmeals = meals.isNotEmpty;

          return GestureDetector(
            onTap: () => context.push('/recipes?mealType=$mealType'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasmeals ? activeBg : cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  if (!hasmeals)
                    const Text(
                      '+ Add',
                      style: TextStyle(fontSize: 11, color: Color(0xFF4361EE), fontWeight: FontWeight.w500),
                    )
                  else
                    Text(
                      '${meals.fold(0, (s, m) => s + m.calories)} kcal',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF4361EE), fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}