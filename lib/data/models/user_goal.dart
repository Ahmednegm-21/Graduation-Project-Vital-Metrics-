enum GoalType {
  gainWeight,
  loseWeight,
}

class UserGoal {
  final GoalType type;
  final String title;
  final String description;
  final String imagePath;

  UserGoal({
    required this.type,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'goal': type == GoalType.gainWeight ? 'gain_weight' : 'lose_weight',
    };
  }

  // Static goals list
  static List<UserGoal> get allGoals => [
        UserGoal(
          type: GoalType.gainWeight,
          title: 'Gain Weight',
          description:
              'Gaining weight specifically through building muscle and strength improves wellness, boosts energy, regulates hormones.',
          imagePath: 'assets/images/gain_image.jpg',
        ),
        UserGoal(
          type: GoalType.loseWeight,
          title: 'Lose Weight',
          description:
              'Losing weight is one of the most common health goals, as it increases disease prevention, improves mobility and energy, and enhances mental and emotional wellness.',
          imagePath: 'assets/images/lose_image.jpg',
        ),
      ];
}