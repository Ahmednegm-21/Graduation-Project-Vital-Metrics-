class HomeConfig {
  HomeConfig._();

  static const List<HomePage> pages = [
    HomePage(
      title: 'Track Your Calories',
      description:
          'Log your meals easily and stay within your daily calorie budget.',
      asset: 'assets/images/home_food.png',
      emoji: '🍽️',
    ),
    HomePage(
      title: 'Stay Hydrated',
      description:
          'Monitor your daily water intake and hit your hydration goal every day.',
      asset: 'assets/images/water_cup.png',
      emoji: '💧',
    ),
    HomePage(
      title: 'Monitor Your Progress',
      description:
          'Check your BMI, macros breakdown, and nutrition trends all in one place.',
      asset: '',
      emoji: '📊',
    ),
  ];
}

class HomePage {
  final String title;
  final String description;
  final String asset;
  final String emoji;

  const HomePage({
    required this.title,
    required this.description,
    required this.asset,
    required this.emoji,
  });
}