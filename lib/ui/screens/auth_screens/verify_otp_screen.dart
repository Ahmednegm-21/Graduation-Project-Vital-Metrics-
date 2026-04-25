import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/forget_password_cubit.dart';
import 'package:vital_metrics/logic/auth/forget_password_state.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

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

  void _onDigitChanged(int index, String val) {
    if (val.isNotEmpty && index < 4) {
      // Move focus to next box
      _focusNodes[index + 1].requestFocus();
    }

    // Auto-verify when last digit is entered
    if (index == 4 && val.isNotEmpty) {
      FocusScope.of(context).unfocus();
      context.read<ForgotPasswordCubit>().verifyOtp(
            email: widget.email,
            otp: _otp,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordOtpVerified) {
            context.push('/set-new-password', extra: {
              'email': widget.email,
              'otp': _otp,
            });
          } else if (state is ForgotPasswordError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ForgotPasswordLoading;
          final otpError  = state is ForgotPasswordValidationError
              ? state.otpError
              : null;

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: AppDecorations.authGradientBackground,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.paddingXXL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppConstants.spaceL),
                    _BackButton(),
                    SizedBox(height: AppConstants.spaceXXXL),

                    Text('Check your\nemail', style: AppTextStyles.authTitle),
                    SizedBox(height: AppConstants.spaceS),

                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.authSubtitle,
                        children: [
                          const TextSpan(text: 'We sent a reset link to '),
                          TextSpan(
                            text: widget.email,
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '\nEnter the 5-digit code mentioned in the email',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceXXXL + 8.h),

                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (i) => _OtpBox(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          hasError: otpError != null,
                          isLoading: isLoading,
                          onChanged: (val) => _onDigitChanged(i, val),
                          onBackspace: () {
                            if (i > 0) _focusNodes[i - 1].requestFocus();
                          },
                        ),
                      ),
                    ),

                    // OTP error
                    if (otpError != null) ...[
                      SizedBox(height: AppConstants.spaceS),
                      Row(children: [
                        Icon(Icons.error_outline,
                            color: AppColors.error,
                            size: AppConstants.iconXS),
                        SizedBox(width: AppConstants.spaceXS),
                        Text(otpError,
                            style: TextStyle(
                                color: AppColors.error, fontSize: 12.sp)),
                      ]),
                    ],

                    SizedBox(height: AppConstants.spaceXXXL),

                    // Manual verify button (fallback if auto didn't trigger)
                    CustomButton(
                      text: 'Verify Code',
                      isLoading: isLoading,
                      onPressed: () =>
                          context.read<ForgotPasswordCubit>().verifyOtp(
                                email: widget.email,
                                otp: _otp,
                              ),
                    ),
                    SizedBox(height: AppConstants.spaceXXL),

                    // Resend email
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.authText,
                          children: [
                            const TextSpan(text: "Haven't got the email yet?  "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<ForgotPasswordCubit>()
                                    .sendResetEmail(email: widget.email),
                                child: Text(
                                  'Resend email',
                                  style: AppTextStyles.authLink,
                                ),
                              ),
                            ),
                          ],
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

// ── Single OTP digit box ──────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.isLoading,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52.w,
      height: 58.h,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          enabled: !isLoading,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            color: isLoading ? AppColors.white70 : AppColors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: false,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.error
                    : isLoading
                        ? AppColors.primaryLight
                        : AppColors.white70,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primaryLight,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(
                color: AppColors.primaryLight.withOpacity(0.6),
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          padding: EdgeInsets.all(AppConstants.paddingS),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white70),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: AppConstants.iconS,
          ),
        ),
      ),
    );
  }
}


