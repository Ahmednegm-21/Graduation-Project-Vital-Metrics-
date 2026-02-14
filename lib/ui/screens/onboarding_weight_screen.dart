import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vital_metrics/logic/onboarding_data/onboarding_data_cubit.dart';
import 'package:vital_metrics/logic/onboarding/weight_cubit.dart';
import 'package:vital_metrics/logic/onboarding/weight_state.dart';

class OnboardingWeight extends StatelessWidget {
  const OnboardingWeight({super.key});

  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  @override
  Widget build(BuildContext context) {
    //Take from gender OnboardingCubitAllData
    final gender = context.read<OnboardingCubitAllData>().currentData.gender ?? 'male';
    
    final bool isMale = gender.toLowerCase() == 'male';
    final Color accent = isMale ? primaryBlue : femalePink;
    final imagePath = isMale
        ? 'assets/images/male.png'
        : 'assets/images/female.png';

    final TextEditingController weightController = TextEditingController();

    return BlocProvider(
      create: (_) => WeightCubit(),
      child: BlocBuilder<WeightCubit, WeightState>(
        builder: (context, state) {
          weightController.text = state.weight.toInt().toString();

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
                        'Choose or write your current weight',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
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
                              width: MediaQuery.of(context).size.width * 0.92,
                              height: MediaQuery.of(context).size.height * 0.46,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: -0.05,
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.9,
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.88 *
                                          0.5,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.94 *
                                        0.5,
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

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: accent,
                                  onPressed: () {
                                    double newWeight = (state.weight - 1).clamp(
                                      30,
                                      150,
                                    );
                                    context.read<WeightCubit>().updateWeight(
                                      newWeight,
                                    );
                                  },
                                ),
                                Container(
                                  width: 100,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: TextField(
                                    controller: weightController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (value) {
                                      double? v = double.tryParse(value);
                                      if (v != null && v >= 30 && v <= 150) {
                                        context
                                            .read<WeightCubit>()
                                            .updateWeight(v);
                                      } else {
                                        weightController.text = state.weight
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
                                    double newWeight = (state.weight + 1).clamp(
                                      30,
                                      150,
                                    );
                                    context.read<WeightCubit>().updateWeight(
                                      newWeight,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'kg',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6.0,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        '30 kg',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      Text(
                                        '150 kg',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Slider(
                                    value: state.weight,
                                    min: 30,
                                    max: 150,
                                    divisions: 120,
                                    activeColor: accent,
                                    inactiveColor: accent.withOpacity(0.3),
                                    onChanged: (v) => context
                                        .read<WeightCubit>()
                                        .updateWeight(v),
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
                        onPressed: () {
                          context.read<OnboardingCubitAllData>().setWeight(
                            state.weight,
                          );
                          context.push('/age');
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