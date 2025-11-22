import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Helper class for testing location functionality on Android emulator
/// This simulates location updates when real GPS is not available
class LocationTestHelper {
  static Timer? _simulationTimer;
  static bool _isSimulating = false;
  
  // Delhi coordinates for simulation
  static const double _baseLatitude = 28.6139;
  static const double _baseLongitude = 77.2090;
  static double _currentLatitude = _baseLatitude;
  static double _currentLongitude = _baseLongitude;
  
  /// Starts simulating location updates for testing
  static void startLocationSimulation() {
    if (_isSimulating) return;
    
    _isSimulating = true;
    print('Starting location simulation for testing...');
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _simulateLocationUpdate();
    });
  }
  
  /// Stops location simulation
  static void stopLocationSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isSimulating = false;
    print('Location simulation stopped');
  }
  
  /// Simulates a location update with small random movements
  static void _simulateLocationUpdate() {
    final random = Random();
    
    // Add small random movement (simulating walking)
    _currentLatitude += (random.nextDouble() - 0.5) * 0.0001; // ~10m variation
    _currentLongitude += (random.nextDouble() - 0.5) * 0.0001; // ~10m variation
    
    // Create a simulated position
      final simulatedPosition = Position(
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        timestamp: DateTime.now(),
        accuracy: 5.0 + random.nextDouble() * 10.0, // 5-15m accuracy
        altitude: 0.0,
        heading: random.nextDouble() * 360.0,
        speed: random.nextDouble() * 5.0, // 0-5 m/s
        speedAccuracy: 1.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      );
    
    // Save to Hive for testing
    _saveSimulatedLocation(simulatedPosition);
    
    print('Simulated location: ${_currentLatitude.toStringAsFixed(6)}, ${_currentLongitude.toStringAsFixed(6)}');
  }
  
  /// Saves simulated location to Hive
  static Future<void> _saveSimulatedLocation(Position position) async {
    try {
      final box = Hive.box('bg_samples');
      final sample = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'heading': position.heading,
        'timestamp': position.timestamp.millisecondsSinceEpoch,
        'simulated': true, // Mark as simulated
      };
      
      await box.add(sample);
      
      // Keep only last 1000 samples
      if (box.length > 1000) {
        await box.deleteAt(0);
      }
    } catch (e) {
      print('Error saving simulated location: $e');
    }
  }
  
  /// Checks if location simulation is active
  static bool get isSimulating => _isSimulating;
  
  /// Resets simulation to base location
  static void resetToBaseLocation() {
    _currentLatitude = _baseLatitude;
    _currentLongitude = _baseLongitude;
    print('Location simulation reset to base location');
  }
}