// lib/logic/tips/tips_cubit.dart

import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vital_metrics/data/models/tip_model.dart';
import 'package:vital_metrics/logic/home/calorie_cubit.dart';
import 'package:vital_metrics/logic/home/sleep_cubit.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_cubit.dart';
import 'package:vital_metrics/logic/activity/activity_state.dart';
import 'tips_state.dart';

class TipsCubit extends Cubit<TipsState> {
  final CalorieCubit  _calorieCubit;
  final WaterCubit    _waterCubit;
  final SleepCubit    _sleepCubit;
  final ActivityCubit _activityCubit;

  static const _lastIndexKey = 'last_tip_index';

  TipsCubit({
    required CalorieCubit  calorieCubit,
    required WaterCubit    waterCubit,
    required SleepCubit    sleepCubit,
    required ActivityCubit activityCubit,
  })  : _calorieCubit  = calorieCubit,
        _waterCubit    = waterCubit,
        _sleepCubit    = sleepCubit,
        _activityCubit = activityCubit,
        super(TipsInitial());

  Future<bool> shouldShowTodayTip() async => true;

  Future<void> markTipShown() async {}

  Future<void> loadTodayTip() async {
    emit(TipsLoading());
    try {
      final tip = await _buildPersonalizedTip();
      emit(TipsLoaded(tip));
    } catch (_) {
      final tip = await _buildPersonalizedTip();
      emit(TipsLoaded(tip));
    }
  }

  Future<TipModel> _buildPersonalizedTip() async {
    final calState   = _calorieCubit.state;
    final waterState = _waterCubit.state;
    final sleepState = _sleepCubit.state;

    int steps = 0;
    if (_activityCubit.state is TodayLoaded) {
      steps = (_activityCubit.state as TodayLoaded).stats.steps;
    }

    final tips = _allTips(
      waterGoalL:     waterState.goalMl / 1000.0,
      caloriesBudget: calState.caloriesBudget,
      sleepHours:     sleepState.sleepHours,
      steps:          steps,
    );

    final prefs     = await SharedPreferences.getInstance();
    final lastIndex = prefs.getInt(_lastIndexKey) ?? -1;

    final chosen = _prioritize(
      tips, calState, waterState, sleepState, steps, lastIndex,
    );

    await prefs.setInt(_lastIndexKey, tips.indexOf(chosen));
    return chosen;
  }

  TipModel _prioritize(
    List<TipModel> tips,
    CalorieState   cal,
    WaterState     water,
    SleepState     sleep,
    int            steps,
    int            lastIndex,
  ) {
    final waterPct = water.consumedMl / water.goalMl;
    final calPct   = cal.totalCaloriesConsumed / cal.caloriesBudget;

    List<TipModel> candidates = [];

    if (waterPct < 0.5) {
      candidates.addAll(tips.where((t) => t.category == TipCategory.water));
    }
    if (sleep.sleepHours < 6) {
      candidates.addAll(tips.where((t) => t.category == TipCategory.sleep));
    }
    if (steps < 3000) {
      candidates.addAll(tips.where((t) => t.category == TipCategory.exercise));
    }
    if (calPct > 1.2) {
      candidates.addAll(tips.where((t) => t.category == TipCategory.nutrition));
    }

    if (candidates.isEmpty) candidates = List.from(tips);

    final lastTip = lastIndex >= 0 && lastIndex < tips.length
        ? tips[lastIndex]
        : null;

    final filtered = lastTip != null
        ? candidates.where((t) => t.id != lastTip.id).toList()
        : candidates;

    if (filtered.isEmpty) return candidates.first;

    return filtered[Random().nextInt(filtered.length)];
  }

