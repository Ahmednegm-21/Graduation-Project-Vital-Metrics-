import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/constants/app_assets.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';

// Total steps: gender → height → weight → age → thank-you
const int _kTotalSteps = 5;
const int _kThisStep = 5;

// ─── Shared onboarding palette (matches height/weight/age/thank-you) ──────
const Color _kBg = Color(0xFFFAF9FF);
const Color _kInk = Color(0xFF231F3D);
const Color _kMuted = Color(0xFF9B96B8);

// ─── Accent colors — same blue/pink pair as the gender screen, fixed ──────
// (header bar + Continue button always match these, exactly like gender)
const Color _kMaleColor = Color(0xFF4A6CF7);
const Color _kFemaleColor = Color(0xFFFF5D9E);

// ─── Shared avatar sizing ───────────────────────────────────────────────
// White badge circle stays at its original size — only the image inside
// it grows, by shrinking the padding around it.
const double _kBadgeSize = 146.0; // was 130
const double _kBadgeImagePadding = 12.0; // was 26 — bigger image, same circle

class OnboardingThankYou extends StatefulWidget {
  const OnboardingThankYou({super.key});

  @override
  State<OnboardingThankYou> createState() => _OnboardingThankYouState();
}

class _OnboardingThankYouState extends State<OnboardingThankYou>
    with TickerProviderStateMixin {
  // Entrance choreography
  late AnimationController _entranceCtrl;
  late Animation<double> _badgeScale;
  late Animation<double> _badgeRotation;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _bodyFade;
  late Animation<Offset> _bodySlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  // Idle ambient animations
  late AnimationController _idleCtrl; // gentle bob + ring pulse
  late AnimationController _confettiCtrl; // one-shot confetti burst

  late final List<_ConfettiPiece> _confetti;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _badgeScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(
      CurvedAnimation(
          parent: _entranceCtrl, curve: const Interval(0.0, 0.55)),
    );

    _badgeRotation = Tween<double>(begin: -0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_titleFade);

    _bodyFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
    );
    _bodySlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(_bodyFade);

    _buttonFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(_buttonFade);

    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final rnd = math.Random(7);
    _confetti = List.generate(18, (i) {
      return _ConfettiPiece(
        angle: rnd.nextDouble() * 2 * math.pi,
        distance: 90 + rnd.nextDouble() * 90,
        size: 5 + rnd.nextDouble() * 5,
        delay: rnd.nextDouble() * 0.3,
        spin: (rnd.nextBool() ? 1 : -1) * (2 + rnd.nextDouble() * 3),
      );
    });

    _entranceCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _confettiCtrl.forward();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _idleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gender =
        context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';
    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = isMale ? _kMaleColor : _kFemaleColor;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header: progress bar color == Continue button color ──────
          _StepHeader(
            accent: accent,
            progressValue: 1.0,
            stepLabel: '$_kThisStep / $_kTotalSteps',
            eyebrow: "YOU'RE ALL SET",
            title: 'Profile\ncomplete!',
            subtitle: 'One last thing before you get started',
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingXXL.w),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Badge + confetti + idle pulse ──────────────────
                    SizedBox(
                      height: 0.26.sh,
                      width: double.infinity,
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_entranceCtrl, _idleCtrl, _confettiCtrl]),
                        builder: (_, __) {
                          final idleBob =
                              math.sin(_idleCtrl.value * math.pi) * 6;
                          final ringPulse = _idleCtrl.value;

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // confetti burst
                              ..._confetti.map((piece) {
                                final raw = (_confettiCtrl.value - piece.delay)
                                    .clamp(0.0, 1.0);
                                final progress =
                                    Curves.easeOutCubic.transform(raw);
                                final dx = math.cos(piece.angle) *
                                    piece.distance *
                                    progress;
                                final dy = math.sin(piece.angle) *
                                        piece.distance *
                                        progress -
                                    20 * progress; // slight upward arc
                                final opacity =
                                    (1.0 - progress).clamp(0.0, 1.0);
                                return Positioned(
                                  left: 0.5.sw - 28.w + dx,
                                  top: (0.26.sh) / 2 + dy,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Transform.rotate(
                                      angle: progress *
                                          piece.spin *
                                          math.pi,
                                      child: Container(
                                        width: piece.size,
                                        height: piece.size,
                                        decoration: BoxDecoration(
                                          color: [
                                            accent,
                                            AppColors.getGenderColor(
                                                gender == 'male'
                                                    ? 'female'
                                                    : 'male'),
                                            accent.withOpacity(0.6),
                                          ][piece.size.toInt() % 3],
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // pulsing ring behind the badge
                              Transform.translate(
                                offset: Offset(0, idleBob),
                                child: Container(
                                  width: _kBadgeSize.w *
                                      (1.0 + ringPulse * 0.12),
                                  height: _kBadgeSize.w *
                                      (1.0 + ringPulse * 0.12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent.withOpacity(
                                        0.14 - ringPulse * 0.08),
                                  ),
                                ),
                              ),

                              // badge / illustration with entrance pop
                              Transform.translate(
                                offset: Offset(0, idleBob),
                                child: Transform.rotate(
                                  angle: _badgeRotation.value,
                                  child: Transform.scale(
                                    scale: _badgeScale.value,
                                    child: Container(
                                      width: _kBadgeSize.w,
                                      height: _kBadgeSize.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: accent.withOpacity(0.3),
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accent.withOpacity(0.25),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(
                                          _kBadgeImagePadding.w),
                                      child: Image.asset(
                                        AppAssets.thanksImage,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.verified_rounded,
                                          size: 56.sp,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const Spacer(flex: 1),

                    // ── Title (slide + fade in) ─────────────────────────
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'Thank you for\ntrusting us!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h2,
                        ),
                      ),
                    ),

                    SizedBox(height: AppConstants.spaceL.h),

                    // ── Body copy (slide + fade in, slightly later) ─────
                    FadeTransition(
                      opacity: _bodyFade,
                      child: SlideTransition(
                        position: _bodySlide,
                        child: Text(
                          'Your privacy and security matter to us.\n'
                          'We promise to always keep your personal information\n'
                          'private and secure.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Continue button (slide + fade in last) ──────────
                    FadeTransition(
                      opacity: _buttonFade,
                      child: SlideTransition(
                        position: _buttonSlide,
                        child: _PulsingButton(
                          accent: accent,
                          onPressed: () {
                            context.push('/goal-selection');
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: AppConstants.paddingXXL.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Confetti piece data ──────────────────────────────────────────────────

class _ConfettiPiece {
  _ConfettiPiece({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.spin,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final double spin;
}

// ─── Continue button with a subtle breathing glow ───────────────────────────

class _PulsingButton extends StatefulWidget {
  const _PulsingButton({required this.accent, required this.onPressed});

  final Color accent;
  final VoidCallback onPressed;

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  double _tapScale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final glow = _ctrl.value;
        return GestureDetector(
          onTapDown: (_) => setState(() => _tapScale = 0.96),
          onTapUp: (_) => setState(() => _tapScale = 1.0),
          onTapCancel: () => setState(() => _tapScale = 1.0),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _tapScale,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: widget.accent,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.accent.withOpacity(0.35 + glow * 0.15),
                    blurRadius: 18 + glow * 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 16.sp,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward_rounded,
                      size: 20.sp, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Shared Header (same pattern as gender/height/weight/age) ───────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.accent,
    required this.progressValue,
    required this.stepLabel,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final Color accent;
  final double progressValue;
  final String stepLabel;
  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36.w,
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: accent,
                        size: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 6.h,
                        backgroundColor: accent.withOpacity(0.15),
                        // ▼ matches Continue button color exactly
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    stepLabel,
                    style: TextStyle(
                      color: _kMuted,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                eyebrow,
                style: TextStyle(
                  color: accent.withOpacity(0.75),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  color: _kInk,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: _kMuted,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}