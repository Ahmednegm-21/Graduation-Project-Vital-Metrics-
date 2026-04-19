import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';
import 'package:vital_metrics/core/themes/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final String? errorText;
  final bool isSuccess;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.errorText,
    this.isSuccess = false,
    this.keyboardType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color borderColor;
    Color iconColor;
    
    if (widget.errorText != null) {
      // Error state
      borderColor = AppColors.error;
      iconColor = AppColors.error;
    } else if (widget.isSuccess) {
      // Success state
      borderColor = AppColors.success;
      iconColor = AppColors.success;
    } else {
      // Normal state
      borderColor = Colors.white.withOpacity(0.38);
      iconColor = Colors.white.withOpacity(0.6);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field container
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: borderColor,
              width: 1.5.w,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              filled: false,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: iconColor,
                size: AppConstants.iconM,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white.withOpacity(0.7),
                        size: AppConstants.iconM,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.isSuccess
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: AppConstants.iconM,
                        )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingL,
              ),
            ),
          ),
        ),
        
        // Error message
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(
              left: AppConstants.paddingL,
              top: AppConstants.spaceS,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: AppConstants.iconXS,
                ),
                SizedBox(width: AppConstants.spaceXS),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}