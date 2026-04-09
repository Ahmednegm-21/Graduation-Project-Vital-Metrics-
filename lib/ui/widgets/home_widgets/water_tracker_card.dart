import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'water_details_sheet.dart';

class WaterTrackerCard extends StatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _drinking = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _onDrink(BuildContext context) async {
    setState(() => _drinking = true);
    await context.read<WaterCubit>().drink();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _drinking = false);
  }

  void _onReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Reset Water',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Reset today's water intake to 0?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              context.read<WaterCubit>().reset();
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WaterCubit>(),
        child: const WaterDetailsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF16213E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final subColor = isDark ? Colors.white54 : Colors.grey;
    final btnBg = isDark ? const Color(0xFF1E2D50) : const Color(0xFFF1F3FF);
    final shadow = isDark
        ? Colors.black45
        : const Color(0xFF4361EE).withOpacity(0.08);

    return BlocBuilder<WaterCubit, WaterState>(
      builder: (context, state) {
        final consumed = state.consumedInUnit;
        final goal = state.goalInUnit;
        final unit = state.unit;

        return FadeInUp(
          duration: const Duration(milliseconds: 600),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── المحتوى ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 130, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Text(
                            'Water Tracker',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => _showDetails(context),
                            child: Icon(Icons.edit, size: 14, color: subColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Goal: ${goal.toStringAsFixed(0)} $unit',
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                      const SizedBox(height: 8),

                      // Amount
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          key: ValueKey(consumed.toStringAsFixed(0)),
                          '${consumed >= 9999 ? "9999+" : consumed.toStringAsFixed(0)} $unit',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4361EE),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Progress bar
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4361EE).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            height: 6,
                            width:
                                (MediaQuery.of(context).size.width -
                                    32 -
                                    130 -
                                    36) *
                                state.progress,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Buttons
                      Row(
                        children: [
                          // Details
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showDetails(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: btnBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Color(0xFF4361EE),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Reset
                          GestureDetector(
                            onTap: () => _onReset(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(
                                  isDark ? 0.2 : 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Drink
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onDrink(context),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _drinking
                                        ? [
                                            const Color(0xFF4CC9F0),
                                            const Color(0xFF4361EE),
                                          ]
                                        : [
                                            const Color(0xFF4361EE),
                                            const Color(0xFF4CC9F0),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4361EE,
                                      ).withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: _drinking
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Drink',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── صورة الكوباية ─────────────────────────────────────────
                Positioned(
                  right: -8,
                  bottom: -8,
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 700),
                    child: _WaterFillImage(
                      progress: state.progress,
                      waveController: _waveController,
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
}

class _WaterFillImage extends StatelessWidget {
  final double progress;
  final AnimationController waveController;

  const _WaterFillImage({required this.progress, required this.waveController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 8,
            left: 18,
            right: 18,
            child: AnimatedBuilder(
              animation: waveController,
              builder: (_, __) => AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: (100 * progress).clamp(0, 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF4CC9F0).withOpacity(0.7),
                      const Color(0xFF4361EE).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          Image.asset(
            'assets/images/water_cup.png',
            width: 120,
            height: 140,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
