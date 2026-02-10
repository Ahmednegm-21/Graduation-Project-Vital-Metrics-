import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_thankyou_screen.dart';
import 'package:vital_metrics/logic/onboarding/age_cubit.dart';
import 'package:vital_metrics/logic/onboarding/age_state.dart';
import 'package:intl/intl.dart';

class OnboardingAge extends StatelessWidget {
  final String gender;
  final double height;
  final double weight;

  const OnboardingAge({
    super.key,
    required this.gender,
    required this.height,
    required this.weight,
  });

  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  @override
  Widget build(BuildContext context) {
    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = isMale ? primaryBlue : femalePink;
    final imagePath = isMale
        ? 'assets/images/male.png'
        : 'assets/images/female.png';

    final mq = MediaQuery.of(context);
    final previewW = mq.size.width * 0.92;
    final previewH = mq.size.height * 0.48;

    final TextEditingController ageController = TextEditingController();

    return BlocProvider(
      create: (_) => AgeCubit(),
      child: BlocBuilder<AgeCubit, AgeState>(
        builder: (context, state) {
          ageController.text = state.age.toInt().toString();

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
                        'What is your birth date?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Center(
                      child: Text(
                        'Pick your age or your birth date',
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

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: accent,
                                onPressed: () {
                                  double newAge = (state.age - 1).clamp(
                                    10,
                                    100,
                                  );
                                  context.read<AgeCubit>().updateAge(newAge);
                                },
                              ),
                              Container(
                                width: 80,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TextField(
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (value) {
                                    double? v = double.tryParse(value);
                                    if (v != null && v >= 10 && v <= 100) {
                                      context.read<AgeCubit>().updateAge(v);
                                    } else {
                                      ageController.text = state.age
                                          .toInt()
                                          .toString();
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: accent,
                                onPressed: () {
                                  double newAge = (state.age + 1).clamp(
                                    10,
                                    100,
                                  );
                                  context.read<AgeCubit>().updateAge(newAge);
                                },
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().subtract(
                                      Duration(days: 365 * state.age.toInt()),
                                    ),
                                    firstDate: DateTime(1920),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    final today = DateTime.now();
                                    int calculatedAge =
                                        today.year - pickedDate.year;
                                    if (today.month < pickedDate.month ||
                                        (today.month == pickedDate.month &&
                                            today.day < pickedDate.day)) {
                                      calculatedAge--;
                                    }
                                    context.read<AgeCubit>().updateAge(
                                      calculatedAge.toDouble(),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Birth Date',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                            ),
                            child: Slider(
                              value: state.age.clamp(10, 100),
                              min: 10,
                              max: 100,
                              divisions: 90,
                              activeColor: accent,
                              inactiveColor: accent.withOpacity(0.3),
                              onChanged: (v) =>
                                  context.read<AgeCubit>().updateAge(v),
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
                                gender: gender,
                                height: height,
                                weight: weight,
                                age: state.age.toInt(),
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
        },
      ),
    );
  }
}
