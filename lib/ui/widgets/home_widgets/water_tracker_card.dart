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

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _floatCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _drink(BuildContext context) {
    context.read<WaterCubit>().drink();
  }

  void _decrease(BuildContext context) {
    context.read<WaterCubit>().removeDrink();
  }

  void _reset(BuildContext context) {
    context.read<WaterCubit>().reset();
  }

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

    return BlocBuilder<WaterCubit, WaterState>(
      builder: (context, state) {
        final progress = state.progress.clamp(0.0, 1.0);
        final percent = (progress * 100).toInt();

        return FadeInUp(
          duration: const Duration(milliseconds: 700),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    math.sin(_floatCtrl.value * math.pi * 2) * 4,
                  ),
                  child: child,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmall ? 18 : 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF071428),
                      Color(0xFF0B1D39),
                      Color(0xFF09111F),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FC3FF).withOpacity(0.18),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GridPainter(),
                      ),
                    ),

                    ...List.generate(
                      15,
                      (i) => _FloatingParticle(
                        controller: _particleCtrl,
                        index: i,
                      ),
                    ),

                    Positioned(
                      top: -50,
                      right: -30,
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) {
                          return Container(
                            width: 170 + (_pulseCtrl.value * 18),
                            height: 170 + (_pulseCtrl.value * 18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF4FC3FF).withOpacity(0.22),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// HEADER
                        Row(
                          children: [
                            Container(
                              width: isSmall ? 52 : 58,
                              height: isSmall ? 52 : 58,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF59D8FF),
                                    Color(0xFF4361EE),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4FC3FF,
                                    ).withOpacity(0.45),
                                    blurRadius: 22,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.water_drop_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hydration Core',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
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
                                      color:
                                          Colors.white.withOpacity(0.5),
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
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.08),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmall ? 18 : 24),

                        /// CENTER
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: _WaterInfo(
                                state: state,
                                progress: progress,
                                percent: percent,
                                isSmall: isSmall,
                              ),
                            ),

                            SizedBox(width: isSmall ? 10 : 16),

                            _LiquidTank(
                              progress: progress,
                              waveCtrl: _waveCtrl,
                              pulseCtrl: _pulseCtrl,
                              isSmall: isSmall,
                            ),
                          ],
                        ),

                        SizedBox(height: isSmall ? 20 : 24),

                        /// BUTTONS
                        SizedBox(
                          height: isSmall ? 72 : 78,
                          child: Row(
                            children: [
                              /// RESET
                              Expanded(
                                flex: 9,
                                child: GestureDetector(
                                  onTap: () => _reset(context),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(26),
                                      color:
                                          Colors.white.withOpacity(0.06),
                                      border: Border.all(
                                        color:
                                            Colors.white.withOpacity(0.08),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.18),
                                          blurRadius: 18,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.restart_alt_rounded,
                                              color:
                                                  Color(0xFFFF5E5E),
                                              size: 28,
                                            ),

                                            const SizedBox(width: 6),

                                            Text(
                                              'RESET',
                                              style: TextStyle(
                                                color:
                                                    const Color(
                                                  0xFFFF5E5E,
                                                ),
                                                fontWeight:
                                                    FontWeight.w900,
                                                fontSize:
                                                    isSmall
                                                        ? 13
                                                        : 15,
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

                              /// ADD
                              Expanded(
                                flex: 16,
                                child: GestureDetector(
                                  onTap: () => _drink(context),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(28),
                                      gradient: const LinearGradient(
                                        begin:
                                            Alignment.centerLeft,
                                        end:
                                            Alignment.centerRight,
                                        colors: [
                                          Color(0xFF4A63FF),
                                          Color(0xFF59D8FF),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF59D8FF,
                                          ).withOpacity(0.45),
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
                                              color: Colors.white
                                                  .withOpacity(0.08),
                                            ),
                                          ),
                                        ),

                                        Center(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets
                                                    .symmetric(
                                              horizontal: 10,
                                            ),
                                            child: FittedBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets
                                                            .all(8),
                                                    decoration:
                                                        BoxDecoration(
                                                      shape: BoxShape
                                                          .circle,
                                                      color: Colors
                                                          .white
                                                          .withOpacity(
                                                              0.16),
                                                    ),
                                                    child:
                                                        const Icon(
                                                      Icons
                                                          .auto_awesome,
                                                      color:
                                                          Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),

                                                  const SizedBox(
                                                      width: 10),

                                                  Text(
                                                    'ADD ${state.drinkAmountInUnit.toStringAsFixed(0)} ${state.unit}',
                                                    style:
                                                        TextStyle(
                                                      color:
                                                          Colors.white,
                                                      fontWeight:
                                                          FontWeight
                                                              .w900,
                                                      fontSize:
                                                          isSmall
                                                              ? 13
                                                              : 16,
                                                      letterSpacing:
                                                          1,
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

                              /// MINUS
                              SizedBox(
                                width: isSmall ? 72 : 82,
                                child: GestureDetector(
                                  onTap: () =>
                                      _decrease(context),
                                  child: Container(
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(28),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF5E5E),
                                          Color(0xFFFF7A45),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFFF5E5E,
                                          ).withOpacity(0.35),
                                          blurRadius: 22,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.remove_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
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

class _WaterInfo extends StatelessWidget {
  final WaterState state;
  final double progress;
  final int percent;
  final bool isSmall;

  const _WaterInfo({
    required this.state,
    required this.progress,
    required this.percent,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [
                  Color(0xFF59D8FF),
                  Colors.white,
                ],
              ).createShader(bounds);
            },
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
            color: Colors.white.withOpacity(0.5),
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
              color: Colors.white.withOpacity(0.08),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF59D8FF),
                      Color(0xFF4361EE),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF59D8FF,
                      ).withOpacity(0.5),
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
            color: const Color(0xFF78D9FF),
            fontWeight: FontWeight.w800,
            fontSize: isSmall ? 14 : 16,
          ),
        ),
      ],
    );
  }
}

class _LiquidTank extends StatelessWidget {
  final double progress;
  final AnimationController waveCtrl;
  final AnimationController pulseCtrl;
  final bool isSmall;

  const _LiquidTank({
    required this.progress,
    required this.waveCtrl,
    required this.pulseCtrl,
    required this.isSmall,
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
        builder: (_, __) {
          return Transform.rotate(
            angle:
                math.sin(pulseCtrl.value * math.pi * 2) * 0.02,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 2,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.10),
                    Colors.white.withOpacity(0.02),
                  ],
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
                        duration:
                            const Duration(milliseconds: 900),
                        curve: Curves.easeOutExpo,
                        height: tankHeight * progress,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF9BE8FF),
                              Color(0xFF4A63FF),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom:
                          (tankHeight * progress) - 10,
                      child: Transform.translate(
                        offset: Offset(
                          math.sin(
                                  waveCtrl.value *
                                      math.pi *
                                      2) *
                              8,
                          0,
                        ),
                        child: Container(
                          width: tankWidth + 15,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(40),
                            color: Colors.white
                                .withOpacity(0.25),
                          ),
                        ),
                      ),
                    ),

                    ...List.generate(
                      8,
                      (i) => Positioned(
                        bottom:
                            10 +
                                ((waveCtrl.value * 100) +
                                        (i * 14)) %
                                    100,
                        left: 15 + (i * 7) % 60,
                        child: Opacity(
                          opacity: 0.45,
                          child: Container(
                            width:
                                (i % 4 + 3).toDouble(),
                            height:
                                (i % 4 + 3).toDouble(),
                            decoration:
                                const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
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
                          borderRadius:
                              BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white
                                  .withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _FloatingParticle({
    required this.controller,
    required this.index,
  });

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
                  BoxShadow(
                    color: const Color(
                      0xFF59D8FF,
                    ).withOpacity(0.8),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const gap = 28.0;

    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}