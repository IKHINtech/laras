import 'dart:async';

class HomeWidgetCommandBus {
  HomeWidgetCommandBus._();

  static final StreamController<Uri> _controller =
      StreamController<Uri>.broadcast();

  static Stream<Uri> get stream => _controller.stream;

  static void emit(Uri? uri) {
    if (uri == null) return;
    _controller.add(uri);
  }
}
