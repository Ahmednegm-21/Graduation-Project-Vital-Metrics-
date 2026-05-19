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

  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const MealSection({
    super.key,
    required this.mealType,
    required this.label,
    required this.emoji,
    required this.index,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final cardBg = isDark
        ? const Color(0xFF16213E)
        : Colors.white;

    final activeBg = isDark
        ? const Color(0xFF1E2D50)
        : const Color(0xFFF1F3FF);

    final textColor = isDark
        ? Colors.white
        : const Color(0xFF2D3142);

    final shadow = isDark
        ? Colors.black45
        : Colors.black12;

    return FadeInUp(
      delay: Duration(
        milliseconds: 120 * index,
      ),

      duration: const Duration(
        milliseconds: 550,
      ),

      child: BlocBuilder<
          CalorieCubit,
          CalorieState>(
        builder: (context, state) {
          final meals =
              state.mealsFor(mealType);

          final hasMeals =
              meals.isNotEmpty;

          return GestureDetector(
            onTap: () => context.push(
              '/recipes?mealType=$mealType',
            ),

            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 350,
              ),

              width: double.infinity,

              padding: const EdgeInsets.all(
                16,
              ),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: hasMeals
                      ? isDark
                          ? [
                              const Color(
                                0xFF1F2E5A,
                              ),
                              const Color(
                                0xFF16213E,
                              ),
                            ]
                          : [
                              const Color(
                                0xFFF5F7FF,
                              ),
                              Colors.white,
                            ]
                      : isDark
                          ? [
                              const Color(
                                0xFF16213E,
                              ),
                              const Color(
                                0xFF121B34,
                              ),
                            ]
                          : [
                              Colors.white,
                              const Color(
                                0xFFF8F9FF,
                              ),
                            ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  28,
                ),

                border: Border.all(
                  color: hasMeals
                      ? const Color(
                          0xFF4361EE,
                        ).withOpacity(0.25)
                      : Colors.white
                          .withOpacity(0.04),
                ),

                boxShadow: [
                  BoxShadow(
                    color: shadow,
                    blurRadius: 18,
                    offset:
                        const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                children: [
                  // EMOJI
                  Text(
                    emoji,
                    style:
                        const TextStyle(
                      fontSize: 42,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // TITLE
                  Text(
                    label,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: textColor,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // KCAL
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),

                      color: const Color(
                        0xFFFFB347,
                      ).withOpacity(0.15),
                    ),

                    child: Text(
                      '$calories kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        color:
                            Color(0xFFFFB347),
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // MACROS
                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(
                      12,
                    ),

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        18,
                      ),

                      color: isDark
                          ? Colors.white
                              .withOpacity(
                                0.04,
                              )
                          : Colors.black
                              .withOpacity(
                                0.03,
                              ),
                    ),

                    child: Column(
                      children: [
                        _macroRow(
                          'Protein',
                          protein,
                          const Color(
                            0xFFFF9A3C,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        _macroRow(
                          'Carbs',
                          carbs,
                          const Color(
                            0xFF2ECC9A,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        _macroRow(
                          'Fat',
                          fat,
                          const Color(
                            0xFFFF6B6B,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ADD BUTTON
                  GestureDetector(
                    onTap: () {
                      context.push(
                        '/recipes?mealType=$mealType',
                      );
                    },

                    child: Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF4361EE),
                            Color(0xFF5B7CFF),
                          ],
                        ),

                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(
                                  0xFF4361EE,
                                ).withOpacity(
                                  0.35,
                                ),
                            blurRadius: 14,
                            offset:
                                const Offset(
                                  0,
                                  6,
                                ),
                          ),
                        ],
                      ),

                      child: const Center(
                        child: Text(
                          '+ Add Meal',
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // RESET BUTTON
                  if (hasMeals) ...[
                    const SizedBox(
                      height: 12,
                    ),

                    GestureDetector(
                      onTap: () {
                        for (final meal
                            in meals) {
                          context
                              .read<
                                CalorieCubit
                              >()
                              .removeMeal(
                                meal,
                              );
                        }
                      },

                      child: Container(
                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 13,
                        ),

                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                                18,
                              ),

                          color: Colors.red
                              .withOpacity(
                                0.12,
                              ),

                          border: Border.all(
                            color: Colors.red
                                .withOpacity(
                                  0.25,
                                ),
                          ),
                        ),

                        child: const Center(
                          child: Text(
                            'Reset Meal',
                            style: TextStyle(
                              color:
                                  Colors.redAccent,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _macroRow(
    String label,
    int value,
    Color color,
  ) {
    return Row(
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

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          '${value}g',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
