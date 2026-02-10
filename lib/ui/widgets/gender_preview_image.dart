import 'package:flutter/material.dart';
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
      duration: const Duration(milliseconds: 260),
      child: gender == null
          ? const SizedBox()
          : SizedBox(
              key: ValueKey(gender),
              width: width,
              height: height,
              child: Image.asset(
                gender == 'male'
                    ? 'assets/images/male.png'
                    : 'assets/images/female.png',
                fit: BoxFit.contain,
              ),
            ),
    );
  }
}
