// lib/ui/screens/splash_screen.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Controllers ────────────────────────────────────────────────────────────
  late final AnimationController _masterCtrl;   // drives everything
  late final AnimationController _particleCtrl; // infinite particle orbit
  late final AnimationController _pulseCtrl;    // ring pulse
  late final AnimationController _shimmerCtrl;  // text shimmer

  // ── Logo ───────────────────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoGlow;

  // ── Ring ───────────────────────────────────────────────────────────────────
  late final Animation<double> _ring1Sweep;
  late final Animation<double> _ring2Sweep;
  late final Animation<double> _ring3Opacity;

  // ── Text ───────────────────────────────────────────────────────────────────
  late final Animation<double>  _titleOpacity;
  late final Animation<Offset>  _titleSlide;
  late final Animation<double>  _subtitleOpacity;
  late final Animation<Offset>  _subtitleSlide;

  // ── Progress bar ───────────────────────────────────────────────────────────
  late final Animation<double> _barWidth;
  late final Animation<double> _barOpacity;

  // ── Pulse ──────────────────────────────────────────────────────────────────
  late final Animation<double> _pulse;
  late final Animation<double> _shimmer;

  static const _primary   = Color(0xFF4361EE);
  static const _secondary = Color(0xFF4CC9F0);
  static const _accent    = Color(0xFF7B5EA7);
  static const _bgDark    = Color(0xFF050816);

  @override
  void initState() {
    super.initState();

    // ── Master (3.6s total) ────────────────────────────────────────────────
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..forward();

    // ── Particles (infinite) ──────────────────────────────────────────────
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    // ── Pulse ring (infinite) ─────────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // ── Shimmer (infinite) ────────────────────────────────────────────────
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // ── Logo ──────────────────────────────────────────────────────────────
    _logoScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.18, curve: Curves.easeOut),
      ),
    );
    _logoGlow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.20, 0.50, curve: Curves.easeOut),
      ),
    );

    // ── Rings ─────────────────────────────────────────────────────────────
    _ring1Sweep = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.08, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _ring2Sweep = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _ring3Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOut),
      ),
    );

    // ── Text ──────────────────────────────────────────────────────────────
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.42, 0.65, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.42, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.55, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    // ── Progress bar ──────────────────────────────────────────────────────
    _barOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.65, 0.78, curve: Curves.easeOut),
      ),
    );
    _barWidth = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.72, 1.0, curve: Curves.easeInOut),
      ),
    );

    // ── Pulse / shimmer ───────────────────────────────────────────────────
    _pulse   = Tween(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shimmer = Tween(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    // ── Auth check after animation settles ───────────────────────────────
    Timer(const Duration(milliseconds: 3200), () {
      if (mounted) context.read<AuthCubit>().checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAdminSuccess) {
          // ✅ Admin → Admin Panel مباشرةً
          context.go('/admin-panel');
        } else if (state is AuthSuccess) {
          final onboardingComplete = state.user.onboardingComplete ?? false;
          if (onboardingComplete) {
            context.go('/home');
          } else {
            context.go('/gender');
          }
        } else if (state is AuthInitial || state is AuthError) {
          context.go('/signin');
        }
      },
      child: Scaffold(
        backgroundColor: _bgDark,
        body: Stack(
          children: [
            // ── Deep space background ──────────────────────────────────────
            _buildBackground(),

            // ── Animated particles ─────────────────────────────────────────
            _buildParticles(),

            // ── Main content ───────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildLogoSection(),
                  const SizedBox(height: 48),
                  _buildTextSection(),
                  const Spacer(flex: 2),
                  _buildProgressSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Background ────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return Stack(
      children: [
        // Top-right nebula glow
        Positioned(
          top: -120,
          right: -100,
          child: AnimatedBuilder(
            animation: _masterCtrl,
            builder: (_, __) => Opacity(
              opacity: (_logoGlow.value * 0.6).clamp(0, 1),
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primary.withOpacity(0.25),
                      _accent.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Bottom-left nebula glow
        Positioned(
          bottom: -150,
          left: -120,
          child: AnimatedBuilder(
            animation: _masterCtrl,
            builder: (_, __) => Opacity(
              opacity: (_ring2Sweep.value * 0.55).clamp(0, 1),
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _secondary.withOpacity(0.20),
                      _primary.withOpacity(0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Dot-grid overlay
        Positioned.fill(
          child: CustomPaint(painter: _GridPainter()),
        ),
      ],
    );
  }

  // ── Floating particles ────────────────────────────────────────────────────

  Widget _buildParticles() {
    final particles = [
      _P(top: 0.12, left: 0.08,  r: 3.5, speed: 1.0,  color: _primary),
      _P(top: 0.18, right: 0.06, r: 2.5, speed: 0.7,  color: _secondary),
      _P(top: 0.28, left: 0.15,  r: 4.0, speed: 1.3,  color: _accent),
      _P(top: 0.72, right: 0.10, r: 3.0, speed: 0.9,  color: _primary),
      _P(top: 0.80, left: 0.07,  r: 2.0, speed: 1.5,  color: _secondary),
      _P(top: 0.65, right: 0.18, r: 5.0, speed: 0.6,  color: _accent),
      _P(top: 0.35, left: 0.88,  r: 3.0, speed: 1.1,  color: _primary),
      _P(top: 0.55, left: 0.92,  r: 2.5, speed: 0.8,  color: _secondary),
      _P(top: 0.45, left: 0.04,  r: 2.0, speed: 1.4,  color: _accent),
    ];

    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        return Stack(
          children: particles.map((p) {
            final t   = _particleCtrl.value;
            final dy  = math.sin(t * 2 * math.pi * p.speed) * 12.0;
            final dx  = math.cos(t * 2 * math.pi * p.speed) * 8.0;
            final op  = (0.20 + math.sin(t * 2 * math.pi * p.speed) * 0.30)
                .clamp(0.0, 1.0);

            double? leftPos  = p.left  != null ? size.width  * p.left!  + dx : null;
            double? rightPos = p.right != null ? size.width  * p.right! - dx : null;
            final   topPos   = size.height * p.top + dy;

            return Positioned(
              top:   topPos,
              left:  leftPos,
              right: rightPos,
              child: Opacity(
                opacity: op,
                child: Container(
                  width:  p.r * 2,
                  height: p.r * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: p.color,
                    boxShadow: [
                      BoxShadow(
                        color: p.color.withOpacity(0.7),
                        blurRadius: p.r * 3,
                        spreadRadius: p.r * 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── Logo section ──────────────────────────────────────────────────────────

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterCtrl, _pulseCtrl]),
      builder: (_, __) {
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow halo
              Opacity(
                opacity: (_logoGlow.value * 0.5).clamp(0, 1),
                child: Transform.scale(
                  scale: _pulse.value * 1.1,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _primary.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Ring 3 — outermost dashed ring
              Opacity(
                opacity: _ring3Opacity.value,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _DashedRingPainter(
                    color: _secondary.withOpacity(0.35),
                    strokeWidth: 1.0,
                    dashCount: 24,
                  ),
                ),
              ),

              // Ring 2 — animated sweep
              CustomPaint(
                size: const Size(172, 172),
                painter: _SweepRingPainter(
                  progress: _ring2Sweep.value,
                  color: _accent,
                  strokeWidth: 2.0,
                  reverse: true,
                ),
              ),

              // Ring 1 — main animated sweep
              CustomPaint(
                size: const Size(148, 148),
                painter: _SweepRingPainter(
                  progress: _ring1Sweep.value,
                  color: _primary,
                  strokeWidth: 3.5,
                ),
              ),

              // Pulsing center logo container
              Transform.scale(
                scale: _logoScale.value,
                child: Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A3FA0), Color(0xFF1A1F5A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: _primary.withOpacity(0.55),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.55),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: _secondary.withOpacity(0.25),
                            blurRadius: 50,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Orbiting dot
              AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, __) {
                  final angle = _particleCtrl.value * 2 * math.pi;
                  final x = math.cos(angle) * 86.0;
                  final y = math.sin(angle) * 86.0;
                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Opacity(
                      opacity: _ring1Sweep.value.clamp(0, 1),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primary,
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.9),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Orbiting dot 2 (opposite)
              AnimatedBuilder(
                animation: _particleCtrl,
                builder: (_, __) {
                  final angle = _particleCtrl.value * 2 * math.pi + math.pi;
                  final x = math.cos(angle) * 86.0;
                  final y = math.sin(angle) * 86.0;
                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Opacity(
                      opacity: _ring2Sweep.value.clamp(0, 1),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _secondary,
                          boxShadow: [
                            BoxShadow(
                              color: _secondary.withOpacity(0.9),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Text section ──────────────────────────────────────────────────────────

  Widget _buildTextSection() {
    return AnimatedBuilder(
      animation: _masterCtrl,
      builder: (_, __) => Column(
        children: [
          // App name with shimmer
          SlideTransition(
            position: _titleSlide,
            child: Opacity(
              opacity: _titleOpacity.value,
              child: AnimatedBuilder(
                animation: _shimmerCtrl,
                builder: (_, __) => ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      Colors.white,
                      Color(0xFF4361EE),
                      Colors.white,
                      Color(0xFF4CC9F0),
                      Colors.white,
                    ],
                    stops: [
                      (_shimmer.value - 0.4).clamp(0, 1),
                      (_shimmer.value - 0.2).clamp(0, 1),
                      _shimmer.value.clamp(0, 1),
                      (_shimmer.value + 0.2).clamp(0, 1),
                      (_shimmer.value + 0.4).clamp(0, 1),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    'Vital Metrics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          SlideTransition(
            position: _subtitleSlide,
            child: Opacity(
              opacity: _subtitleOpacity.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, _primary],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Track · Optimize · Thrive',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 28,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_secondary, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress section ──────────────────────────────────────────────────────

  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _masterCtrl,
      builder: (_, __) => Opacity(
        opacity: _barOpacity.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            children: [
              // Progress bar
              LayoutBuilder(
                builder: (_, constraints) {
                  final maxW = constraints.maxWidth;
                  return Stack(
                    children: [
                      // Track
                      Container(
                        height: 3,
                        width: maxW,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Fill
                      Container(
                        height: 3,
                        width: maxW * _barWidth.value,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: const LinearGradient(
                            colors: [_primary, _secondary],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primary.withOpacity(0.6),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              // Loading text
              Text(
                _barWidth.value < 0.4
                    ? 'Initializing...'
                    : _barWidth.value < 0.75
                        ? 'Loading your data...'
                        : 'Almost ready...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _P {
  final double top;
  final double? left;
  final double? right;
  final double r;
  final double speed;
  final Color color;
  const _P({
    required this.top,
    this.left,
    this.right,
    required this.r,
    required this.speed,
    required this.color,
  });
}

// ── Custom Painters ───────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;
    const gap = 36.0;
    for (double x = 0; x < size.width;  x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _SweepRingPainter extends CustomPainter {
  final double progress;
  final Color  color;
  final double strokeWidth;
  final bool   reverse;

  const _SweepRingPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 2,
    this.reverse = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Track
    final trackPaint = Paint()
      ..color  = color.withOpacity(0.12)
      ..style  = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Arc
    final arcPaint = Paint()
      ..color  = color
      ..style  = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round;

    final startAngle = reverse
        ? -math.pi / 2 + (1 - progress) * 2 * math.pi
        : -math.pi / 2;
    final sweepAngle = progress * 2 * math.pi * (reverse ? -1 : 1);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_SweepRingPainter old) =>
      old.progress != progress;
}

class _DashedRingPainter extends CustomPainter {
  final Color  color;
  final double strokeWidth;
  final int    dashCount;

  const _DashedRingPainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashCount   = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final paint  = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round;

    final step = 2 * math.pi / dashCount;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * step;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        step * 0.45,
        false,
        paint,
      );
    }
  }

  @override bool shouldRepaint(_) => false;
}