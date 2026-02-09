import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vital_metrics/logic/onboarding/gender_cubit.dart';
import 'package:vital_metrics/logic/onboarding/gender_state.dart';
import 'onboarding_height.dart';

class OnboardingGender extends StatefulWidget {
  const OnboardingGender({super.key});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _handleAnim;

  static const double controlWidth = 340;
  static const double controlHeight = 86;
  static const double handlePadding = 6;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _handleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final previewW = mq.size.width * 0.78;
    final previewH = mq.size.height * 0.40;

    return BlocProvider(
      create: (_) => GenderCubit(animCtrl: _animCtrl),
      child: BlocBuilder<GenderCubit, GenderState>(
        builder: (context, state) {
          final cubit = context.read<GenderCubit>();

          return Scaffold(
            backgroundColor: Colors.white,

            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: 0.20,
                    minHeight: 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(state.accent),
                  ),
                ),
              ),
            ),

            body: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'What is your gender?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0),
                    child: Center(
                      child: Text(
                        'Pick your gender',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity == null) return;
                      details.primaryVelocity! < 0
                          ? cubit.selectGender('female')
                          : cubit.selectGender('male');
                    },
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          width: controlWidth,
                          height: controlHeight,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(
                              controlHeight / 2,
                            ),
                          ),
                        ),

                        AnimatedBuilder(
                          animation: _handleAnim,
                          builder: (_, child) {
                            final t = _handleAnim.value;
                            final left =
                                handlePadding +
                                t * (controlWidth / 2 - handlePadding * 2);

                            return Positioned(
                              left: left,
                              top: handlePadding,
                              child: child!,
                            );
                          },
                          child: Container(
                            width: controlWidth / 2 - handlePadding * 2,
                            height: controlHeight - handlePadding * 2,
                            decoration: BoxDecoration(
                              color: state.accent,
                              borderRadius: BorderRadius.circular(
                                (controlHeight - handlePadding * 2) / 2,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: controlWidth,
                          height: controlHeight,
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => cubit.selectGender('male'),
                                  child: const Center(
                                    child: Text(
                                      'Male',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => cubit.selectGender('female'),
                                  child: const Center(
                                    child: Text(
                                      'Female',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: state.selectedGender == null
                          ? const SizedBox()
                          : Container(
                              key: ValueKey(state.selectedGender),
                              width: previewW,
                              height: previewH,
                              child: Image.asset(
                                state.selectedGender == 'male'
                                    ? 'assets/images/male.png'
                                    : 'assets/images/female.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                  ),

                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.selectedGender == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Onboarding2(
                                      gender: state.selectedGender!,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.accent,
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
