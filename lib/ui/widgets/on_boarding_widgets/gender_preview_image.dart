import 'package:flutter/material.dart';
import 'package:vital_metrics/core/constants/app_assets.dart';
import 'package:vital_metrics/core/constants/app_constants.dart';

class GenderPreview extends StatelessWidget {
  final String? gender;
  final double width;
  final double height;

  const GenderPreview({
    super.key,
    required this.gender,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: AppConstants.animationNormal),
      child: gender == null
          ? const SizedBox()
          : SizedBox(
              key: ValueKey(gender),
              width: width,
              height: height,
              child: Image.asset(
                AppAssets.getGenderImage(gender!),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    gender == 'male' ? Icons.man : Icons.woman,
                    size: 160,
                    color: Colors.grey,
                  );
                },
              ),
            ),
    );
  }
}