// lib/data/utils/meal_translation_lookup.dart

import 'package:vital_metrics/data/models/egyptian_meals_data.dart';


class MealTranslationLookup {
  static Map<String, String>? _cache;

  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll(RegExp(r'ة'), 'ه')
      .replaceAll(RegExp(r'ى'), 'ي')
      .replaceAll(RegExp(r'[،,.\-_]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static Map<String, String> get _map {
    if (_cache != null) return _cache!;
    final map = <String, String>{};
    for (final meal in egyptianMeals()) {
      if (meal.nameEn.isEmpty) continue;
      final key = _norm(meal.name);
      map.putIfAbsent(key, () => meal.nameEn);
    }
    _cache = map;
    return map;
  }

  static String englishFor(String arabicName) {
    return _map[_norm(arabicName)] ?? '';
  }

  static String englishForFuzzy(String arabicName) {
    final exact = englishFor(arabicName);
    if (exact.isNotEmpty) return exact;

    final q = _norm(arabicName);
    final words = q.split(' ').where((w) => w.length >= 2).toList();
    if (words.isEmpty) return '';

    for (final entry in _map.entries) {
      if (words.every((w) => entry.key.contains(w))) {
        return entry.value;
      }
    }
    return '';
  }
}