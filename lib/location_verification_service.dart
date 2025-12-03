import 'package:detect_fake_location/detect_fake_location.dart';
import 'package:geolocator/geolocator.dart';

class LocationVerificationService {

  LocationVerificationService._();

  /// Check location permissions
  static Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Check location services
  static Future<bool> isLocationServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  /// Detect fake location using multiple methods
  static Future<bool> isLocationFake(Position position) async {
    try {
      // Method 1: Direct mock detection (Android only)
      if (position.isMocked) {
        return true;
      }

      // Method 2: Specialized plugin detection
      final isFakeLocation = await DetectFakeLocation().detectFakeLocation();
      if (isFakeLocation) {
        return true;
      }

      // Method 3: Pattern analysis - check for unrealistic speed/jumps
      if (_hasUnrealisticPattern(position)) {
        return true;
      }

      return false;
    } catch (e) {
      // If detection fails, we'll be conservative and trust the location
      print('Fake detection error: $e');
      return false;
    }
  }

  /// Check for unrealistic location patterns
  static bool _hasUnrealisticPattern(Position position) {
    // Check for impossible altitude
    if (position.altitude.abs() > 10000) {
      // Above Mount Everest or too deep
      return true;
    }
    // Check for impossible coordinates
    if (position.latitude.abs() > 90 || position.longitude.abs() > 180) {
      return true;
    }
    // Check accuracy - if accuracy is too poor, be suspicious
    if (position.accuracy > 5000) {
      // Accuracy > 5km is very poor
      return true;
    }
    return false;
  }
}