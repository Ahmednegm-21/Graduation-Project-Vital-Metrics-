import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        // width: 60,
        // height: 60,
        decoration: BoxDecoration(
          // color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _buildIcon(),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (imagePath.contains('google')) {
      return Image.asset(
        'assets/images/google_logo.png',
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.g_mobiledata, color: Colors.red, size: 32);
        },
      );
    } else if (imagePath.contains('facebook')) {
      return Image.asset(
        'assets/images/face_book_logo.png',
        width: 70,
        height: 70,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 50);
        },
      );
    }
    return const Icon(Icons.login, color: Colors.grey, size: 32);
  }
}