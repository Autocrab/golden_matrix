import 'package:flutter/foundation.dart';

/// Captures Flutter layout errors and warnings during widget rendering.
///
/// Used internally by the test runner to detect RenderFlex overflows,
/// layout failures, and other framework errors during golden tests.
///
/// Usage:
/// ```dart
/// final capture = ErrorCapture()..start();
/// try {
///   await tester.pumpWidget(widget);
///   await tester.pumpAndSettle();
/// } finally {
///   capture.stop();
/// }
/// print(capture.warnings); // ['A RenderFlex overflowed by 42 pixels...']
/// ```
class ErrorCapture {
  /// Collected warning messages.
  final List<String> warnings = [];

  FlutterExceptionHandler? _originalHandler;
  bool _active = false;

  /// Known error patterns to capture as warnings.
  static const _warningPatterns = [
    'RenderFlex overflowed',
    'RenderBox was not laid out',
    'A RenderFlex overflowed by',
    'overflowing by',
    'OVERFLOWING',
  ];

  /// Starts capturing Flutter errors.
  ///
  /// Overrides [FlutterError.onError] with a custom handler that
  /// collects layout warnings. Always call [stop] when done.
  void start() {
    if (_active) return;
    _active = true;
    _originalHandler = FlutterError.onError;
    FlutterError.onError = _handleError;
  }

  /// Stops capturing and restores the original error handler.
  ///
  /// Safe to call multiple times.
  void stop() {
    if (!_active) return;
    _active = false;
    FlutterError.onError = _originalHandler;
    _originalHandler = null;
  }

  void _handleError(FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    final isLayoutWarning = _warningPatterns.any((pattern) => message.contains(pattern));

    if (isLayoutWarning) {
      warnings.add(message);
    }

    // Always forward to original handler to maintain framework state
    _originalHandler?.call(details);
  }
}
