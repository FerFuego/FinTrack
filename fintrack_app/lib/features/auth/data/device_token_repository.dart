import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>(
  (ref) => DeviceTokenRepository(ref.watch(dioClientProvider)),
);

class DeviceTokenRepository {
  final DioClient _client;

  DeviceTokenRepository(this._client);

  Future<void> registerToken(String token, String platform) async {
    await _client.post(
      '/devices/token',
      data: {'token': token, 'platform': platform},
    );
  }

  Future<void> unregisterToken(String token) async {
    await _client.delete(
      '/devices/token',
      data: {'token': token},
    );
  }
}
