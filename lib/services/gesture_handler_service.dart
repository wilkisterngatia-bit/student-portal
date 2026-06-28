import 'package:flutter/material.dart';

/// The four gesture types this app recognizes, organized as an enum
/// so every part of the app refers to gestures the same way rather
/// than passing around raw strings.
enum GestureType { tap, doubleTap, longPress, swipeLeft, swipeRight, swipeUp, swipeDown }

/// A single recognized gesture event, carrying its type and the time
/// it happened — used by the demo screen's event log, but designed so
/// any screen could subscribe to gesture events in the same shape.
class GestureEvent {
  final GestureType type;
  final DateTime timestamp;
  const GestureEvent(this.type, this.timestamp);

  String get label {
    switch (type) {
      case GestureType.tap:
        return 'Tap';
      case GestureType.doubleTap:
        return 'Double tap';
      case GestureType.longPress:
        return 'Long press';
      case GestureType.swipeLeft:
        return 'Swipe left';
      case GestureType.swipeRight:
        return 'Swipe right';
      case GestureType.swipeUp:
        return 'Swipe up';
      case GestureType.swipeDown:
        return 'Swipe down';
    }
  }
}

/// A dedicated class for organizing touch gesture handling, rather
/// than wiring onTap/onDoubleTap/onLongPress/onPanEnd callbacks
/// inline on every widget that needs them. Call [wrap] around any
/// child widget to give it full tap, double-tap, long-press, and
/// four-directional swipe detection, with every recognized gesture
/// reported through a single [onGesture] callback.
///
/// This is the Flutter/Dart equivalent of the lecture notes' Python
/// GestureHandler class — same idea (a dedicated class owning gesture
/// recognition logic so calling code doesn't reimplement it per
/// screen), expressed with Flutter's gesture detection widgets.
class GestureHandlerService {
  final void Function(GestureEvent event) onGesture;

  /// Minimum drag distance (in logical pixels) before a pan is
  /// classified as a swipe rather than an accidental small movement.
  final double swipeThreshold;

  GestureHandlerService({required this.onGesture, this.swipeThreshold = 60});

  void _emit(GestureType type) {
    onGesture(GestureEvent(type, DateTime.now()));
  }

  /// Wraps [child] with gesture detection for tap, double-tap,
  /// long-press, and swipe in all four directions.
  Widget wrap({required Widget child}) {
    Offset? panStart;

    return GestureDetector(
      onTap: () => _emit(GestureType.tap),
      onDoubleTap: () => _emit(GestureType.doubleTap),
      onLongPress: () => _emit(GestureType.longPress),
      onPanStart: (details) => panStart = details.localPosition,
      onPanEnd: (details) {
        if (panStart == null) return;
        final velocity = details.velocity.pixelsPerSecond;

        if (velocity.distance < swipeThreshold * 4) return;

        if (velocity.dx.abs() > velocity.dy.abs()) {
          _emit(velocity.dx > 0 ? GestureType.swipeRight : GestureType.swipeLeft);
        } else {
          _emit(velocity.dy > 0 ? GestureType.swipeDown : GestureType.swipeUp);
        }
        panStart = null;
      },
      child: child,
    );
  }
}
