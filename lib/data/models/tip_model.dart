// lib/data/models/tip_model.dart

enum TipCategory {
  health    ('💚', 'Health'),
  nutrition ('🥗', 'Nutrition'),
  sleep     ('🌙', 'Sleep'),
  exercise  ('🏃', 'Exercise'),
  water     ('💧', 'Water');

  final String emoji, label;
  const TipCategory(this.emoji, this.label);

  static TipCategory fromString(String v) {
    switch (v.toLowerCase()) {
      case 'nutrition':
      case 'meal':       return TipCategory.nutrition;
      case 'sleep':      return TipCategory.sleep;
      case 'exercise':
      case 'activity':   return TipCategory.exercise;
      case 'water':      return TipCategory.water;
      default:           return TipCategory.health;
    }
  }
}

class TipModel {
  final int         id;
  final String      title;
  final String      body;
  final TipCategory category;
  final String?     source; // e.g. "WHO", "Harvard Health"

  const TipModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.source,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) => TipModel(
        id:       (json['id'] as num?)?.toInt() ?? 0,
        title:    json['title']    as String? ?? '',
        body:     json['body']     as String? ?? '',
        category: TipCategory.fromString(json['category'] as String? ?? ''),
        source:   json['source']   as String?,
      );
}

// ── Local fallback tips (مبنية على بيانات اليوزر) ──────────────────────────

List<TipModel> localTips({
  double waterGoalL    = 2.5,
  int    caloriesBudget = 2000,
  double sleepHours    = 7.0,
  int    steps         = 0,
}) {
  return [
    // ── Water ──────────────────────────────────────────────────────────────
    TipModel(
      id: 101, category: TipCategory.water,
      title: 'Stay Hydrated 💧',
      body: 'Your daily water goal is ${waterGoalL.toStringAsFixed(1)}L. '
            'Drinking water before meals can reduce calorie intake by up to 13%.',
      source: 'Journal of Clinical Endocrinology',
    ),
    TipModel(
      id: 102, category: TipCategory.water,
      title: 'Morning Hydration',
      body: 'Drink a glass of water right after waking up. '
            'Your body loses ~500ml overnight through breathing alone.',
      source: 'Harvard Health',
    ),

    // ── Nutrition ──────────────────────────────────────────────────────────
    TipModel(
      id: 201, category: TipCategory.nutrition,
      title: 'Calorie Awareness 🔥',
      body: 'Your daily budget is $caloriesBudget kcal. '
            'Eating slowly gives your brain 20 minutes to register fullness — '
            'this alone can cut 10–15% of your intake.',
      source: 'American Journal of Clinical Nutrition',
    ),
    TipModel(
      id: 202, category: TipCategory.nutrition,
      title: 'Protein First 🥩',
      body: 'Start each meal with the protein on your plate. '
            'Protein keeps you full longer and boosts metabolism by 15–30%.',
      source: 'Nutrition & Metabolism',
    ),
    TipModel(
      id: 203, category: TipCategory.nutrition,
      title: 'Rainbow Your Plate 🌈',
      body: 'Aim for 5 different colored vegetables daily. '
            'Each color provides unique antioxidants your body needs.',
      source: 'WHO',
    ),

    // ── Sleep ──────────────────────────────────────────────────────────────
    TipModel(
      id: 301, category: TipCategory.sleep,
      title: sleepHours < 7 ? 'You Need More Sleep 😴' : 'Great Sleep Habits 🌙',
      body: sleepHours < 7
          ? 'You logged ${sleepHours.toStringAsFixed(1)}h last night. '
            'Less than 7h increases hunger hormones (ghrelin) by 15% '
            'and makes it harder to lose weight.'
          : 'You logged ${sleepHours.toStringAsFixed(1)}h — right in the sweet spot. '
            'Quality sleep regulates leptin and ghrelin, keeping cravings in check.',
      source: 'Sleep Foundation',
    ),
    TipModel(
      id: 302, category: TipCategory.sleep,
      title: 'Wind Down Routine',
      body: 'Dim your lights and avoid screens 1 hour before bed. '
            'Blue light suppresses melatonin by up to 50%, delaying sleep onset.',
      source: 'Harvard Medical School',
    ),

    // ── Exercise ───────────────────────────────────────────────────────────
    TipModel(
      id: 401, category: TipCategory.exercise,
      title: steps < 5000 ? 'Get Moving! 🚶' : 'Keep It Up! 🏃',
      body: steps < 5000
          ? 'You\'ve done $steps steps today. '
            'Just 30 min of walking burns ~150 kcal and improves insulin sensitivity.'
          : 'Great work on your steps! '
            'Adding strength training 2x/week boosts resting metabolism for 48h after.',
      source: 'American Heart Association',
    ),
    TipModel(
      id: 402, category: TipCategory.exercise,
      title: 'Post-Workout Nutrition',
      body: 'Eat 20–40g of protein within 45 minutes after exercise '
            'to maximize muscle repair and growth.',
      source: 'Journal of the International Society of Sports Nutrition',
    ),

    // ── Health ─────────────────────────────────────────────────────────────
    TipModel(
      id: 501, category: TipCategory.health,
      title: 'Small Wins Matter 🎯',
      body: 'Research shows tracking your food daily increases weight loss '
            'success by 2x compared to those who don\'t track.',
      source: 'American Journal of Preventive Medicine',
    ),
    TipModel(
      id: 502, category: TipCategory.health,
      title: 'Stress & Weight',
      body: 'Chronic stress raises cortisol, which increases fat storage — '
            'especially around the belly. '
            'Try 5 minutes of deep breathing daily.',
      source: 'Psychoneuroendocrinology',
    ),
    TipModel(
      id: 503, category: TipCategory.health,
      title: 'Consistency Beats Perfection',
      body: 'Missing one day doesn\'t ruin your progress. '
            'What matters is your average over the week, not a single day.',
      source: 'Behavior Research and Therapy',
    ),
  ];
}