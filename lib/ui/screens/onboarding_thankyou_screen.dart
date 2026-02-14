import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';

class OnboardingThankYou extends StatelessWidget {
  const OnboardingThankYou({super.key});

  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  @override
  Widget build(BuildContext context) {
    //Take from gender OnboardingCubitAllData
    final gender = context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';
    
    final mq = MediaQuery.of(context);
    final imageH = mq.size.height * 0.28;

    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = isMale ? primaryBlue : femalePink;

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
              onPressed: () => context.pop(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: 1.0,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              SizedBox(
                height: imageH,
                child: Image.asset(
                  'assets/images/thanks.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.verified_user,
                    size: imageH * 0.7,
                    color: accent,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              const Text(
                'Thank you for\ntrusting us!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Your privacy and security matter to us.\n'
                'We promise to always keep your personal information\n'
                'private and secure.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<OnboardingCubitAllData>().saveOnboardingData();
                    context.push('/goal-selection');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}