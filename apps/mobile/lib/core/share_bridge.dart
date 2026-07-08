import 'package:flutter/services.dart';

class ShareBridge {
  static const _channel = MethodChannel('laras/share');

  static Future<bool> shareImage({
    required String path,
    String? text,
  }) async {
    final result = await _channel.invokeMethod<bool>(
      'shareImage',
      {
        'path': path,
        'text': text,
      },
    );
    return result == true;
  }
}
