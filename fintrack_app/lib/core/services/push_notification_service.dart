import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../../features/auth/data/device_token_repository.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

class PushNotificationService {
  final Ref _ref;
  String? _mockToken;

  PushNotificationService(this._ref) {
    _generateMockToken();
  }

  void _generateMockToken() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_';
    final tokenBuffer = StringBuffer('fcm_mock_token_');
    for (int i = 0; i < 140; i++) {
      tokenBuffer.write(chars[random.nextInt(chars.length)]);
    }
    _mockToken = tokenBuffer.toString();
  }

  String get mockToken => _mockToken ?? '';

  Future<void> init() async {
    // Simulate requesting permissions and initialization
    print('🔔 [Push Service] Initializing Push Notification Service...');
    print('🔔 [Push Service] Requesting push notification permissions... GRANTED');
    print('🔔 [Push Service] Registered FCM Device Token: $_mockToken');
  }

  Future<void> registerDeviceToken() async {
    if (_mockToken == null) return;
    try {
      final platform = kIsWeb ? 'web' : 'android'; // fallback/simulation platform
      await _ref.read(deviceTokenRepositoryProvider).registerToken(_mockToken!, platform);
      print('🔔 [Push Service] Device token successfully registered on Laravel backend database!');
    } catch (e) {
      print('🔔 [Push Service] Failed to register device token on backend: $e');
    }
  }

  Future<void> unregisterDeviceToken() async {
    if (_mockToken == null) return;
    try {
      await _ref.read(deviceTokenRepositoryProvider).unregisterToken(_mockToken!);
      print('🔔 [Push Service] Device token successfully unregistered from backend database.');
    } catch (e) {
      print('🔔 [Push Service] Failed to unregister device token: $e');
    }
  }
}