  List<TipModel> _allTips({
    required double waterGoalL,
    required int    caloriesBudget,
    required double sleepHours,
    required int    steps,
  }) =>
      [
        // ── Water (12 tips) ───────────────────────────────────────────────
        TipModel(
          id: 101, category: TipCategory.water,
          title: 'Start your morning with water',
          body: 'Drink a full glass of water right after waking up to kickstart '
                'your metabolism and rehydrate your body after sleep.',
          source: 'Harvard Health',
        ),
        TipModel(
          id: 102, category: TipCategory.water,
          title: 'The 8×8 rule',
          body: 'Aim for eight 8-ounce glasses of water a day — about '
                '${waterGoalL.toStringAsFixed(1)} L, your current daily goal.',
          source: 'Mayo Clinic',
        ),
        TipModel(
          id: 103, category: TipCategory.water,
          title: 'Drink before you eat',
          body: 'Having 500 ml of water 30 minutes before meals can reduce '
                'calorie intake by up to 13% and improve digestion.',
          source: 'Journal of Clinical Endocrinology',
        ),
        TipModel(
          id: 104, category: TipCategory.water,
          title: 'Herbal teas count too',
          body: 'Unsweetened herbal teas contribute to your daily fluid intake. '
                'Try chamomile or peppermint for added health benefits.',
          source: 'NHS',
        ),
        TipModel(
          id: 105, category: TipCategory.water,
          title: 'Set hydration reminders',
          body: 'If you forget to drink water, set an alarm every 2 hours. '
                'Small consistent sips beat large infrequent gulps.',
          source: 'American Heart Association',
        ),
        TipModel(
          id: 106, category: TipCategory.water,
          title: 'Check your urine color',
          body: 'Pale yellow means you\'re well-hydrated. Dark yellow is a sign '
                'you need more water — aim for lemonade color, not apple juice.',
          source: 'Cleveland Clinic',
        ),
        TipModel(
          id: 107, category: TipCategory.water,
          title: 'Eat your water too',
          body: 'Cucumbers, watermelon, and oranges are over 90% water. '
                'Adding them to meals boosts hydration without effort.',
          source: 'Healthline',
        ),
        TipModel(
          id: 108, category: TipCategory.water,
          title: 'Hydrate after exercise',
          body: 'Drink 500 ml of water for every 30 minutes of moderate exercise. '
                'Sweat loss can sneak up on you faster than thirst.',
          source: 'American College of Sports Medicine',
        ),
        TipModel(
          id: 109, category: TipCategory.water,
          title: 'Cold water burns more calories',
          body: 'Drinking cold water forces your body to warm it up, burning '
                'an extra 8–10 calories per glass — small but consistent over time.',
          source: 'Journal of Clinical Endocrinology & Metabolism',
        ),
        TipModel(
          id: 110, category: TipCategory.water,
          title: 'Sparkling water is fine too',
          body: 'Unsweetened sparkling water counts toward your hydration goal. '
                'The carbonation does not harm bones or teeth with moderate intake.',
          source: 'American Journal of Clinical Nutrition',
        ),
        TipModel(
          id: 111, category: TipCategory.water,
          title: 'Carry a water bottle everywhere',
          body: 'People who carry a reusable bottle drink 22% more water daily. '
                'Visibility is one of the strongest triggers for drinking.',
          source: 'International Journal of Environmental Research',
        ),
        TipModel(
          id: 112, category: TipCategory.water,
          title: 'Thirst means you\'re already dehydrated',
          body: 'By the time you feel thirsty, your body is already 1–2% dehydrated, '
                'which reduces concentration and physical performance noticeably.',
          source: 'British Journal of Nutrition',
        ),

        // ── Sleep (12 tips) ───────────────────────────────────────────────
        TipModel(
          id: 201, category: TipCategory.sleep,
          title: sleepHours >= 7 ? 'Great sleep habits!' : 'Aim for 7–9 hours',
          body: 'You\'re currently logging ${sleepHours.toStringAsFixed(1)} h. '
                '${sleepHours >= 7 ? "Keep it up — quality sleep regulates hunger hormones." : "Less than 7 h raises ghrelin by 15%, making weight control harder."}',
          source: 'Sleep Foundation',
        ),
        TipModel(
          id: 202, category: TipCategory.sleep,
          title: 'Keep a consistent schedule',
          body: 'Going to bed and waking up at the same time every day — '
                'even on weekends — trains your body clock for deeper sleep.',
          source: 'Harvard Medical School',
        ),
        TipModel(
          id: 203, category: TipCategory.sleep,
          title: 'Dim the lights before bed',
          body: 'Blue light from screens suppresses melatonin by up to 50%. '
                'Switch to night mode or use blue-light glasses after 9 PM.',
          source: 'Harvard Medical School',
        ),
        TipModel(
          id: 204, category: TipCategory.sleep,
          title: 'Cool your room down',
          body: 'The ideal sleep temperature is 18–20 °C. A cooler room '
                'signals your body it\'s time to sleep and deepens REM cycles.',
          source: 'Sleep Foundation',
        ),
        TipModel(
          id: 205, category: TipCategory.sleep,
          title: 'Avoid caffeine after 2 PM',
          body: 'Caffeine has a half-life of 6 hours. A coffee at 3 PM means '
                'half the caffeine is still active at 9 PM, delaying sleep.',
          source: 'Journal of Clinical Sleep Medicine',
        ),
        TipModel(
          id: 206, category: TipCategory.sleep,
          title: 'Try the 4-7-8 breathing technique',
          body: 'Inhale for 4 s, hold for 7 s, exhale for 8 s. This activates '
                'your parasympathetic system and helps you fall asleep faster.',
          source: 'Dr. Andrew Weil, Harvard',
        ),
        TipModel(
          id: 207, category: TipCategory.sleep,
          title: 'A 20-minute nap can help',
          body: 'A short power nap between 1–3 PM boosts alertness without '
                'disrupting nighttime sleep. Set an alarm so you don\'t oversleep.',
          source: 'NASA Research',
        ),
        TipModel(
          id: 208, category: TipCategory.sleep,
          title: 'Write tomorrow\'s list tonight',
          body: 'Racing thoughts keep many people awake. Jotting down your '
                'to-do list before bed offloads mental clutter and helps you relax.',
          source: 'Baylor University Study',
        ),
        TipModel(
          id: 209, category: TipCategory.sleep,
          title: 'Avoid alcohol before bed',
          body: 'Alcohol may help you fall asleep faster but it fragments REM sleep, '
                'leaving you less rested even after a full 8 hours.',
          source: 'JAMA Network',
        ),
        TipModel(
          id: 210, category: TipCategory.sleep,
          title: 'Exercise improves sleep quality',
          body: 'People who exercise regularly fall asleep 13 minutes faster and '
                'sleep 18 minutes longer. Even a 20-minute walk makes a difference.',
          source: 'Mental Health and Physical Activity Journal',
        ),
        TipModel(
          id: 211, category: TipCategory.sleep,
          title: 'Keep your bedroom for sleep only',
          body: 'Working or watching TV in bed trains your brain to associate the '
                'bedroom with wakefulness. Reserve it for sleep to reinforce the habit.',
          source: 'American Academy of Sleep Medicine',
        ),
        TipModel(
          id: 212, category: TipCategory.sleep,
          title: 'Magnesium supports deeper sleep',
          body: 'Magnesium-rich foods like almonds, spinach, and dark chocolate '
                'help regulate melatonin and improve sleep quality naturally.',
          source: 'Journal of Research in Medical Sciences',
        ),

        // ── Nutrition (12 tips) ───────────────────────────────────────────
        TipModel(
          id: 301, category: TipCategory.nutrition,
          title: 'Front-load your calories',
          body: 'Eating a larger breakfast and smaller dinner aligns with your '
                'circadian rhythm and improves metabolism throughout the day.',
          source: 'American Journal of Clinical Nutrition',
        ),
        TipModel(
          id: 302, category: TipCategory.nutrition,
          title: 'Protein at every meal',
          body: 'Including 20–30 g of protein per meal keeps you fuller longer, '
                'preserves muscle, and reduces afternoon energy crashes.',
          source: 'Nutrition & Metabolism',
        ),
        TipModel(
          id: 303, category: TipCategory.nutrition,
          title: 'Don\'t skip breakfast',
          body: 'Skipping breakfast spikes cortisol and increases cravings. '
                'Even a quick high-protein option keeps metabolism steady.',
          source: 'American Journal of Clinical Nutrition',
        ),
        TipModel(
          id: 304, category: TipCategory.nutrition,
          title: 'Eat slowly — take 20 minutes',
          body: 'It takes 20 minutes for your stomach to signal fullness to '
                'your brain. Eating slowly can reduce total intake by up to 20%.',
          source: 'American Journal of Clinical Nutrition',
        ),
        TipModel(
          id: 305, category: TipCategory.nutrition,
          title: 'Add color to your plate',
          body: 'Each color in vegetables represents different antioxidants. '
                'Aim for at least 3 colors per meal for a wide micronutrient range.',
          source: 'WHO',
        ),
        TipModel(
          id: 306, category: TipCategory.nutrition,
          title: 'Watch your $caloriesBudget kcal budget',
          body: 'Your daily budget is $caloriesBudget kcal. Logging every meal — '
                'even small snacks — is the single best predictor of staying on track.',
          source: 'American Journal of Preventive Medicine',
        ),
        TipModel(
          id: 307, category: TipCategory.nutrition,
          title: 'Fiber is your friend',
          body: 'Aim for 25–35 g of fiber per day from vegetables, legumes, '
                'and whole grains. It slows sugar absorption and keeps hunger at bay.',
          source: 'WHO',
        ),
        TipModel(
          id: 308, category: TipCategory.nutrition,
          title: 'Limit ultra-processed foods',
          body: 'Ultra-processed foods hide sugar, salt, and unhealthy fats. '
                'Cooking at home at least 4 days a week gives you much better control.',
          source: 'BMJ',
        ),
        TipModel(
          id: 309, category: TipCategory.nutrition,
          title: 'Healthy fats are essential',
          body: 'Avocados, olive oil, and nuts provide omega-3s that reduce '
                'inflammation, support brain function, and keep you full longer.',
          source: 'New England Journal of Medicine',
        ),
        TipModel(
          id: 310, category: TipCategory.nutrition,
          title: 'Watch hidden sugars in drinks',
          body: 'A single can of soda contains up to 10 teaspoons of sugar. '
                'Switching to water or unsweetened drinks saves 150+ kcal instantly.',
          source: 'American Heart Association',
        ),
        TipModel(
          id: 311, category: TipCategory.nutrition,
          title: 'Plan your meals in advance',
          body: 'People who meal-prep weekly consume 28% fewer calories from '
                'takeout. Spending 1 hour on Sunday saves hours of decisions all week.',
          source: 'International Journal of Behavioral Nutrition',
        ),
        TipModel(
          id: 312, category: TipCategory.nutrition,
          title: 'Never shop hungry',
          body: 'Shopping on an empty stomach increases high-calorie food purchases '
                'by 64%. Eat a small snack before heading to the supermarket.',
          source: 'JAMA Internal Medicine',
        ),

        // ── Exercise (11 tips) ────────────────────────────────────────────
        TipModel(
          id: 401, category: TipCategory.exercise,
          title: steps < 5000 ? 'Get moving today!' : 'Keep up the great work!',
          body: steps < 5000
              ? 'You\'ve logged $steps steps so far. Even a 10-minute walk '
                'after meals improves blood sugar and energy levels.'
              : 'Great work on $steps steps! Adding strength training 2×/week '
                'boosts resting metabolism for 48 h after each session.',
          source: 'American Heart Association',
        ),
        TipModel(
          id: 402, category: TipCategory.exercise,
          title: 'Take the stairs',
          body: 'Swapping the elevator for stairs adds low-effort cardio to '
                'your day. Just 10 flights burns roughly 100 extra calories.',
          source: 'Harvard Health',
        ),
        TipModel(
          id: 403, category: TipCategory.exercise,
          title: 'Strength train twice a week',
          body: 'Two resistance sessions per week preserve lean muscle, boost '
                'resting metabolism, and improve insulin sensitivity long-term.',
          source: 'American College of Sports Medicine',
        ),
        TipModel(
          id: 404, category: TipCategory.exercise,
          title: 'Stretch in the morning',
          body: 'Five minutes of light stretching after waking up improves '
                'circulation, reduces stiffness, and sets a positive tone for the day.',
          source: 'Mayo Clinic',
        ),
        TipModel(
          id: 405, category: TipCategory.exercise,
          title: 'The 2-minute rule',
          body: 'If a workout feels overwhelming, commit to just 2 minutes. '
                'Starting is the hardest part — you\'ll almost always continue.',
          source: 'Behavior Research and Therapy',
        ),
        TipModel(
          id: 406, category: TipCategory.exercise,
          title: 'Rest days are not lazy days',
          body: 'Muscles grow during recovery, not during exercise. One or two '
                'rest days per week improve performance and prevent burnout.',
          source: 'Journal of Strength and Conditioning Research',
        ),
        TipModel(
          id: 407, category: TipCategory.exercise,
          title: 'Post-meal walks lower blood sugar',
          body: 'A gentle 10–15 minute walk after eating reduces the post-meal '
                'blood sugar spike by up to 30%. One of the simplest health habits.',
          source: 'Sports Medicine Journal',
        ),
        TipModel(
          id: 408, category: TipCategory.exercise,
          title: 'Try HIIT for maximum efficiency',
          body: '20 minutes of high-intensity interval training burns as many '
                'calories as 45 minutes of steady cardio — perfect for busy days.',
          source: 'Journal of Obesity',
        ),
        TipModel(
          id: 409, category: TipCategory.exercise,
          title: 'Walk while you talk',
          body: 'Taking phone calls while walking adds 15–30 minutes of movement '
                'to your day without any dedicated workout time.',
          source: 'Mayo Clinic',
        ),
        TipModel(
          id: 410, category: TipCategory.exercise,
          title: 'Warm up before every workout',
          body: 'A 5-minute dynamic warm-up increases muscle temperature by 1–2 °C, '
                'improving performance by 10–20% and significantly reducing injury risk.',
          source: 'British Journal of Sports Medicine',
        ),
        TipModel(
          id: 411, category: TipCategory.exercise,
          title: 'Track your workouts',
          body: 'People who log their exercise are 42% more likely to stick to '
                'their routine. Even a simple note of what you did is enough.',
          source: 'Health Psychology Journal',
        ),

        // ── Health (9 tips) ───────────────────────────────────────────────
        TipModel(
          id: 501, category: TipCategory.health,
          title: 'Small wins matter',
          body: 'Tracking your food daily increases weight loss success by 2× '
                'compared to those who don\'t track. Every log counts.',
          source: 'American Journal of Preventive Medicine',
        ),
        TipModel(
          id: 502, category: TipCategory.health,
          title: 'Stress affects your weight',
          body: 'Chronic stress raises cortisol, increasing fat storage — '
                'especially around the belly. Try 5 minutes of deep breathing daily.',
          source: 'Psychoneuroendocrinology',
        ),
        TipModel(
          id: 503, category: TipCategory.health,
          title: 'Consistency beats perfection',
          body: 'Missing one day doesn\'t ruin your progress. What matters is '
                'your average over the week, not a single day.',
          source: 'Behavior Research and Therapy',
        ),
        TipModel(
          id: 504, category: TipCategory.health,
          title: 'Sunlight in the morning',
          body: 'Getting 10 minutes of natural sunlight within an hour of waking '
                'regulates your circadian rhythm and boosts mood and energy.',
          source: 'Journal of Biological Rhythms',
        ),
        TipModel(
          id: 505, category: TipCategory.health,
          title: 'Social eating is healthy',
          body: 'Eating with others is linked to higher diet quality and better '
                'mental health. Plan at least one shared meal a day when possible.',
          source: 'Social Science & Medicine',
        ),
        TipModel(
          id: 506, category: TipCategory.health,
          title: 'Sit less, live longer',
          body: 'Sitting for more than 8 hours a day increases mortality risk by 60%, '
                'even if you exercise. Stand up or walk for 5 minutes every hour.',
          source: 'Annals of Internal Medicine',
        ),
        TipModel(
          id: 507, category: TipCategory.health,
          title: 'Laugh more — it\'s medicine',
          body: 'Laughter reduces cortisol and adrenaline, lowers blood pressure, '
                'and boosts immune function. Even a forced smile triggers real benefits.',
          source: 'American Psychological Association',
        ),
        TipModel(
          id: 508, category: TipCategory.health,
          title: 'Gratitude improves health',
          body: 'Writing down 3 things you\'re grateful for daily reduces stress '
                'hormones by 23% and improves sleep quality over time.',
          source: 'Journal of Personality and Social Psychology',
        ),
        TipModel(
          id: 509, category: TipCategory.health,
          title: 'Wash your hands — seriously',
          body: 'Regular handwashing reduces respiratory infections by 21% and '
                'gut infections by 31%. One of the highest-impact health habits.',
          source: 'WHO',
        ),
      ];
}