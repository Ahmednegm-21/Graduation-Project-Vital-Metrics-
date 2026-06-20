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
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_state.dart';
import 'package:vital_metrics/logic/onboarding/age_cubit.dart';
import 'package:vital_metrics/logic/onboarding/age_state.dart';

// Total steps: gender → height → weight → age → thank-you
const int _kTotalSteps = 5;
const int _kThisStep = 4;

// ─── Shared onboarding palette (matches height/weight/age/thank-you) ──────
const Color _kBg = Color(0xFFFAF9FF);
const Color _kInk = Color(0xFF231F3D);
const Color _kMuted = Color(0xFF9B96B8);
const Color _kMutedLight = Color(0xFFAFA9C4);
const Color _kDisabled = Color(0xFFE3DEF5);

// ─── Accent colors — same blue/pink pair as the gender screen, fixed ──────
// (header bar + Continue button always match these, exactly like gender)
const Color _kMaleColor = Color(0xFF4A6CF7);
const Color _kFemaleColor = Color(0xFFFF5D9E);

// ─── Shared avatar sizing (matches height/weight/age) ─────────────────────
// White circle frame stays at its original size — only the image inside
// it grows, by shrinking the padding around it.
const double _kAvatarBoxSize = 230.0; // outer SizedBox (w/h)
const double _kAvatarBaseSize = 220.0; // circle base diameter (was 194)
const double _kAvatarImagePadding = 10.5; // was 18 — bigger image, same circle

class OnboardingAge extends StatelessWidget {
  const OnboardingAge({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AgeCubit(),
      child: const _OnboardingAgeView(),
    );
  }
}

class _OnboardingAgeView extends StatefulWidget {
  const _OnboardingAgeView();

  @override
  State<_OnboardingAgeView> createState() => _OnboardingAgeViewState();
}

