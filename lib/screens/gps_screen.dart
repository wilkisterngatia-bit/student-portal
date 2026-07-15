
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
 
/// Week 9 — GPS Integration.
///
/// Demonstrates how a mobile application accesses the device's GPS
/// sensor to retrieve the student's current location, following the
/// Week 9 brief: request permission → access sensor → display data.
/// Shows latitude, longitude, accuracy, and altitude in real time.
class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});
 
  @override
  State<GpsScreen> createState() => _GpsScreenState();
}
 
class _GpsScreenState extends State<GpsScreen> {
  Position? _position;
  bool _isLoading = false;
  String? _errorMessage;
  String _permissionStatus = 'Not checked';
 
  Future<void> _getLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
 
    try {
      // Step 1: Check if location services are enabled on the device.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Location services are disabled. Enable GPS in your device settings and try again.';
          _permissionStatus = 'Service disabled';
        });
        return;
      }
 
      // Step 2: Check and request location permission.
      LocationPermission permission = await Geolocator.checkPermission();
      setState(() => _permissionStatus = permission.name);
 
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        setState(() => _permissionStatus = permission.name);
 
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Location permission denied. The app needs location access to show your GPS coordinates.';
          });
          return;
        }
      }
 
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _permissionStatus = 'Denied permanently';
          _errorMessage =
              'Location permission permanently denied. Go to your device Settings → Apps → Student Portal → Permissions to enable it.';
        });
        return;
      }
 
      // Step 3: Retrieve the current GPS position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
 
      setState(() {
        _position = position;
        _isLoading = false;
        _permissionStatus = 'Granted';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not retrieve location. On Chrome, GPS access requires HTTPS and browser permission — try on a physical device for full GPS data.';
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                  eyebrow: 'DEVICE FEATURES', title: 'GPS Location'),
              const SizedBox(height: 4),
              Text(
                'Retrieve your current GPS coordinates from the device sensor.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
 
              // GPS info card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.location_on_outlined,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('GPS Sensor',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            'Permission: $_permissionStatus',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
 
              const SizedBox(height: AppSpacing.xl),
 
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _getLocation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location, size: 20),
                label: Text(
                    _isLoading ? 'Getting location...' : 'Get my location'),
              ),
 
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.amber,
                                height: 1.4)),
                      ),
                    ],
                  ),
                ),
              ],
 
              if (_position != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Current location',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
 
                _coordCard(context, 'Latitude',
                    '${_position!.latitude.toStringAsFixed(6)}°',
                    Icons.arrow_upward),
                const SizedBox(height: AppSpacing.sm),
                _coordCard(context, 'Longitude',
                    '${_position!.longitude.toStringAsFixed(6)}°',
                    Icons.arrow_forward),
                const SizedBox(height: AppSpacing.sm),
                _coordCard(context, 'Accuracy',
                    '±${_position!.accuracy.toStringAsFixed(1)} metres',
                    Icons.radar),
                const SizedBox(height: AppSpacing.sm),
                _coordCard(context, 'Altitude',
                    '${_position!.altitude.toStringAsFixed(1)} metres',
                    Icons.height),
              ],
 
              const SizedBox(height: AppSpacing.xl),
 
              // How it works
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.violetSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.inkPlum),
                        SizedBox(width: 8),
                        Text('How GPS integration works',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkPlum)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _stepRow('1', 'App checks if location services are enabled'),
                    _stepRow('2', 'App requests location permission from the OS'),
                    _stepRow('3', 'GPS sensor reads satellite/network signals'),
                    _stepRow('4', 'Coordinates returned and displayed in the app'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _coordCard(
      BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.violetSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: AppColors.violet),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.violet,
                  )),
        ],
      ),
    );
  }
 
  Widget _stepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.inkPlum,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkPlum,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }
}
 
















