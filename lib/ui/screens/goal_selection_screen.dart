import 'package:flutter/material.dart';

class GoalSelectionScreen extends StatelessWidget {
  final String gender;
  final double height;
  final double weight;
  final int age;

  const GoalSelectionScreen({
    Key? key,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
  }) : super(key: key);

  static const Color primaryBlue = Color(0xFF005EBD);
  static const Color femalePink = Color(0xFFFF7EB9);

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: 0.85,
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
              const SizedBox(height: 40),
              const Text(
                'What is your main\ngoal?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 100),
              GoalButton(
                icon: Icons.fitness_center,
                title: 'Gain Weight',
                subtitle: 'Increase Body Weight',
                backgroundColor: const Color(0xFF6BA5B0),
                onTap: () {
                  _navigateToNextScreen(context, 'gain');
                },
              ),
              const SizedBox(height: 130),
              GoalButton(
                icon: Icons.trending_down,
                title: 'Lose Weight',
                subtitle: 'Burn Fat and tone down',
                backgroundColor: const Color(0xFF2C4A5C),
                onTap: () {
                  _navigateToNextScreen(context, 'lose');
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNextScreen(BuildContext context, String goal) {
    print('Selected goal: $goal');
    print('Gender: $gender, Height: $height, Weight: $weight, Age: $age');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextScreen(
          gender: gender,
          height: height,
          weight: weight,
          age: age,
          goal: goal,
        ),
      ),
    );
  }
}

class GoalButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  const GoalButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(34),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NextScreen extends StatelessWidget {
  final String gender;
  final double height;
  final double weight;
  final int age;
  final String goal;

  const NextScreen({
    Key? key,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.goal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Next Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Gender: $gender'),
            Text('Height: $height cm'),
            Text('Weight: $weight kg'),
            Text('Age: $age years'),
            Text('Goal: $goal'),
          ],
        ),
      ),
    );
  }
}
