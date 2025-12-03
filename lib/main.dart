import 'dart:async';
import 'package:fake_location_detector_sample/location_verification_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const LocationVerifierScreen(),
    );
  }
}

class LocationVerifierScreen extends StatefulWidget {
  const LocationVerifierScreen({super.key});

  @override
  State<LocationVerifierScreen> createState() => _LocationVerifierScreenState();
}

class _LocationVerifierScreenState extends State<LocationVerifierScreen> {
  String _locationText = 'Press button to get location';
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Verifier')),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_locationText),
              if (!_isLoading && _currentPosition != null && !_locationText.contains('Fake')) ...[
                SizedBox(height: 24),
                Text(
                  'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)} meters\n'
                  'Altitude: ${_currentPosition!.altitude.toStringAsFixed(1)} meters',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 32),
              _isLoading ? CircularProgressIndicator() : ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text('Get Current Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _locationText = 'Checking permissions...';
    });
    try {
      // TODO 4. Check permission
      if (!await LocationVerificationService.isLocationPermissionGranted()) {
        setState(() {
          _locationText = 'Location permission is denied';
          _isLoading = false;
        });
        return;
      }
      // TODO 5. Check service
      if (!await LocationVerificationService.isLocationServiceEnabled()) {
        setState(() {
          _locationText = 'Location service is disabled';
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _locationText = 'Getting location...';
      });
      // TODO 6. Get current position
      Position position = await Geolocator.getCurrentPosition(locationSettings: AndroidSettings(forceLocationManager: true));
      setState(() {
        _locationText = 'Verifying location...';
      });
      // TODO 7. Check if location is fake
      bool isFake = await LocationVerificationService.isLocationFake(position);
      if (isFake) {
        setState(() {
          _currentPosition = position;
          _locationText = '⚠️ Fake location detected!';
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentPosition = position;
          _locationText =
              '📍 Real Location:\n'
              'Lat: ${position.latitude.toStringAsFixed(6)}\n'
              'Lng: ${position.longitude.toStringAsFixed(6)}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationText = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
