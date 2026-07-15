import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captures the student's location silently at login — no screen, no
/// button, nothing the student has to open. This is the same
/// geolocator permission-check → request → getCurrentPosition flow
/// as the original Week 9 GpsScreen, just running in the background
/// instead of behind a "Get my location" button, which is closer to
/// how a real school portal would use device location: as evidence
/// attached to an event (a login), not a feature you go looking for.
class LocationService {
  static const _lastLoginKey = 'last_login_location';

  /// Attempts to capture and persist the current location, tagged
  /// with the time it was captured. Fails silently on any problem
  /// (permission denied, GPS off, no HTTPS on web, etc.) — a failed
  /// background capture should never interrupt or block login.
  static Future<void> captureLoginLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastLoginKey,
        json.encode({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'capturedAt': DateTime.now().toIso8601String(),
        }),
      );
    } catch (_) {
      // Silent by design — this runs in the background at login and
      // should never surface an error or block the login flow.
    }
  }

  /// Reads back the most recently captured login location, or null
  /// if none has ever been captured (e.g. permission was never
  /// granted, or this is web/Chrome without HTTPS).
  static Future<Map<String, dynamic>?> getLastLoginLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastLoginKey);
    if (raw == null) return null;
    return json.decode(raw) as Map<String, dynamic>;
  }
}