import 'package:flutter/material.dart';
import 'onboarding_thankyou.dart'; 

class OnboardingAge extends StatefulWidget {
  final String gender;
  final double height;
  final double weight;

  const OnboardingAge({
    super.key,
    required this.gender,
    required this.height,
    required this.weight,
  });

  @override
  State<OnboardingAge> createState() => _OnboardingAgeState();
}

class _OnboardingAgeState extends State<OnboardingAge> {
  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  double _age = 25.0;
  final int minAge = 10;
  final int maxAge = 100;

  @override
  Widget build(BuildContext context) {
    final bool isMale = widget.gender.toLowerCase() == 'male';
    final Color accent = isMale ? primaryBlue : femalePink;

    final imagePath =
        isMale ? 'assets/images/male.png' : 'assets/images/female.png';

    final mq = MediaQuery.of(context);
    final previewW = mq.size.width * 0.92;
    final previewH = mq.size.height * 0.48;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: accent,
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: 0.9,
                    minHeight: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0),
              child: Center(
                child: Text(
                  'How old are you?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Center(
                child: Text(
                  'Use the slider to pick your age',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(
                      width: previewW,
                      height: previewH,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: -0.05,
                            child: Container(
                              width: previewW * 0.86,
                              height: previewH * 0.86,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          Container(
                            width: previewW * 0.86,
                            height: previewH * 0.92,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  isMale ? Icons.man : Icons.woman,
                                  size: 160,
                                  color: accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),
                    Text(
                      '${_age.toInt()} years',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Slider(
                        value: _age.clamp(
                          minAge.toDouble(),
                          maxAge.toDouble(),
                        ),
                        min: minAge.toDouble(),
                        max: maxAge.toDouble(),
                        divisions: maxAge - minAge,
                        activeColor: accent,
                        inactiveColor: accent.withOpacity(0.3),
                        onChanged: (v) => setState(() => _age = v),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingThankYou(
                          gender: widget.gender,
                          height: widget.height,
                          weight: widget.weight,
                          age: _age.toInt(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