class _OnboardingAgeViewState extends State<_OnboardingAgeView>
    with TickerProviderStateMixin {
  final TextEditingController _ageController = TextEditingController();
  late AnimationController _idleCtrl;
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _idleCtrl.dispose();
    _entryCtrl.dispose();
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
    final gender =
        context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';
    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = isMale ? _kMaleColor : _kFemaleColor;
    final imagePath = AppAssets.getGenderImage(gender);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthRegistrationSuccess) {
              context.push('/verify-signup-otp', extra: state.email);
            } else if (state is AuthError) {
              _showError(state.message);
            }
          },
        ),
        BlocListener<OnboardingCubitAllData, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingError) {
              _showError(state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<AgeCubit, AgeState>(
        builder: (context, state) {
          if (!_ageController.value.composing.isValid) {
            _ageController.text = state.age.toInt().toString();
          }

          final isLoading =
              context.watch<OnboardingCubitAllData>().state
                  is OnboardingLoading ||
              context.watch<AuthCubit>().state is AuthLoading;

          return Scaffold(
            backgroundColor: _kBg,
            body: Column(
              children: [
                _StepHeader(
                  accent: accent,
                  progressValue: OnboardingConfig.getProgressValue('age'),
                  stepLabel: '$_kThisStep / $_kTotalSteps',
                  eyebrow: 'YOUR PROFILE',
                  title: 'How old\nare you?',
                  subtitle: 'This helps us tailor your health benchmarks',
                ),

                Expanded(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entryCtrl,
                      curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        child: Column(
                          children: [
                            // ── Avatar with idle float ───────────────────
                            AnimatedBuilder(
                              animation: Listenable.merge([
                                _idleCtrl,
                                _entryCtrl,
                              ]),
                              builder: (_, __) {
                                final idleBob =
                                    math.sin(_idleCtrl.value * math.pi) * 7;
                                final ringPulse = _idleCtrl.value;
                                final baseSize = _kAvatarBaseSize;
                                final entryScale = Curves.easeOutBack.transform(
                                  CurvedAnimation(
                                    parent: _entryCtrl,
                                    curve: const Interval(0.0, 0.75),
                                  ).value,
                                );

                                return Transform.translate(
                                  offset: Offset(0, idleBob),
                                  child: Transform.scale(
                                    scale: entryScale,
                                    child: SizedBox(
                                      width: _kAvatarBoxSize.w,
                                      height: _kAvatarBoxSize.h,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width:
                                                baseSize.w *
                                                (1.05 + ringPulse * 0.10),
                                            height:
                                                baseSize.h *
                                                (1.05 + ringPulse * 0.10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: RadialGradient(
                                                colors: [
                                                  accent.withOpacity(
                                                    0.16 - ringPulse * 0.07,
                                                  ),
                                                  accent.withOpacity(0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: baseSize.w,
                                            height: baseSize.h,
                                            // ▼ FIX: clip the child to the
                                            // circle shape — without this the
                                            // image can paint past the round
                                            // border once it's no longer
                                            // shrunk down to fit inside it.
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              border: Border.all(
                                                color: accent.withOpacity(0.35),
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accent.withOpacity(
                                                    0.22,
                                                  ),
                                                  blurRadius: 22,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            padding: EdgeInsets.all(
                                              _kAvatarImagePadding.w,
                                            ),
                                            child: ClipOval(
                                              // ▼ FIX: BoxFit.cover so the
                                              // image fills the circle edge
                                              // to edge instead of shrinking
                                              // down to fit inside it.
                                              child: Image.asset(
                                                imagePath,
                                                fit: BoxFit.cover,
                                                alignment: isMale
                                                    ? const Alignment(0, -0.55)
                                                    : const Alignment(0, -0.46),
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                      isMale
                                                          ? Icons.man
                                                          : Icons.woman,
                                                      size: 72.sp,
                                                      color: accent,
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

                            SizedBox(height: 20.h),

                            Text(
                              'What is your birth date?',
                              style: AppTextStyles.h3,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'Pick your age or your birth date',
                              style: AppTextStyles.subtitle2,
                            ),

                            SizedBox(height: 28.h),

                            // ── Animated age counter ─────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _StepperButton(
                                  icon: Icons.remove_rounded,
                                  accent: accent,
                                  onTap: () {
                                    final newAge = (state.age - 1).clamp(
                                      OnboardingConfig.ageConfig['min']!,
                                      OnboardingConfig.ageConfig['max']!,
                                    );
                                    context.read<AgeCubit>().updateAge(newAge);
                                  },
                                ),
                                SizedBox(width: 18.w),
                                SizedBox(
                                  width: 110.w,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 240),
                                    switchInCurve: Curves.easeOutBack,
                                    switchOutCurve: Curves.easeIn,
                                    transitionBuilder: (child, anim) {
                                      return ScaleTransition(
                                        scale: anim,
                                        child: FadeTransition(
                                          opacity: anim,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      state.age.toInt().toString(),
                                      key: ValueKey(state.age.toInt()),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 52.sp,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 18.w),
                                _StepperButton(
                                  icon: Icons.add_rounded,
                                  accent: accent,
                                  onTap: () {
                                    final newAge = (state.age + 1).clamp(
                                      OnboardingConfig.ageConfig['min']!,
                                      OnboardingConfig.ageConfig['max']!,
                                    );
                                    context.read<AgeCubit>().updateAge(newAge);
                                  },
                                ),
                              ],
                            ),
                            Text(
                              'years old',
                              style: AppTextStyles.caption.copyWith(
                                color: _kMutedLight,
                                letterSpacing: 0.5,
                              ),
                            ),

                            SizedBox(height: 24.h),

                            // ── Slider ───────────────────────────────────
                            Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 6.h,
                                    thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 11.r,
                                      elevation: 3,
                                    ),
                                    overlayShape: RoundSliderOverlayShape(
                                      overlayRadius: 20.r,
                                    ),
                                    activeTrackColor: accent,
                                    inactiveTrackColor: accent.withOpacity(
                                      0.15,
                                    ),
                                    thumbColor: accent,
                                  ),
                                  child: Slider(
                                    value: state.age.clamp(
                                      OnboardingConfig.ageConfig['min']!,
                                      OnboardingConfig.ageConfig['max']!,
                                    ),
                                    min: OnboardingConfig.ageConfig['min']!,
                                    max: OnboardingConfig.ageConfig['max']!,
                                    divisions: OnboardingConfig.ageDivisions,
                                    onChanged: (v) =>
                                        context.read<AgeCubit>().updateAge(v),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${OnboardingConfig.ageConfig['min']!.toInt()} yrs',
                                        style: AppTextStyles.caption.copyWith(
                                          color: _kMutedLight,
                                        ),
                                      ),
                                      Text(
                                        '${OnboardingConfig.ageConfig['max']!.toInt()} yrs',
                                        style: AppTextStyles.caption.copyWith(
                                          color: _kMutedLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            // ── Birth-date picker button ─────────────────
                            GestureDetector(
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().subtract(
                                    Duration(days: 365 * state.age.toInt()),
                                  ),
                                  firstDate: DateTime(1920),
                                  lastDate: DateTime.now(),
                                  builder: (ctx, child) => Theme(
                                    data: Theme.of(ctx).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: accent,
                                      ),
                                    ),
                                    child: child!,
                                  ),
                                );
                                if (pickedDate != null) {
                                  final today = DateTime.now();
                                  int calculatedAge =
                                      today.year - pickedDate.year;
                                  if (today.month < pickedDate.month ||
                                      (today.month == pickedDate.month &&
                                          today.day < pickedDate.day)) {
                                    calculatedAge--;
                                  }
                                  // ignore: use_build_context_synchronously
                                  context.read<AgeCubit>().updateAge(
                                    calculatedAge.toDouble(),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  vertical: 14.h,
                                  horizontal: 16.w,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: const Color(0xFFE3DEF5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 18.sp,
                                      color: accent,
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'Pick birth date instead',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Next button → save age + register user (→ OTP) ──────
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
                  child: _ContinueButton(
                    accent: accent,
                    enabled: !isLoading,
                    isLoading: isLoading,
                    onPressed: () {
                      context.read<OnboardingCubitAllData>().setAge(state.age);
                      context.read<OnboardingCubitAllData>().registerUser(
                        context.read<AuthCubit>(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Shared Header ───────────────────────────────────────────────────────────

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
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progressValue),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        builder: (_, animatedValue, __) =>
                            LinearProgressIndicator(
                              value: animatedValue,
                              minHeight: 6.h,
                              backgroundColor: accent.withOpacity(0.15),
                              // ▼ matches Continue button color exactly
                              valueColor: AlwaysStoppedAnimation(accent),
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
                style: TextStyle(color: _kMuted, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stepper button (+ / -) with tap-scale feedback ─────────────────────────

class _StepperButton extends StatefulWidget {
  const _StepperButton({
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.86),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: widget.accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: widget.accent, size: 22.sp),
        ),
      ),
    );
  }
}

// ─── Continue button (supports a loading spinner state) ────────────────────

class _ContinueButton extends StatefulWidget {
  const _ContinueButton({
    required this.accent,
    required this.enabled,
    required this.onPressed,
    this.isLoading = false,
  });

  final Color accent;
  final bool enabled;
  final bool isLoading;
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
              child: Container(
                decoration: BoxDecoration(
                  color: widget.enabled ? widget.accent : _kDisabled,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: widget.enabled
                      ? [
                          BoxShadow(
                            color: widget.accent.withOpacity(
                              0.32 + glow * 0.16,
                            ),
                            blurRadius: 16 + glow * 10,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 16.sp,
                              letterSpacing: 0.3,
                              color: widget.enabled
                                  ? Colors.white
                                  : _kMutedLight,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20.sp,
                            color: widget.enabled ? Colors.white : _kMutedLight,
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
