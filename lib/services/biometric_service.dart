import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// Wraps the phone's own fingerprint/face sensor for confirming the
/// enrolled student's identity before joining an online lesson.
///
/// This is real device biometrics (via local_auth), unlike the
/// classroom door scanners — there is no separate hardware for an
/// online class, so the phone itself is the right device to confirm
/// "this is genuinely the enrolled student, present right now."
///
/// On Flutter Web there is no biometric sensor API, so authenticate()
/// falls back to a short simulated check so the demo still runs in
/// Chrome. On a real device this triggers the actual OS fingerprint
/// or face prompt.
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the student's identity was confirmed, either via
  /// a real biometric prompt or the simulated web fallback.
  static Future<bool> authenticate({required String reason}) async {
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 700));
      return true;
    }
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
