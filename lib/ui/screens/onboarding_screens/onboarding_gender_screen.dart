import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_assets.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/constants/onboarding_config.dart';
import 'package:vital_metrics/logic/onboarding/gender_cubit.dart';
import 'package:vital_metrics/logic/onboarding/gender_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';

// Total steps: gender → height → weight → age → thank-you
const int _kTotalSteps = 5;
const int _kThisStep = 1;

// Original accent system restored: male = blue, female = pink.
// The header bar and Continue button always match whichever gender
// is currently selected (default tint = male blue before any pick).
const Color _kMaleColor = Color(0xFF4A6CF7);
const Color _kFemaleColor = Color(0xFFFF5D9E);
const Color _kInk = Color(0xFF1E2125);
const Color _kMuted = Color(0xFF8B9099);
const Color _kSurface = Color(0xFFF7F8F6);
const Color _kCardBorder = Color(0xFFE7E9E4);

// ─── Screen ─────────────────────────────────────────────────────────────────

class OnboardingGender extends StatefulWidget {
  const OnboardingGender({super.key});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender>
    with TickerProviderStateMixin {
  late final AnimationController _animCtrl; // drives GenderCubit's own state
  late final AnimationController _entryCtrl; // page entrance choreography
  late final AnimationController _bgCtrl; // ambient background drift

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppConstants.animationNormal),
    );
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GenderCubit(animCtrl: _animCtrl),
      child: BlocBuilder<GenderCubit, GenderState>(
        builder: (context, state) {
          final cubit = context.read<GenderCubit>();
          final hasSelection = state.selectedGender != null;

          // header bar + Continue button always match the selected gender
          final Color accent = state.selectedGender == 'female'
              ? _kFemaleColor
              : _kMaleColor;

          return Scaffold(
            backgroundColor: _kSurface,
            body: Stack(
              children: [
                // ── ambient drifting color blobs (subtle, behind content) ──
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _bgCtrl,
                    builder: (_, __) {
                      final drift = _bgCtrl.value;
                      return IgnorePointer(
                        child: Stack(
                          children: [
                            Positioned(
                              top: -60.h + drift * 30,
                              right: -50.w - drift * 20,
                              child: Container(
                                width: 220.w,
                                height: 220.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.withOpacity(0.06),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 80.h - drift * 25,
                              left: -70.w + drift * 15,
                              child: Container(
                                width: 180.w,
                                height: 180.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      (state.selectedGender == 'female'
                                              ? _kMaleColor
                                              : _kFemaleColor)
                                          .withOpacity(0.05),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _StepHeader(
                        key: ValueKey(accent.value),
                        accent: accent,
                        progressValue: OnboardingConfig.getProgressValue(
                          'gender',
                        ),
                        stepLabel: '$_kThisStep / $_kTotalSteps',
                        eyebrow: 'YOUR PROFILE',
                        title: "What's your gender?",
                        subtitle:
                            'We use this to personalise your daily targets',
                      ),
                    ),

                    // ── Cards ─────────────────────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _GenderCard(
                                label: 'Male',
                                imagePath: AppAssets.getGenderImage('male'),
                                isSelected: state.selectedGender == 'male',
                                accent: _kMaleColor,
                                imageAlignment: const Alignment(0, -0.35),
                                entryDelay: 0.0,
                                entryCtrl: _entryCtrl,
                                onTap: () {
                                  cubit.selectGender('male');
                                  context
                                      .read<OnboardingCubitAllData>()
                                      .setGender('male');
                                },
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: _GenderCard(
                                label: 'Female',
                                imagePath: AppAssets.getGenderImage('female'),
                                isSelected: state.selectedGender == 'female',
                                accent: _kFemaleColor,
                                // ▼ pulled up so the head shows instead of
                                // just the neck/shoulders being framed
                                imageAlignment: const Alignment(0, -0.28),
                                entryDelay: 0.14,
                                entryCtrl: _entryCtrl,
                                onTap: () {
                                  cubit.selectGender('female');
                                  context
                                      .read<OnboardingCubitAllData>()
                                      .setGender('female');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Continue button ───────────────────────────────────
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
                      child: _ContinueButton(
                        accent: accent,
                        enabled: hasSelection,
                        onPressed: () {
                          context.read<OnboardingCubitAllData>().setGender(
                            state.selectedGender!,
                          );
                          context.push('/height');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Gender Card: photo-led, with richer selection choreography ───────────

class _GenderCard extends StatefulWidget {
  const _GenderCard({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.accent,
    required this.imageAlignment,
    required this.entryDelay,
    required this.entryCtrl,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final Color accent;
  final Alignment imageAlignment;
  final double entryDelay;
  final AnimationController entryCtrl;
  final VoidCallback onTap;

  @override
  State<_GenderCard> createState() => _GenderCardState();
}

class _GenderCardState extends State<_GenderCard>
    with TickerProviderStateMixin {
  late AnimationController _idleCtrl; // ambient breathing/glow
  late AnimationController _selectCtrl; // pop + ring sweep on selection
  double _tapScale = 1.0;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _selectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isSelected) _selectCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant _GenderCard old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _selectCtrl.forward(from: 0);
    } else if (!widget.isSelected && old.isSelected) {
      _selectCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _selectCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([widget.entryCtrl, _idleCtrl, _selectCtrl]),
      builder: (_, __) {
        final entryT = CurvedAnimation(
          parent: widget.entryCtrl,
          curve: Interval(
            widget.entryDelay,
            (widget.entryDelay + 0.7).clamp(0.0, 1.0),
            curve: Curves.easeOutBack,
          ),
        ).value;
        // separate, non-overshooting curve dedicated to opacity — easeOutBack
        // overshoots past 1.0 by design (that's what gives the little bounce),
        // which is fine for position/scale but illegal for Opacity.
        final entryFade = CurvedAnimation(
          parent: widget.entryCtrl,
          curve: Interval(
            widget.entryDelay,
            (widget.entryDelay + 0.7).clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ).value.clamp(0.0, 1.0);

        final idleBob = widget.isSelected
            ? math.sin(_idleCtrl.value * math.pi) * 4
            : 0.0;
        final selectPop = Curves.easeOutBack.transform(
          _selectCtrl.value.clamp(0.0, 1.0),
        );
        // dedicated, non-overshooting fade for anything using Opacity —
        // selectPop is for scale/size only (overshoot there is fine and
        // gives the little bounce; it is NOT safe to feed into Opacity).
        final selectFade = _selectCtrl.value.clamp(0.0, 1.0);
        final ringSweep = Curves.easeOut.transform(_selectCtrl.value);

        return Transform.translate(
          offset: Offset(0, (1 - entryFade) * 28 + idleBob),
          child: Transform.scale(
            scale: 0.9 + entryT * 0.1,
            child: Opacity(
              opacity: entryFade,
              child: GestureDetector(
                onTapDown: (_) => setState(() => _tapScale = 0.96),
                onTapUp: (_) => setState(() => _tapScale = 1.0),
                onTapCancel: () => setState(() => _tapScale = 1.0),
                onTap: widget.onTap,
                child: AnimatedScale(
                  scale: _tapScale,
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    height: 0.42.sh,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      border: Border.all(
                        color: widget.isSelected ? widget.accent : _kCardBorder,
                        width: widget.isSelected ? 2.4 : 1.4,
                      ),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: widget.accent.withOpacity(0.24),
                                blurRadius: 26,
                                offset: const Offset(0, 12),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26.r),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ── Photo medallion with sweeping ring ────
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  width: 132.w,
                                  height: 132.h,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // sweeping selection ring (draws on)
                                      if (widget.isSelected)
                                        SizedBox(
                                          width: 132.w,
                                          height: 132.h,
                                          child: CustomPaint(
                                            painter: _RingSweepPainter(
                                              progress: ringSweep,
                                              color: widget.accent,
                                            ),
                                          ),
                                        ),
                                      // soft glow pulse behind photo
                                      if (widget.isSelected)
                                        Container(
                                          width:
                                              112.w *
                                              (1.0 + _idleCtrl.value * 0.05),
                                          height:
                                              112.h *
                                              (1.0 + _idleCtrl.value * 0.05),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                widget.accent.withOpacity(
                                                  0.18 - _idleCtrl.value * 0.08,
                                                ),
                                                widget.accent.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 280,
                                        ),
                                        width:
                                            (widget.isSelected ? 116 : 100).w *
                                            (1.0 + selectPop * 0.04),
                                        height:
                                            (widget.isSelected ? 116 : 100).h *
                                            (1.0 + selectPop * 0.04),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _kSurface,
                                          border: Border.all(
                                            color: widget.isSelected
                                                ? widget.accent.withOpacity(0.5)
                                                : _kCardBorder,
                                            width: 2,
                                          ),
                                        ),
                                        padding: EdgeInsets.all(8.w),
                                        child: ClipOval(
                                          child: Image.asset(
                                            widget.imagePath,
                                            fit: BoxFit.cover,
                                            alignment: widget.imageAlignment,
                                            errorBuilder: (_, __, ___) => Icon(
                                              widget.label == 'Male'
                                                  ? Icons.man_rounded
                                                  : Icons.woman_rounded,
                                              size: 48.sp,
                                              color: widget.isSelected
                                                  ? widget.accent
                                                  : _kMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // check badge, elastic pop
                                      if (widget.isSelected)
                                        Positioned(
                                          bottom: 2.h,
                                          right: 2.w,
                                          child: Transform.scale(
                                            scale: selectPop,
                                            child: Container(
                                              width: 28.w,
                                              height: 28.h,
                                              decoration: BoxDecoration(
                                                color: widget.accent,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: widget.accent
                                                        .withOpacity(0.4),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 15.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 14.h),

                            // ── Label ─────────────────────────────────
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w700,
                                color: widget.isSelected ? _kInk : _kMuted,
                              ),
                              child: Text(widget.label),
                            ),

                            SizedBox(height: 10.h),

                            // ── Selection indicator pill ──────────────
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 28.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? widget.accent
                                    : _kSurface,
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: widget.isSelected
                                      ? widget.accent
                                      : _kCardBorder,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: widget.isSelected
                                  ? Opacity(
                                      opacity: selectFade,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.check_rounded,
                                            size: 14.sp,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Selected',
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      'Tap to select',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                        color: _kMuted.withOpacity(0.8),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Sweeping ring painter: draws an arc around the medallion on select ────

class _RingSweepPainter extends CustomPainter {
  _RingSweepPainter({required this.progress, required this.color});

  final double progress; // 0..1
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingSweepPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ─── Continue button ─────────────────────────────────────────────────────────

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({
    required this.accent,
    required this.enabled,
    required this.onPressed,
  });

  final Color accent;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  double _tapScale = 1.0;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (_, __) {
        final glow = widget.enabled ? _glowCtrl.value : 0.0;
        return GestureDetector(
          onTapDown: widget.enabled
              ? (_) => setState(() => _tapScale = 0.96)
              : null,
          onTapUp: widget.enabled
              ? (_) => setState(() => _tapScale = 1.0)
              : null,
          onTapCancel: widget.enabled
              ? () => setState(() => _tapScale = 1.0)
              : null,
          onTap: widget.enabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: _tapScale,
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                decoration: BoxDecoration(
                  gradient: widget.enabled
                      ? LinearGradient(
                          colors: [
                            widget.accent,
                            widget.accent.withOpacity(0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.enabled ? null : const Color(0xFFE3E6E1),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: widget.enabled
                      ? [
                          BoxShadow(
                            color: widget.accent.withOpacity(
                              0.30 + glow * 0.16,
                            ),
                            blurRadius: 16 + glow * 10,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
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
                        color: widget.enabled ? Colors.white : _kMuted,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20.sp,
                      color: widget.enabled ? Colors.white : _kMuted,
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

// ─── Shared Header — bar color matches selected gender's accent ───────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    super.key,
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
                    // ▼ FIX: this is the FIRST onboarding step, so "back"
                    // should explicitly return to sign-up — not just pop,
                    // which can be unreliable depending on how the user
                    // arrived here (e.g. context.go from elsewhere would
                    // leave nothing to pop).
                    onTap: () => context.go('/signup'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
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
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progressValue),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (_, animatedValue, __) => AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          child: LinearProgressIndicator(
                            value: animatedValue,
                            minHeight: 6.h,
                            backgroundColor: accent.withOpacity(0.15),
                            // ▼ matches Continue button color exactly
                            valueColor: AlwaysStoppedAnimation(accent),
                          ),
                        ),
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
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: accent,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
                child: Text(eyebrow),
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  color: _kInk,
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(color: _kMuted, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
