// lib/ui/screens/auth_screens/sign_in_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/services/device_token_manager.dart';
import 'package:vital_metrics/ui/widgets/custom_auth/custom_text_field.dart';
import 'package:vital_metrics/ui/widgets/custom_auth/social_auth_button.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {

  // ── Text Controllers ───────────────────────────────────────────────────────
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  // ── Animation Controllers ──────────────────────────────────────────────────
  late final AnimationController _masterCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _floatCtrl;

  // ── Animations ─────────────────────────────────────────────────────────────
  late final Animation<double> _bgGlow;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset>  _titleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset>  _subtitleSlide;
  late final Animation<double> _dividerWidth;
  late final Animation<double> _field1Opacity;
  late final Animation<Offset>  _field1Slide;
  late final Animation<double> _field2Opacity;
  late final Animation<Offset>  _field2Slide;
  late final Animation<double> _forgotOpacity;
  late final Animation<double> _btnOpacity;
  late final Animation<double> _btnScale;
  late final Animation<double> _bottomOpacity;
  late final Animation<Offset>  _bottomSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _shimmer;
  late final Animation<double> _float;

  // ── Colors (matching splash) ───────────────────────────────────────────────
  static const _primary   = Color(0xFF4361EE);
  static const _secondary = Color(0xFF4CC9F0);
  static const _accent    = Color(0xFF7B5EA7);
  static const _bgDark    = Color(0xFF050816);

  @override
  void initState() {
    super.initState();

    // ── Master (1.8s entrance) ────────────────────────────────────────────
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // ── Particles ─────────────────────────────────────────────────────────
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    // ── Pulse ─────────────────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // ── Shimmer ───────────────────────────────────────────────────────────
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    // ── Float (logo levitation) ───────────────────────────────────────────
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    // ── BG Glow ───────────────────────────────────────────────────────────
    _bgGlow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // ── Logo ──────────────────────────────────────────────────────────────
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );
    _logoSlide = Tween(begin: -40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.30, curve: Curves.easeOutCubic),
      ),
    );

    // ── Title ─────────────────────────────────────────────────────────────
    _titleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.18, 0.40, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.18, 0.42, curve: Curves.easeOutCubic),
      ),
    );

    // ── Subtitle ──────────────────────────────────────────────────────────
    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.25, 0.45, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.25, 0.47, curve: Curves.easeOutCubic),
      ),
    );

    // ── Divider line ──────────────────────────────────────────────────────
    _dividerWidth = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.32, 0.52, curve: Curves.easeOutCubic),
      ),
    );

    // ── Fields ────────────────────────────────────────────────────────────
    _field1Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.38, 0.58, curve: Curves.easeOut),
      ),
    );
    _field1Slide = Tween(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.38, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _field2Opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.46, 0.65, curve: Curves.easeOut),
      ),
    );
    _field2Slide = Tween(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.46, 0.67, curve: Curves.easeOutCubic),
      ),
    );

    // ── Forgot ────────────────────────────────────────────────────────────
    _forgotOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.54, 0.70, curve: Curves.easeOut),
      ),
    );

    // ── Button ────────────────────────────────────────────────────────────
    _btnOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.60, 0.78, curve: Curves.easeOut),
      ),
    );
    _btnScale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.60, 0.80, curve: Curves.elasticOut),
      ),
    );

    // ── Bottom (signup + social) ──────────────────────────────────────────
    _bottomOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.72, 0.90, curve: Curves.easeOut),
      ),
    );
    _bottomSlide = Tween(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.72, 0.92, curve: Curves.easeOutCubic),
      ),
    );

    // ── Infinite ──────────────────────────────────────────────────────────
    _pulse = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _shimmer = Tween(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );
    _float = Tween(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _masterCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppConstants.paddingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) async {
          if (state is AuthAdminSuccess) {
            await DeviceTokenManager.instance.registerAfterLogin();
            context.go('/admin-panel');
          } else if (state is AuthSuccess) {
            await DeviceTokenManager.instance.registerAfterLogin();
            context.go('/home');
          } else if (state is AuthSignInOTPSent) {
            context.push('/verify-signin-otp', extra: state.email);
          } else if (state is AuthError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final isSuccess = state is AuthSuccess;
          final emailError = state is AuthValidationError ? state.emailError : null;
          final passwordError = state is AuthValidationError ? state.passwordError : null;

          return Stack(
            children: [
              // ── Background ───────────────────────────────────────────────
              _buildBackground(),

              // ── Particles ────────────────────────────────────────────────
              _buildParticles(),

              // ── Main content ─────────────────────────────────────────────
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height
                          - MediaQuery.of(context).padding.top
                          - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 36.h),

                          // ── Logo ─────────────────────────────────────────
                          _buildLogo(),

                          SizedBox(height: 32.h),

                          // ── Title ────────────────────────────────────────
                          _buildTitle(),

                          SizedBox(height: 36.h),

                          // ── Card with fields ─────────────────────────────
                          _buildFormCard(
                            isLoading: isLoading,
                            isSuccess: isSuccess,
                            emailError: emailError,
                            passwordError: passwordError,
                          ),

                          SizedBox(height: 28.h),

                          // ── Bottom section ───────────────────────────────
                          _buildBottom(),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Background ─────────────────────────────────────────────────────────────

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _masterCtrl,
      builder: (_, __) => Stack(
        children: [
          // Top-left nebula
          Positioned(
            top: -80,
            left: -60,
            child: Opacity(
              opacity: (_bgGlow.value * 0.7).clamp(0, 1),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _secondary.withOpacity(0.22),
                      _accent.withOpacity(0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Bottom-right nebula
          Positioned(
            bottom: -100,
            right: -80,
            child: Opacity(
              opacity: (_bgGlow.value * 0.6).clamp(0, 1),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primary.withOpacity(0.18),
                      _secondary.withOpacity(0.07),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Center mid glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -40,
            child: Opacity(
              opacity: (_bgGlow.value * 0.3).clamp(0, 1),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accent.withOpacity(0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Grid
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
        ],
      ),
    );
  }

  // ── Particles ──────────────────────────────────────────────────────────────

  Widget _buildParticles() {
    final particles = [
      _P(top: 0.06, left: 0.05,  r: 2.5, speed: 1.0, color: _secondary),
      _P(top: 0.12, right: 0.08, r: 2.0, speed: 0.7, color: _primary),
      _P(top: 0.22, left: 0.90,  r: 3.0, speed: 1.3, color: _accent),
      _P(top: 0.70, right: 0.06, r: 2.5, speed: 0.9, color: _secondary),
      _P(top: 0.82, left: 0.04,  r: 1.5, speed: 1.5, color: _primary),
      _P(top: 0.60, right: 0.92, r: 3.5, speed: 0.6, color: _accent),
      _P(top: 0.40, left: 0.95,  r: 2.0, speed: 1.1, color: _secondary),
      _P(top: 0.92, left: 0.75,  r: 2.0, speed: 0.8, color: _primary),
    ];

    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        return Stack(
          children: particles.map((p) {
            final t  = _particleCtrl.value;
            final dy = math.sin(t * 2 * math.pi * p.speed) * 10.0;
            final dx = math.cos(t * 2 * math.pi * p.speed) * 7.0;
            final op = (0.15 + math.sin(t * 2 * math.pi * p.speed) * 0.28)
                .clamp(0.0, 1.0);

            double? leftPos  = p.left  != null ? size.width  * p.left!  + dx : null;
            double? rightPos = p.right != null ? size.width  * p.right! - dx : null;
            final   topPos   = size.height * p.top + dy;

            return Positioned(
              top: topPos, left: leftPos, right: rightPos,
              child: Opacity(
                opacity: op,
                child: Container(
                  width: p.r * 2, height: p.r * 2,
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

  // ── Logo ───────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterCtrl, _pulseCtrl, _floatCtrl]),
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _logoSlide.value + _float.value),
        child: Opacity(
          opacity: _logoOpacity.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  Transform.scale(
                    scale: _pulse.value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _secondary.withOpacity(0.18),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Dashed ring
                  CustomPaint(
                    size: const Size(145, 145),
                    painter: _DashedRingPainter(
                      color: _primary.withOpacity(0.30),
                      strokeWidth: 1.0,
                      dashCount: 20,
                    ),
                  ),
                  // Logo container
                  Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A3A6A), Color(0xFF0D1A3A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _secondary.withOpacity(0.50),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _secondary.withOpacity(0.40),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: _primary.withOpacity(0.20),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/icons/vital_metrics_logo_transparent.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
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

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterCtrl, _shimmerCtrl]),
      builder: (_, __) => Column(
        children: [
          // App name shimmer
          SlideTransition(
            position: _titleSlide,
            child: Opacity(
              opacity: _titleOpacity.value,
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Colors.white,
                    Color(0xFF4CC9F0),
                    Colors.white,
                    Color(0xFF4361EE),
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
                child: Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // Animated divider lines
          SlideTransition(
            position: _subtitleSlide,
            child: Opacity(
              opacity: _subtitleOpacity.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left line
                  AnimatedBuilder(
                    animation: _masterCtrl,
                    builder: (_, __) => Container(
                      width: 40 * _dividerWidth.value,
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, _secondary],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.8,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // Right line
                  AnimatedBuilder(
                    animation: _masterCtrl,
                    builder: (_, __) => Container(
                      width: 40 * _dividerWidth.value,
                      height: 1.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primary, Colors.transparent],
                        ),
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

  // ── Form Card ──────────────────────────────────────────────────────────────

  Widget _buildFormCard({
    required bool isLoading,
    required bool isSuccess,
    String? emailError,
    String? passwordError,
  }) {
    return AnimatedBuilder(
      animation: _masterCtrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.06),
              Colors.white.withOpacity(0.02),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _secondary.withOpacity(0.08),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── Email field ─────────────────────────────────────────
                SlideTransition(
                  position: _field1Slide,
                  child: FadeTransition(
                    opacity: _field1Opacity,
                    child: CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                      isSuccess: isSuccess,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // ── Password field ──────────────────────────────────────
                SlideTransition(
                  position: _field2Slide,
                  child: FadeTransition(
                    opacity: _field2Opacity,
                    child: CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      errorText: passwordError,
                      isSuccess: isSuccess,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // ── Forgot password ─────────────────────────────────────
                FadeTransition(
                  opacity: _forgotOpacity,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _secondary.withOpacity(0.25),
                            width: 1,
                          ),
                          color: _secondary.withOpacity(0.06),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: _primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Sign in button ──────────────────────────────────────
                Transform.scale(
                  scale: _btnScale.value,
                  child: FadeTransition(
                    opacity: _btnOpacity,
                    child: _buildSignInButton(isLoading),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign in button ─────────────────────────────────────────────────────────

  Widget _buildSignInButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () => context.read<AuthCubit>().signIn(
                email: _emailController.text,
                password: _passwordController.text,
              ),
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Container(
          height: 54.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF4CC9F0), Color(0xFF4361EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _secondary.withOpacity(0.40 + _pulse.value * 0.05),
                blurRadius: 18 + _pulse.value * 4,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: _primary.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white.withOpacity(0.9),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ── Bottom section ─────────────────────────────────────────────────────────

  Widget _buildBottom() {
    return SlideTransition(
      position: _bottomSlide,
      child: FadeTransition(
        opacity: _bottomOpacity,
        child: Column(
          children: [
            // Sign up row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?  ",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/signup'),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_secondary, _primary],
                    ).createShader(bounds),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 28.h),

            // Divider with OR
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.12),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Google button
            Center(
              child: SocialAuthButton(
                imagePath: 'google',
                onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

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

// ── Custom Painters ────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.022)
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