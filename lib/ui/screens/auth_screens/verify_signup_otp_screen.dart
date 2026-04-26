import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/auth_cubit.dart';
import 'package:vital_metrics/logic/auth/auth_state.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

class VerifySignupOtpScreen extends StatefulWidget {
  final String email;
  const VerifySignupOtpScreen({super.key, required this.email});

  @override
  State<VerifySignupOtpScreen> createState() => _VerifySignupOtpScreenState();
}

class _VerifySignupOtpScreenState extends State<VerifySignupOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _showSnack(String message, {Color color = const Color(0xFFF44336)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppConstants.paddingL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
      ),
    );
  }

  void _verify() {
    if (_otp.length < 6) {
      _showSnack('Please enter the 6-digit verification code');
      return;
    }
    context.read<AuthCubit>().verifyOTP(
          email: widget.email,
          otp: _otp,
        );
  }

  void _onDigitChanged(int index, String val) {
    if (val.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (index == 5 && val.isNotEmpty) {
      FocusScope.of(context).unfocus();
      _verify();
    }
  }

  void _showResendInfo() {
    _showSnack(
      'To get a new code, go back and sign up again',
      color: AppColors.primaryLight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthOTPVerified) {
          context.go('/goal-selection');
        } else if (state is AuthError) {
          _showSnack(state.message);
        }
      },
      child: Scaffold(
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

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

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: EdgeInsets.all(AppConstants.paddingS),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.white70),
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusM),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.white,
                              size: AppConstants.iconS,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXXXL),

                      Text('Check your\nemail', style: AppTextStyles.authTitle),
                      SizedBox(height: AppConstants.spaceS),

                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.authSubtitle,
                          children: [
                            const TextSpan(
                                text: 'We sent a verification code to '),
                            TextSpan(
                              text: widget.email,
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                              ),
                            ),
                            const TextSpan(
                              text: '\nEnter the code to complete sign up',
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXXXL + 8.h),

                      // OTP boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (i) => _OtpBox(
                            controller: _controllers[i],
                            focusNode: _focusNodes[i],
                            isLoading: isLoading,
                            onChanged: (val) => _onDigitChanged(i, val),
                            onBackspace: () {
                              if (i > 0) _focusNodes[i - 1].requestFocus();
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: AppConstants.spaceXXXL),

                      CustomButton(
                        text: 'Verify Code',
                        isLoading: isLoading,
                        onPressed: isLoading ? () {} : _verify,
                      ),

                      SizedBox(height: AppConstants.spaceXXL),

                      // Resend → shows info message instead
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.authText,
                            children: [
                              const TextSpan(text: "Haven't got the code?  "),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: _showResendInfo,
                                  child: Text(
                                    'Resend',
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
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45.w,
      height: 55.h,
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
                color: isLoading ? AppColors.primaryLight : AppColors.white70,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
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