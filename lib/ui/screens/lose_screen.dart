import 'package:flutter/material.dart';

class LoseScreen extends StatelessWidget {
  final String gender;
  final double height;
  final double weight;
  final int age;
  final String goal;

  const LoseScreen({
    super.key,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('lose screen')),
      body: Center(
        child: Text(
          'Gender: $gender\nHeight: $height\nWeight: $weight\nAge: $age\nGoal: $goal',
        ),
      ),
    );
  }
}
