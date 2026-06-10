// lib/data/config/ai_api_config.dart

import 'dart:io';
import 'package:flutter/foundation.dart';

class AiApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────────────
  // نفس نفس منطق ApiConfig بتاعك بس على port 8501
  static String get baseUrl {
    if (kIsWeb)             return 'http://localhost:8501';
    if (Platform.isAndroid) return 'http://192.168.1.5:8501'; // نفس IP جهازك
    if (Platform.isIOS)     return 'http://localhost:8501';
    return 'http://localhost:8501';
  }

  // ── API Key ────────────────────────────────────────────────────────────────
  // لو السيرفر مش بيطلب key، سيب القيمة دي فارغة ''
  static const String apiKey = '';

  // ── Endpoints ──────────────────────────────────────────────────────────────
  static const String health    = '/health';
  static const String foods     = '/foods';
  static const String recommend = '/recommend';
  static const String suggest   = '/suggest';
  static const String similar   = '/similar';

  // ── Timeouts (نفس قيم ApiConfig بتاعك) ────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout    = Duration(seconds: 60);

  // ── Headers ────────────────────────────────────────────────────────────────
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
    if (apiKey.isNotEmpty) 'X-API-Key': apiKey,
  };

  // ── Defaults ───────────────────────────────────────────────────────────────
  static const int    defaultTopN      = 5;
  static const double defaultWeight    = 100;
  static const double defaultTolerance = 50;
}