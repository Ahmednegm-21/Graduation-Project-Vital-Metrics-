// onboarding_gender.dart
import 'package:flutter/material.dart';
import 'onboarding_height.dart';

class OnboardingGender extends StatefulWidget {
  const OnboardingGender({super.key});

  @override
  State<OnboardingGender> createState() => _OnboardingGenderState();
}

class _OnboardingGenderState extends State<OnboardingGender>
    with SingleTickerProviderStateMixin {
  String? _selectedGender; // 'male' or 'female'

  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  late final AnimationController _animCtrl;
  late final Animation<double> _handleAnim;

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

  void _selectGender(String g) {
    if (g == _selectedGender) return;
    setState(() {
      _selectedGender = g;
      g == 'female' ? _animCtrl.forward() : _animCtrl.reverse();
    });
  }

  void _goNext() {
    if (_selectedGender == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Onboarding2(gender: _selectedGender!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final previewW = mq.size.width * 0.78;
    final previewH = mq.size.height * 0.40;

    final bool isMale = _selectedGender != 'female';
    final Color accent = _selectedGender == null
        ? primaryBlue
        : (isMale ? primaryBlue : femalePink);

    const double controlWidth = 340;
    const double controlHeight = 86;
    const double handlePadding = 6;

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
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
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
                  'What is your gender?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// Gender switch
            Center(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  details.primaryVelocity! < 0
                      ? _selectGender('female')
                      : _selectGender('male');
                },
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      width: controlWidth,
                      height: controlHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(controlHeight / 2),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _handleAnim,
                      builder: (context, child) {
                        final t = _handleAnim.value;
                        final left = 4 + t * (controlWidth / 2 - 8);
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
                          color: accent,
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
                          _GenderSide(
                            label: 'Male',
                            selected: _selectedGender == 'male',
                            color: primaryBlue,
                            icon: Icons.man,
                            onTap: () => _selectGender('male'),
                          ),
                          _GenderSide(
                            label: 'Female',
                            selected: _selectedGender == 'female',
                            color: femalePink,
                            icon: Icons.woman,
                            onTap: () => _selectGender('female'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _selectedGender == null
                        ? SizedBox(
                            key: const ValueKey('ph'),
                            width: previewW,
                            height: previewH,
                          )
                        : _LargePreview(
                            selected: _selectedGender!,
                            primaryBlue: primaryBlue,
                            femalePink: femalePink,
                            width: previewW,
                            height: previewH,
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 10,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedGender == null ? null : _goNext,
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

/// ===== Helper Widgets =====

class _GenderSide extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _GenderSide({
    required this.label,
    required this.selected,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: selected ? Colors.white : color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LargePreview extends StatelessWidget {
  final String selected;
  final Color primaryBlue;
  final Color femalePink;
  final double width;
  final double height;

  const _LargePreview({
    required this.selected,
    required this.primaryBlue,
    required this.femalePink,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMale = selected == 'male';
    final Color accent = isMale ? primaryBlue : femalePink;
    final asset = isMale
        ? 'assets/images/male.png'
        : 'assets/images/female.png';

    return Container(
      key: ValueKey(selected),
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.08,
            child: Container(
              width: width * 0.95,
              height: height * 0.88,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Container(
            width: width * 0.95,
            height: height * 0.96,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
