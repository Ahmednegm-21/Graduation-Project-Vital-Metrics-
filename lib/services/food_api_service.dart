
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vital_metrics/data/models/food_item.dart';
import 'package:vital_metrics/data/models/food_model.dart' hide FoodItem;
import 'package:vital_metrics/data/models/meal_model.dart';

class FoodApiService {
  static const String baseUrl = 'http://10.0.2.2:8501'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8501'; // iOS / Web
  static const String apiKey = ''; 

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (apiKey.isNotEmpty) 'X-API-Key': apiKey,
  };

  // ── Health Check ──────────────────────────────────────────────────────────
  static Future<bool> checkHealth() async {
    final res = await http.get(
      Uri.parse('$baseUrl/health'),
      headers: _headers,
    );
    final data = jsonDecode(res.body);
    return data['success'] == true;
  }

  // ── Get Foods ─────────────────────────────────────────────────────────────
  static Future<List<FoodItem>> getFoods({
    String? search,
    int?    limit,
  }) async {
    final uri = Uri.parse('$baseUrl/foods').replace(
      queryParameters: {
        if (search != null) 'search': search,
        if (limit  != null) 'limit':  limit.toString(),
      },
    );
    final res  = await http.get(uri, headers: _headers);
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      return (data['data'] as List<dynamic>)
          .map((e) => _aiJsonToFoodItem(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(data['error']);
  }

  // ── Recommend Foods ───────────────────────────────────────────────────────
  static Future<List<FoodItem>> recommendFoods({
    required String query,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    int     topN = 5,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/recommend'),
      headers: _headers,
      body: jsonEncode({
        'query': query,
        'top_n': topN,
        if (calories != null) 'calories': calories,
        if (protein  != null) 'protein':  protein,
        if (fat      != null) 'fat':      fat,
        if (carbs    != null) 'carbs':    carbs,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      return (data['data'] as List<dynamic>)
          .map((e) => _aiJsonToFoodItem(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(data['error']);
  }

  // ── Meal Suggestion ───────────────────────────────────────────────────────
  static Future<MealSuggestion?> suggestMeal({
    required double calories,
    double weight    = 100,
    double tolerance = 50,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/suggest'),
      headers: _headers,
      body: jsonEncode({
        'calories':  calories,
        'weight':    weight,
        'tolerance': tolerance,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      if (data['data'] == null) return null;
      return MealSuggestion.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception(data['error']);
  }

  // ── Similar Foods ─────────────────────────────────────────────────────────
  static Future<List<FoodItem>> similarFoods({
    required String foodName,
    int             topN = 5,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/similar'),
      headers: _headers,
      body: jsonEncode({
        'food_name': foodName,
        'top_n':     topN,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (data['success'] == true) {
      return (data['data'] as List<dynamic>)
          .map((e) => _aiJsonToFoodItem(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(data['error']);
  }

  // الـ AI API بيبعت: food, calories, protein, fat, carbohydrates
  static FoodItem _aiJsonToFoodItem(Map<String, dynamic> json) {
    final name = json['food'] as String;
    return FoodItem(
      id:       name.toLowerCase().replaceAll(' ', '_'),
      name:     name,
      emoji:    MealModel.getEmoji(name),
      category: _inferCategory(name),
      calories: (json['calories']      as num).toDouble(),
      protein:  (json['protein']       as num).toDouble(),
      carbs:    (json['carbohydrates'] as num).toDouble(),
      fats:     (json['fat']           as num).toDouble(),
    );
  }

  static String _inferCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('chicken') || n.contains('beef')  || n.contains('fish')  ||
        n.contains('turkey')  || n.contains('lamb')  || n.contains('دجاج')  ||
        n.contains('لحم')     || n.contains('سمك'))
      return 'Protein';
    if (n.contains('rice')    || n.contains('pasta') || n.contains('bread') ||
        n.contains('أرز')     || n.contains('مكرونة')|| n.contains('خبز'))
      return 'Carbs';
    if (n.contains('salad')   || n.contains('vegetable') || n.contains('سلطة') ||
        n.contains('خضار'))
      return 'Vegetables';
    if (n.contains('fruit')   || n.contains('apple') || n.contains('فاكهة'))
      return 'Fruits';
    if (n.contains('milk')    || n.contains('cheese')|| n.contains('yogurt')||
        n.contains('لبن')     || n.contains('جبن'))
      return 'Dairy';
    return 'Other';
  }
}

// ── MealSuggestion Model ───────────────────────────────────────────────────
class MealSuggestion {
  final String name;
  final double weightG;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrates;

  const MealSuggestion({
    required this.name,
    required this.weightG,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      name:          json['food']          as String,
      weightG:       (json['weight_g']     as num).toDouble(),
      calories:      (json['calories']     as num).toDouble(),
      protein:       (json['protein']      as num).toDouble(),
      fat:           (json['fat']          as num).toDouble(),
      carbohydrates: (json['carbohydrates']as num).toDouble(),
    );
  }

  FoodItem toFoodItem() => FoodItem(
    id:       name.toLowerCase().replaceAll(' ', '_'),
    name:     name,
    emoji:    MealModel.getEmoji(name),
    category: 'Suggested',
    calories: calories,
    protein:  protein,
    carbs:    carbohydrates,
    fats:     fat,
  );
}