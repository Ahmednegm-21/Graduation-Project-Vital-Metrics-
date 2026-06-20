// lib/data/config/ai_api_config.dart

import 'dart:io';
import 'package:flutter/foundation.dart';

class AiApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8502';
    if (Platform.isAndroid) return 'http://192.168.1.27:8502';
    if (Platform.isIOS) return 'http://192.168.1.27:8502';
    return 'http://localhost:8502';
  }

  // ── API Key ────────────────────────────────────────────────────────────────
  static const String apiKey = '';

  // ── Endpoints ──────────────────────────────────────────────────────────────
  static const String health = '/health';
  static const String foods = '/foods';
  static const String recommend = '/recommend';
  static const String suggest = '/suggest';
  static const String similar = '/similar';

  // ── Timeouts ───────────────────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration aiModelTimeout = Duration(seconds: 120);

  // ── Headers ────────────────────────────────────────────────────────────────
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (apiKey.isNotEmpty) 'X-API-Key': apiKey,
  };

  // ── Defaults ───────────────────────────────────────────────────────────────
  static const int defaultTopN = 5;
  static const double defaultWeight = 100;
  static const double defaultTolerance = 50;
}
