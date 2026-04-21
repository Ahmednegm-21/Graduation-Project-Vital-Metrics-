// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:vital_metrics/core/constants/app_constants.dart';
// import 'package:vital_metrics/core/styles/decorations.dart';
// import 'package:vital_metrics/core/styles/text_styles.dart';
// import 'package:vital_metrics/core/themes/app_colors.dart';
// import 'package:vital_metrics/ui/widgets/custom_auth/custom_text_field.dart';
// import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final _emailController = TextEditingController();
//   String? _emailError;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   void _onResetPressed() {
//     final email = _emailController.text.trim();

//     if (email.isEmpty) {
//       setState(() => _emailError = 'Email is required');
//       return;
//     }
//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
//       setState(() => _emailError = 'Invalid email format');
//       return;
//     }

//     setState(() => _emailError = null);

//     // connect to ForgotPasswordCubit
//     context.push('/verify-otp', extra: email);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: MediaQuery.of(context).size.height,
//         decoration: AppDecorations.authGradientBackground,
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(AppConstants.paddingXXL),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(height: AppConstants.spaceL),

//                 // Back button
//                 _BackButton(),
//                 SizedBox(height: AppConstants.spaceXXXL),

//                 // Title
//                 Text('Forgot\nPassword', style: AppTextStyles.authTitle),
//                 SizedBox(height: AppConstants.spaceS),

//                 // Subtitle
//                 Text(
//                   'Please enter your email to reset the password',
//                   style: AppTextStyles.authSubtitle,
//                 ),
//                 SizedBox(height: AppConstants.spaceXXXL + 8.h),

//                 // Email label
//                 Text(
//                   'Your Email',
//                   style: TextStyle(
//                     color: AppColors.white70,
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: AppConstants.spaceS),

//                 // Email field
//                 CustomTextField(
//                   controller: _emailController,
//                   hintText: 'Enter your email',
//                   prefixIcon: Icons.email_outlined,
//                   keyboardType: TextInputType.emailAddress,
//                   errorText: _emailError,
//                 ),
//                 SizedBox(height: AppConstants.spaceXXXL),

//                 // Reset button
//                 CustomButton(
//                   text: 'Reset Password',
//                   onPressed: _onResetPressed,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Reusable back button ──────────────────────────────────────────────────────
// class _BackButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: GestureDetector(
//         onTap: () => context.pop(),
//         child: Container(
//           padding: EdgeInsets.all(AppConstants.paddingS),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: AppColors.white70,
//             ),
//             borderRadius: BorderRadius.circular(AppConstants.radiusM),
//           ),
//           child: Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: AppColors.white,
//             size: AppConstants.iconS,
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/styles/decorations.dart';
import 'package:vital_metrics/core/styles/text_styles.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';
import 'package:vital_metrics/logic/auth/forget_password_cubit.dart';
import 'package:vital_metrics/logic/auth/forget_password_state.dart';
import 'package:vital_metrics/ui/widgets/custom_auth/custom_text_field.dart';
import 'package:vital_metrics/ui/widgets/goal_selction/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordEmailSent) {
            // Navigate to OTP screen only after API confirms email sent
            context.push('/verify-otp', extra: _emailController.text.trim());
          } else if (state is ForgotPasswordError) {
            _showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading  = state is ForgotPasswordLoading;
          final emailError = state is ForgotPasswordValidationError
              ? state.emailError
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

                    // Back button
                    _BackButton(),
                    SizedBox(height: AppConstants.spaceXXXL),

                    // Title
                    Text('Forgot\nPassword', style: AppTextStyles.authTitle),
                    SizedBox(height: AppConstants.spaceS),

                    // Subtitle
                    Text(
                      'Please enter your email to reset the password',
                      style: AppTextStyles.authSubtitle,
                    ),
                    SizedBox(height: AppConstants.spaceXXXL + 8.h),

                    // Email label
                    Text(
                      'Your Email',
                      style: TextStyle(
                        color: AppColors.white70,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppConstants.spaceS),

                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: emailError,
                    ),
                    SizedBox(height: AppConstants.spaceXXXL),

                    // Reset button
                    CustomButton(
                      text: 'Reset Password',
                      isLoading: isLoading,
                      onPressed: () =>
                          context.read<ForgotPasswordCubit>().sendResetEmail(
                                email: _emailController.text.trim(),
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