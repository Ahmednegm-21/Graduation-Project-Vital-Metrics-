import 'dart:convert';

import 'package:http/http.dart' as http;

class FoodRecommendation {
  final String food;
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbohydrates;
  final double? similarity;

  FoodRecommendation({
    required this.food,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.similarity,
  });

  factory FoodRecommendation.fromJson(Map<String, dynamic> json) {
    return FoodRecommendation(
      food: (json['food'] ?? '').toString(),
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
      similarity: (json['similarity'] as num?)?.toDouble(),
    );
  }
}

class FoodApiResponse {
  final bool success;
  final int count;
  final String query;
  final List<FoodRecommendation> results;
  final String? message;
  final String? error;

  FoodApiResponse({
    required this.success,
    required this.count,
    required this.query,
    required this.results,
    this.message,
    this.error,
  });

  factory FoodApiResponse.fromJson(Map<String, dynamic> json) {
    final resultsJson = (json['results'] as List?) ?? const [];
    return FoodApiResponse(
      success: json['success'] == true,
      count: (json['count'] ?? 0) as int,
      query: (json['query'] ?? '') as String,
      results: resultsJson
          .map((item) => FoodRecommendation.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
      error: json['error'] as String?,
    );
  }
}

class FoodApiService {
  FoodApiService({required this.baseUrl});

  final String baseUrl;

  Future<FoodApiResponse> recommend({
    required String query,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    int topN = 5,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
        'top_n': topN,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final apiResponse = FoodApiResponse.fromJson(body);

    if (response.statusCode >= 400) {
      throw Exception(apiResponse.error ?? 'Food API request failed');
    }

    return apiResponse;
  }
}
