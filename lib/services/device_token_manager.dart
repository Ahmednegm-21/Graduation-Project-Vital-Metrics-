// lib/services/device_token_manager.dart
//
// ── Usage ──────────────────────────────────────────────────────────────────
// After login:
//   await DeviceTokenManager.instance.registerAfterLogin();
//
// Before logout:
//   await DeviceTokenManager.instance.unregisterOnLogout();

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:vital_metrics/services/device_token_service.dart';

class DeviceTokenManager {
  DeviceTokenManager._();
  static final instance = DeviceTokenManager._();

  final DeviceTokenService _service = DeviceTokenService();

  // ── Register after login ──────────────────────────────────────────────────

  /// 1. Requests FCM permission (iOS).
  /// 2. Gets the FCM token.
  /// 3. Registers it with the backend.
  /// 4. Listens for token refresh and re-registers automatically.
  ///
  /// Never throws — errors are swallowed so login flow is never broken.
  Future<void> registerAfterLogin() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (required on iOS)
      final settings = await messaging.requestPermission(
        alert:         true,
        badge:         true,
        sound:         true,
        announcement:  false,
        carPlay:       false,
        criticalAlert: false,
        provisional:   false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[DeviceTokenManager] Permission denied by user.');
        return;
      }

      final fcmToken = await messaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('[DeviceTokenManager] FCM token is null — skipping.');
        return;
      }

      final platform   = _platformString();
      final deviceName = await _deviceName();

      final registered = await _service.registerToken(
        fcmToken:   fcmToken,
        platform:   platform,
        deviceName: deviceName,
      );

      if (registered != null) {
        debugPrint('[DeviceTokenManager] Registered → id: ${registered.tokenId}');
      } else {
        debugPrint('[DeviceTokenManager] Already registered (cached).');
      }

      // Re-register automatically when FCM rotates the token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        debugPrint('[DeviceTokenManager] Token refreshed — re-registering.');
        try {
          await _service.registerToken(
            fcmToken:   newToken,
            platform:   platform,
            deviceName: deviceName,
          );
        } catch (e) {
          debugPrint('[DeviceTokenManager] Re-register failed: $e');
        }
      });
    } catch (e) {
      debugPrint('[DeviceTokenManager] registerAfterLogin error (ignored): $e');
    }
  }

  // ── Unregister on logout ──────────────────────────────────────────────────

  Future<void> unregisterOnLogout() async {
    try {
      await _service.deleteCurrentToken();
      debugPrint('[DeviceTokenManager] Token unregistered.');
    } catch (e) {
      debugPrint('[DeviceTokenManager] unregisterOnLogout error (ignored): $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _platformString() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS || Platform.isMacOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  Future<String> _deviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await info.webBrowserInfo;
        return web.browserName.name;
      }
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return '${android.manufacturer} ${android.model}';
      }
      if (Platform.isIOS) {
        final ios = await info.iosInfo;
        return ios.name;
      }
    } catch (_) {}
    return 'Unknown Device';
  }
}