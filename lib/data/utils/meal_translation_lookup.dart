// lib/data/utils/meal_translation_lookup.dart

import 'package:vital_metrics/data/models/egyptian_meals_data.dart';

// The backend admin panel only stores Arabic names and never fills name_en.
// This lookup translates backend meal names to English using the local
// egyptianMeals() dataset, which already has nameEn for ~539 meals.
//
// Usage:
//   final en = MealTranslationLookup.englishFor(meal.name);
//   // en is '' if no match was found

class MealTranslationLookup {
  static Map<String, String>? _cache;

  // normalize — strip diacritics, unify alef/taa marbuta/yaa, collapse spaces
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
      // first match wins, duplicates in the dataset are ignored
      map.putIfAbsent(key, () => meal.nameEn);
    }
    _cache = map;
    return map;
  }

  // Exact normalized match. Returns '' if nothing matches.
  static String englishFor(String arabicName) {
    return _map[_norm(arabicName)] ?? '';
  }

  // Fuzzy fallback for names with small wording differences
  // (extra words, different word order). Only used if exact match fails.
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