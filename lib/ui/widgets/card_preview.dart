import 'package:flutter/material.dart';

class ProfilePreviewCard extends StatelessWidget {
  final Color accent;
  final String imagePath;
  final IconData fallbackIcon;

  const ProfilePreviewCard({
    super.key,
    required this.accent,
    required this.imagePath,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width * 0.92;
    final h = mq.size.height * 0.48;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.05,
            child: Container(
              width: w * 0.86,
              height: h * 0.86,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          Container(
            width: w * 0.86,
            height: h * 0.92,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(fallbackIcon, size: 160, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
