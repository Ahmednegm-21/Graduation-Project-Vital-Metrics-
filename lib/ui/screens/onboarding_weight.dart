import 'package:flutter/material.dart';
import 'onboarding_age.dart';

class OnboardingWeight extends StatefulWidget {
  final String gender;
  final int? height;

  const OnboardingWeight({
    super.key,
    required this.gender,
    this.height,
  });

  @override
  State<OnboardingWeight> createState() => _OnboardingWeightState();
}

class _OnboardingWeightState extends State<OnboardingWeight> {
  double selectedWeight = 70.0;

  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  @override
  Widget build(BuildContext context) {
    final bool isMale = widget.gender.toLowerCase() == 'male';
    final Color accent = isMale ? primaryBlue : femalePink;

    final imagePath =
        isMale ? 'assets/images/male.png' : 'assets/images/female.png';

    final mq = MediaQuery.of(context);
    final previewW = mq.size.width * 0.92;
    final previewH = mq.size.height * 0.46;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                    value: 0.6,
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
                  'What is your weight?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 6,
                  ),
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
                                width: previewW * 0.9,
                                height: previewH * 0.88,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                            ),
                            Container(
                              width: previewW * 0.9,
                              height: previewH * 0.94,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${selectedWeight.toInt()} kg',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: accent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('30 kg',
                                    style: TextStyle(color: Colors.grey)),
                                Text('150 kg',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Slider(
                              value: selectedWeight,
                              min: 30,
                              max: 150,
                              divisions: 120,
                              activeColor: accent,
                              inactiveColor: accent.withOpacity(0.3),
                              onChanged: (v) =>
                                  setState(() => selectedWeight = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OnboardingAge(
                        gender: widget.gender,
                        height: widget.height?.toDouble() ?? 0.0,
                        weight: selectedWeight,
                      ),
                    ),
                  ),
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
