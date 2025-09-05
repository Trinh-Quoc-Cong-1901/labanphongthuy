import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:rxdart/rxdart.dart';

import '../models/compass_data.dart';

class SensorService {
  static SensorService? _instance;
  static SensorService get instance => _instance ??= SensorService._internal();
  
  SensorService._internal();

  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  
  final BehaviorSubject<CompassData> _compassDataController = 
      BehaviorSubject<CompassData>.seeded(CompassData.initial());
  
  final BehaviorSubject<bool> _isAvailableController = 
      BehaviorSubject<bool>.seeded(false);

  final BehaviorSubject<double> _calibrationAccuracy = 
      BehaviorSubject<double>.seeded(0.0);

  // Smoothing parameters - reduced buffer size for better performance
  static const int _bufferSize = 3;
  final List<double> _headingBuffer = [];
  
  // Performance optimization - throttle updates to match controller (60fps)
  static const int _updateIntervalMs = 16; // Update every 16ms for 60fps smooth rotation
  DateTime _lastUpdateTime = DateTime(0);
  
  // Calibration variables  
  final List<double> _calibrationReadings = [];
  bool _isCalibrating = false;
  static const int _calibrationSamples = 20;

  // Getters for streams
  Stream<CompassData> get compassDataStream => _compassDataController.stream;
  Stream<bool> get isAvailableStream => _isAvailableController.stream;
  Stream<double> get calibrationAccuracyStream => _calibrationAccuracy.stream;
  
  CompassData get currentCompassData => _compassDataController.value;
  bool get isAvailable => _isAvailableController.value;
  double get calibrationAccuracy => _calibrationAccuracy.value;

  /// Initialize the sensor service
  Future<bool> initialize() async {
    try {
      // Check if compass is available
      final compassAvailable = await FlutterCompass.events?.first != null;
      _isAvailableController.add(compassAvailable);
      
      if (compassAvailable) {
        await _startListening();
        return true;
      }
      return false;
    } catch (e) {
      _isAvailableController.add(false);
      return false;
    }
  }

  /// Start listening to sensor data
  Future<void> _startListening() async {
    // Listen to compass events
    _compassSubscription = FlutterCompass.events?.listen(
      (CompassEvent event) {
        if (event.heading != null) {
          _processCompassReading(event.heading!);
        }
      },
      onError: (error) {
        _isAvailableController.add(false);
      },
    );

    // Listen to magnetometer for calibration accuracy
    _magnetometerSubscription = magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        _updateCalibrationAccuracy(event);
      },
      onError: (error) {
        // Handle magnetometer error silently
      },
    );
  }

  /// Process raw compass reading with smoothing and throttling
  void _processCompassReading(double rawHeading) {
    final now = DateTime.now();
    
    // Throttle updates to improve performance
    if (now.difference(_lastUpdateTime).inMilliseconds < _updateIntervalMs) {
      return;
    }
    _lastUpdateTime = now;
    
    final smoothedHeading = _smoothHeading(rawHeading);
    final isCalibrated = calibrationAccuracy > 0.7;
    
    final compassData = CompassData(
      heading: smoothedHeading,
      magneticDeclination: 1.0, // Vietnam magnetic declination ~1° East
      isCalibrated: isCalibrated,
      timestamp: now,
    );
    
    _compassDataController.add(compassData);
    
    // Add to calibration data if calibrating
    if (_isCalibrating && _calibrationReadings.length < _calibrationSamples) {
      _calibrationReadings.add(smoothedHeading);
    }
  }

  /// Smooth heading readings to reduce jitter
  double _smoothHeading(double rawHeading) {
    // Handle the 360-0 degree transition
    final normalizedHeading = rawHeading < 0 ? rawHeading + 360 : rawHeading % 360;
    
    _headingBuffer.add(normalizedHeading);
    
    if (_headingBuffer.length > _bufferSize) {
      _headingBuffer.removeAt(0);
    }
    
    if (_headingBuffer.isEmpty) return normalizedHeading;
    
    // Use circular mean for angle averaging
    double sinSum = 0;
    double cosSum = 0;
    
    for (final heading in _headingBuffer) {
      final radians = heading * math.pi / 180;
      sinSum += math.sin(radians);
      cosSum += math.cos(radians);
    }
    
    final meanRadians = math.atan2(sinSum / _headingBuffer.length, cosSum / _headingBuffer.length);
    var meanDegrees = meanRadians * 180 / math.pi;
    
    if (meanDegrees < 0) meanDegrees += 360;
    
    return meanDegrees;
  }

  /// Update calibration accuracy based on magnetometer readings with throttling
  DateTime _lastCalibrationUpdate = DateTime(0);
  
  void _updateCalibrationAccuracy(MagnetometerEvent event) {
    final now = DateTime.now();
    
    // Throttle calibration updates to reduce CPU usage
    if (now.difference(_lastCalibrationUpdate).inMilliseconds < 500) {
      return;
    }
    _lastCalibrationUpdate = now;
    
    // Calculate magnetic field strength
    final fieldStrength = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );
    
    // Earth's magnetic field is typically 25-65 microtesla
    // Higher values indicate better calibration
    const minFieldStrength = 20.0;
    const maxFieldStrength = 70.0;
    
    double accuracy = 0.0;
    if (fieldStrength >= minFieldStrength && fieldStrength <= maxFieldStrength) {
      accuracy = math.min(1.0, (fieldStrength - minFieldStrength) / (maxFieldStrength - minFieldStrength));
    }
    
    // Only update if accuracy changed significantly
    if ((accuracy - _calibrationAccuracy.value).abs() > 0.05) {
      _calibrationAccuracy.add(accuracy);
    }
  }

  /// Start calibration process
  Future<bool> startCalibration() async {
    if (!isAvailable) return false;
    
    _isCalibrating = true;
    _calibrationReadings.clear();
    
    return true;
  }

  /// Finish calibration and return success
  bool finishCalibration() {
    _isCalibrating = false;
    
    if (_calibrationReadings.length >= _calibrationSamples) {
      // Calculate variance to check if user moved device enough
      final mean = _calibrationReadings.reduce((a, b) => a + b) / _calibrationReadings.length;
      final variance = _calibrationReadings
          .map((x) => math.pow(x - mean, 2))
          .reduce((a, b) => a + b) / _calibrationReadings.length;
      
      // Good calibration should have sufficient variance (movement)
      return variance > 1000; // Adjust threshold as needed
    }
    
    return false;
  }

  /// Get calibration progress (0-1)
  double get calibrationProgress => 
      _calibrationReadings.length / _calibrationSamples.toDouble();

  /// Pause sensor listening
  void pause() {
    _compassSubscription?.pause();
    _magnetometerSubscription?.pause();
  }

  /// Resume sensor listening  
  void resume() {
    _compassSubscription?.resume();
    _magnetometerSubscription?.resume();
  }

  /// Stop and dispose of all resources
  void dispose() {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = null;
    
    // Close streams if not already closed
    if (!_compassDataController.isClosed) {
      _compassDataController.close();
    }
    if (!_isAvailableController.isClosed) {
      _isAvailableController.close();
    }
    if (!_calibrationAccuracy.isClosed) {
      _calibrationAccuracy.close();
    }
    
    // Clear buffers to free memory
    _headingBuffer.clear();
    _calibrationReadings.clear();
    
    // Reset singleton instance for clean restart
    _instance = null;
  }
}