import 'dart:async';

class HomeWidgetCommandBus {
  HomeWidgetCommandBus._();

  static final StreamController<Uri> _controller =
      StreamController<Uri>.broadcast();
  static Uri? _lastPending;

  static Stream<Uri> get stream => _controller.stream;

  static void emit(Uri? uri) {
    if (uri == null) return;
    _lastPending = uri;
    _controller.add(uri);
  }

  static Uri? takePending() {
    final uri = _lastPending;
    _lastPending = null;
    return uri;
  }
}
