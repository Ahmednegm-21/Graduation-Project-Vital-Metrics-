import 'dart:math' as math;
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'water_details_sheet.dart';

class WaterTrackerCard extends StatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _floatCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _drink(BuildContext context) => context.read<WaterCubit>().drink();
  void _decrease(BuildContext context) => context.read<WaterCubit>().removeDrink();
  void _reset(BuildContext context) => context.read<WaterCubit>().reset();

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<WaterCubit>(),
        child: const WaterDetailsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isSmall = width < 370;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<WaterCubit, WaterState>(
      builder: (context, state) {
        final progress = state.progress.clamp(0.0, 1.0);
        final percent = (progress * 100).toInt();

        // Text and icon colors based on theme
        final titleColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final subtitleColor = isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF7B8299);
        final tuneIconColor = isDark ? Colors.white : const Color(0xFF4361EE);
        final tuneBgColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF4361EE).withOpacity(0.08);
        final tuneBorderColor = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF4361EE).withOpacity(0.15);
        final resetBtnBg = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFFF5E5E).withOpacity(0.08);
        final resetBtnBorder = isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFFF5E5E).withOpacity(0.20);

        return FadeInUp(
          duration: const Duration(milliseconds: 700),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, math.sin(_floatCtrl.value * math.pi * 2) * 4),
                child: child,
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmall ? 18 : 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF071428), Color(0xFF0B1D39), Color(0xFF09111F)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          // White background matching sleep card
                          colors: [Colors.white, Color(0xFFF5F7FF)],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FC3FF).withOpacity(isDark ? 0.18 : 0.12),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 15),
                    ),
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _GridPainter(isDark: isDark))),

                    // Particles only in dark mode, too distracting on white
                    if (isDark)
                      ...List.generate(15, (i) => _FloatingParticle(controller: _particleCtrl, index: i)),

                    Positioned(
                      top: -50,
                      right: -30,
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) => Container(
                          width: 170 + (_pulseCtrl.value * 18),
                          height: 170 + (_pulseCtrl.value * 18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF4FC3FF).withOpacity(isDark ? 0.22 : 0.08),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Container(
                              width: isSmall ? 52 : 58,
                              height: isSmall ? 52 : 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF59D8FF), Color(0xFF4361EE)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4FC3FF).withOpacity(isDark ? 0.45 : 0.30),
                                    blurRadius: 22,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hydration Core',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      // Dark title in light mode
                                      color: titleColor,
                                      fontSize: isSmall ? 18 : 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Cinematic Liquid Tracking',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      // Muted subtitle in light mode
                                      color: subtitleColor,
                                      fontSize: isSmall ? 11 : 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showDetails(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      // Blue tinted bg in light mode
                                      color: tuneBgColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: tuneBorderColor),
                                    ),
                                    child: Icon(Icons.tune_rounded, color: tuneIconColor),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmall ? 18 : 24),

                        // CENTER ROW
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _WaterInfo(
                                state: state,
                                progress: progress,
                                percent: percent,
                                isSmall: isSmall,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: isSmall ? 10 : 16),
                            _LiquidTank(
                              progress: progress,
                              waveCtrl: _waveCtrl,
                              pulseCtrl: _pulseCtrl,
                              isSmall: isSmall,
                              isDark: isDark,
                            ),
                          ],
                        ),

                        SizedBox(height: isSmall ? 20 : 24),

                        // BUTTONS
                        SizedBox(
                          height: 60,
                          child: Row(
                            children: [
                              // RESET button
                              Expanded(
                                flex: 9,
                                child: GestureDetector(
                                  onTap: () => _reset(context),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(26),
                                      // Visible bg in light mode
                                      color: resetBtnBg,
                                      border: Border.all(color: resetBtnBorder),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.restart_alt_rounded, color: Color(0xFFFF5E5E), size: 28),
                                            const SizedBox(width: 6),
                                            Text(
                                              'RESET',
                                              style: TextStyle(
                                                color: const Color(0xFFFF5E5E),
                                                fontWeight: FontWeight.w900,
                                                fontSize: isSmall ? 13 : 15,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // ADD button stays the same gradient always
                              Expanded(
                                flex: 16,
                                child: GestureDetector(
                                  onTap: () => _drink(context),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [Color(0xFF4A63FF), Color(0xFF59D8FF)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF59D8FF).withOpacity(isDark ? 0.45 : 0.30),
                                          blurRadius: 28,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: -18,
                                          left: -10,
                                          child: Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.08),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                            child: FittedBox(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white.withOpacity(0.16),
                                                    ),
                                                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'ADD ${state.drinkAmountInUnit.toStringAsFixed(0)} ${state.unit}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: isSmall ? 13 : 16,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // MINUS button stays red gradient always
                              SizedBox(
                                width: isSmall ? 72 : 82,
                                child: GestureDetector(
                                  onTap: () => _decrease(context),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF5E5E), Color(0xFFFF7A45)],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF5E5E).withOpacity(isDark ? 0.35 : 0.25),
                                          blurRadius: 22,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.remove_rounded, color: Colors.white, size: 40),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Added isDark parameter to adapt text colors
class _WaterInfo extends StatelessWidget {
  final WaterState state;
  final double progress;
  final int percent;
  final bool isSmall;
  final bool isDark;

  const _WaterInfo({
    required this.state,
    required this.progress,
    required this.percent,
    required this.isSmall,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Consumed amount color: cyan gradient in dark, solid blue in light
    final goalColor = isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF7B8299);
    final percentColor = isDark ? const Color(0xFF78D9FF) : const Color(0xFF4361EE);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: isDark
                  // Cyan to white in dark mode
                  ? [const Color(0xFF59D8FF), Colors.white]
                  // Blue gradient in light mode
                  : [const Color(0xFF4361EE), const Color(0xFF4FC3FF)],
            ).createShader(bounds),
            child: Text(
              '${state.consumedInUnit.toStringAsFixed(0)} ${state.unit}',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmall ? 34 : 42,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Goal ${state.goalInUnit.toStringAsFixed(0)} ${state.unit}',
          style: TextStyle(
            // Muted grey in light mode
            color: goalColor,
            fontSize: isSmall ? 12 : 14,
          ),
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              // Visible track in light mode
              color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFF4361EE).withOpacity(0.10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF59D8FF), Color(0xFF4361EE)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF59D8FF).withOpacity(isDark ? 0.5 : 0.35),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$percent% completed',
          style: TextStyle(
            // Blue in light mode instead of cyan
            color: percentColor,
            fontWeight: FontWeight.w800,
            fontSize: isSmall ? 14 : 16,
          ),
        ),
      ],
    );
  }
}

