import 'dart:async';

class HomeWidgetCommandBus {
  HomeWidgetCommandBus._();

  static const _duplicateWindow = Duration(milliseconds: 800);

  static final StreamController<Uri> _controller =
      StreamController<Uri>.broadcast();
  static Uri? _lastPending;
  static String? _lastEmitKey;
  static DateTime? _lastEmitAt;

  static Stream<Uri> get stream => _controller.stream;

  static void emit(Uri? uri) {
    if (uri == null) return;
    final normalized = _normalize(uri);
    final key = normalized.toString();
    final now = DateTime.now();
    final lastEmitAt = _lastEmitAt;
    if (_lastEmitKey == key &&
        lastEmitAt != null &&
        now.difference(lastEmitAt) < _duplicateWindow) {
      return;
    }

    _lastEmitKey = key;
    _lastEmitAt = now;
    if (_controller.hasListener) {
      _controller.add(normalized);
    } else {
      _lastPending = normalized;
    }
  }

  static Uri? takePending() {
    final uri = _lastPending;
    _lastPending = null;
    return uri;
  }

  static Uri _normalize(Uri uri) {
    final action = uri.queryParameters['action'];
    if (action != null && action.isNotEmpty) {
      return Uri(
        scheme: 'laras',
        host: 'player',
        queryParameters: {'action': action},
      );
    }
    if (uri.host == 'now-playing' || uri.path.contains('now-playing')) {
      return Uri(scheme: 'laras', host: 'now-playing');
    }
    return uri;
  }
}
