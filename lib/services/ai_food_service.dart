// lib/data/services/ai_food_service.dart

import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vital_metrics/data/config/ai_api_config.dart';
import 'package:vital_metrics/data/exceptions/api_exception.dart';
import 'package:vital_metrics/data/models/ai_food_models.dart';
import 'package:vital_metrics/data/models/food_item.dart';

class AiFoodService {
  static final AiFoodService _instance = AiFoodService._internal();
  factory AiFoodService() => _instance;
  AiFoodService._internal();

  final http.Client _client = http.Client();

  // ── Helper: GET ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('${AiApiConfig.baseUrl}$path')
          .replace(queryParameters: query);
      final response = await _client
          .get(uri, headers: AiApiConfig.headers)
          .timeout(timeout ?? AiApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on async.TimeoutException {
      throw TimeoutException('Request timed out. The AI model may still be loading, please try again.');
    } on SocketException {
      throw NetworkException();
    }
  }

  // ── Helper: POST ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _post(
    String path, {
    required Map<String, dynamic> body,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('${AiApiConfig.baseUrl}$path');
      final response = await _client
          .post(uri, headers: AiApiConfig.headers, body: jsonEncode(body))
          .timeout(timeout ?? AiApiConfig.receiveTimeout);
      return _handleResponse(response);
    } on async.TimeoutException {
      throw TimeoutException('Request timed out. The AI model may still be loading, please try again.');
    } on SocketException {
      throw NetworkException();
    }
  }

  // ── Response handler ───────────────────────────────────────────────────────
  Map<String, dynamic> _handleResponse(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    switch (response.statusCode) {
      case 200:
      case 201:
        return json;
      case 400:
        throw BadRequestException(json['error'] as String?);
      case 401:
        throw UnauthorizedException(json['error'] as String?);
      case 403:
        throw ForbiddenException(json['error'] as String?);
      case 404:
        throw NotFoundException(json['error'] as String?);
      case 422:
        throw ValidationException(message: json['error'] as String?);
      case 500:
      case 502:
      case 503:
        throw ServerException(json['error'] as String?, response.statusCode);
      default:
        throw HttpException(
          message:    json['error'] as String? ?? 'Unexpected error',
          statusCode: response.statusCode,
        );
    }
  }

  // ── 1) Health Check ────────────────────────────────────────────────────────
  Future<bool> checkHealth() async {
    final json = await _get(AiApiConfig.health);
    return json['success'] == true;
  }

  // ── 2) Get Foods ───────────────────────────────────────────────────────────
  Future<List<FoodItem>> getFoods({String? search, int? limit}) async {
    final response = await _get(
      AiApiConfig.foods,
      query: {
        if (search != null) 'search': search,
        if (limit  != null) 'limit':  limit.toString(),
      },
    );
    return AiFoodsResponse.fromJson(response)
        .items
        .map((e) => e.toFoodItem())
        .toList();
  }

  // ── 3) Recommend Foods ─────────────────────────────────────────────────────
  Future<List<FoodItem>> recommendFoods({
    required String query,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    int topN = AiApiConfig.defaultTopN,
  }) async {
    final response = await _post(
      AiApiConfig.recommend,
      timeout: AiApiConfig.aiModelTimeout,
      body: {
        'query': query,
        'top_n': topN,
        if (calories != null) 'calories': calories,
        if (protein  != null) 'protein':  protein,
        if (fat      != null) 'fat':      fat,
        if (carbs    != null) 'carbs':    carbs,
      },
    );
    return AiRecommendResponse.fromJson(response)
        .items
        .map((e) => e.toFoodItem())
        .toList();
  }

  // ── 4) Suggest Meal ────────────────────────────────────────────────────────
  Future<FoodItem?> suggestMeal({
    required double calories,
    double weight    = AiApiConfig.defaultWeight,
    double tolerance = AiApiConfig.defaultTolerance,
  }) async {
    final response = await _post(
      AiApiConfig.suggest,
      timeout: AiApiConfig.aiModelTimeout,
      body: {
        'calories':  calories,
        'weight':    weight,
        'tolerance': tolerance,
      },
    );
    final result = AiSuggestResponse.fromJson(response);
    return result.meal?.toFoodItem();
  }

  // ── 5) Similar Foods ───────────────────────────────────────────────────────
  Future<List<FoodItem>> similarFoods({
    required String foodName,
    int topN = AiApiConfig.defaultTopN,
  }) async {
    final response = await _post(
      AiApiConfig.similar,
      timeout: AiApiConfig.aiModelTimeout,
      body: {
        'food_name': foodName,
        'top_n':     topN,
      },
    );
    return AiFoodsResponse.fromJson(response)
        .items
        .map((e) => e.toFoodItem())
        .toList();
  }

  void dispose() => _client.close();
}