// Added isDark to slightly adjust tank border visibility
class _LiquidTank extends StatelessWidget {
  final double progress;
  final AnimationController waveCtrl;
  final AnimationController pulseCtrl;
  final bool isSmall;
  final bool isDark;

  const _LiquidTank({
    required this.progress,
    required this.waveCtrl,
    required this.pulseCtrl,
    required this.isSmall,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final tankHeight = isSmall ? 145.0 : 170.0;
    final tankWidth = isSmall ? 120.0 : 145.0;

    return SizedBox(
      width: tankWidth,
      height: tankHeight,
      child: AnimatedBuilder(
        animation: Listenable.merge([waveCtrl, pulseCtrl]),
        builder: (_, __) => Transform.rotate(
          angle: math.sin(pulseCtrl.value * math.pi * 2) * 0.02,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                // More visible border in light mode
                color: isDark ? Colors.white.withOpacity(0.18) : const Color(0xFF4361EE).withOpacity(0.25),
                width: 2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.white.withOpacity(0.10), Colors.white.withOpacity(0.02)]
                    : [const Color(0xFF4361EE).withOpacity(0.06), const Color(0xFF4FC3FF).withOpacity(0.03)],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutExpo,
                      height: tankHeight * progress,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF9BE8FF), Color(0xFF4A63FF)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: (tankHeight * progress) - 10,
                    child: Transform.translate(
                      offset: Offset(math.sin(waveCtrl.value * math.pi * 2) * 8, 0),
                      child: Container(
                        width: tankWidth + 15,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(
                    8,
                    (i) => Positioned(
                      bottom: 10 + ((waveCtrl.value * 100) + (i * 14)) % 100,
                      left: 15 + (i * 7) % 60,
                      child: Opacity(
                        opacity: 0.45,
                        child: Container(
                          width: (i % 4 + 3).toDouble(),
                          height: (i % 4 + 3).toDouble(),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 18,
                    child: Container(
                      width: 10,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.7), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _FloatingParticle({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final size = random.nextDouble() * 5 + 2;
    final dx = random.nextDouble() * 320;
    final delay = random.nextDouble();

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final value = (controller.value + delay) % 1;
        return Positioned(
          left: dx,
          bottom: value * 320,
          child: Opacity(
            opacity: (1 - value) * 0.7,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.7),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF59D8FF).withOpacity(0.8), blurRadius: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Added isDark to make grid visible on white background
class _GridPainter extends CustomPainter {
  final bool isDark;
  const _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // Slightly blue tinted grid lines in light mode
      ..color = isDark ? Colors.white.withOpacity(0.05) : const Color(0xFF4361EE).withOpacity(0.04)
      ..strokeWidth = 1;

    const gap = 28.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) => old.isDark != isDark;
}