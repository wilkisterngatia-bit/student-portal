import 'package:flutter/foundation.dart';

/// Tracks whether a student is currently signed in, so app-wide UI
/// (like the floating assistant bubble) knows whether to show itself.
/// A ValueNotifier is enough here — this is UI-level visibility state,
/// not anything that needs persistence beyond the current app session.
class AuthState {
  AuthState._();
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
}
