import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  AuthState._();
  static final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

  /// Marks the user as logged in. Call this right after a successful
  /// login, alongside saving whatever session data (username, etc.)
  /// the caller needs.
  static void login() {
    isLoggedIn.value = true;
  }

  /// Logs the user out: flips the shared login flag (which the
  /// FloatingAssistant and other listeners react to) and clears the
  /// persisted "is_logged_in" flag so a restarted app doesn't skip
  /// back to the Dashboard. Kept as one method rather than a raw
  /// `isLoggedIn.value = false` scattered across Settings/other
  /// screens, so there's a single, documented place logout happens.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    isLoggedIn.value = false;
  }
}