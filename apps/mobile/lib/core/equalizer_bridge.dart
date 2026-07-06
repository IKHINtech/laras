import 'package:flutter/services.dart';

class EqualizerBridge {
  static const _channel = MethodChannel('laras/equalizer');

  static Future<bool> openSystemEqualizer(int? sessionId) async {
    if (sessionId == null) return false;
    final result = await _channel.invokeMethod<bool>('openEqualizer', {
      'sessionId': sessionId,
    });
    return result ?? false;
  }
}
