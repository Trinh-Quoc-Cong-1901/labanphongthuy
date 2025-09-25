import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';

import '../models/compass_data.dart';
import '../models/direction_info.dart';
import '../models/feng_shui_result.dart';
import '../services/sensor_service.dart';
import '../services/feng_shui_calculator.dart';

enum CompassMode {
  basic,     // La bàn cơ bản - 8 cung + 24 sơn
  personal,  // La bàn cá nhân - theo tuổi + feng shui
}

class CompassController extends GetxController {
  static CompassController get instance => Get.find<CompassController>();

  // Services
  final SensorService _sensorService = SensorService.instance;
  final FengShuiCalculator _fengShuiCalculator = FengShuiCalculator.instance;
  
  // Performance optimization
  DateTime _lastUpdateTime = DateTime.now();
  static const int _updateThrottleMs = 16; // ~60 FPS, reduce from default sensor frequency

  // Observable data
  final _compassData = CompassData.initial().obs;
  final _isCompassAvailable = false.obs;
  final _calibrationAccuracy = 0.0.obs;
  final _currentDirection = Rx<DirectionInfo?>(null);
  final _compassMode = CompassMode.basic.obs;
  final _fengShuiResult = Rx<FengShuiResult?>(null);
  final _isCalibrating = false.obs;
  final _calibrationProgress = 0.0.obs;

  // Animation
  final _rotationAngle = 0.0.obs;
  final _isRotating = false.obs;

  // Stream subscriptions
  StreamSubscription<CompassData>? _compassSubscription;
  StreamSubscription<bool>? _availabilitySubscription;
  StreamSubscription<double>? _calibrationSubscription;
  Timer? _calibrationTimer; // Fix timer memory leak

  // Getters - return locked values when rotation is locked
  CompassData get compassData => _isRotationLocked.value ? _lockedCompassData.value : _compassData.value;
  bool get isCompassAvailable => _isCompassAvailable.value;
  double get calibrationAccuracy => _calibrationAccuracy.value;
  DirectionInfo? get currentDirection => _isRotationLocked.value ? _lockedDirection.value : _currentDirection.value;
  CompassMode get compassMode => _compassMode.value;
  FengShuiResult? get fengShuiResult => _fengShuiResult.value;
  bool get isCalibrating => _isCalibrating.value;
  double get calibrationProgress => _calibrationProgress.value;
  double get rotationAngle => _isRotationLocked.value ? _lockedAngle.value : _rotationAngle.value;
  bool get isRotating => _isRotating.value;

  // Personal info for feng shui
  final _birthYear = 0.obs;
  final _isMale = true.obs;
  final _hasPersonalInfo = false.obs;
  
  // UI settings
  final _show24Mountains = true.obs;
  
  // Zoom settings
  final _zoomLevel = 1.0.obs;
  final _isRotationLocked = false.obs;
  final _lockedAngle = 0.0.obs; // Angle when locked
  final _lockedCompassData = CompassData.initial().obs; // Compass data when locked
  final _lockedDirection = Rx<DirectionInfo?>(null); // Direction when locked
  final _zoomAction = Rx<String?>(''); // Zoom action: 'in', 'out', 'reset'
  
  // Screenshot functionality
  final ScreenshotController _screenshotController = ScreenshotController();
  final _isCapturingScreenshot = false.obs;

  int get birthYear => _birthYear.value;
  bool get isMale => _isMale.value;
  bool get hasPersonalInfo => _hasPersonalInfo.value;
  bool get show24Mountains => _show24Mountains.value;
  double get zoomLevel => _zoomLevel.value;
  bool get isRotationLocked => _isRotationLocked.value;
  double get lockedAngle => _lockedAngle.value;
  Rx<String?> get zoomActionObs => _zoomAction;
  ScreenshotController get screenshotController => _screenshotController;
  bool get isCapturingScreenshot => _isCapturingScreenshot.value;

  @override
  void onInit() {
    super.onInit();
    _initializeCompass();
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    _disposeSubscriptions();
    // ScreenshotController doesn't need explicit disposal
    _sensorService.dispose();
    super.onClose();
  }
  
  /// Handle app lifecycle changes for better performance
  void onAppLifecycleStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        pauseCompass();
        break;
      case AppLifecycleState.resumed:
        if (_isCompassAvailable.value) {
          resumeCompass();
        }
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
    }
  }

  /// Initialize compass service and start listening
  Future<void> _initializeCompass() async {
    try {
      final isAvailable = await _sensorService.initialize();
      _isCompassAvailable.value = isAvailable;

      if (isAvailable) {
        _startListening();
      } else {
        Get.snackbar(
          'Không thể khởi tạo la bàn',
          'Thiết bị không hỗ trợ cảm biến từ tính hoặc quyền truy cập bị từ chối',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          isDismissible: true,
        );
      }
    } catch (e) {
      // Handle initialization error silently
      _isCompassAvailable.value = false;
      Get.snackbar(
        'Lỗi khởi tạo',
        'Không thể khởi tạo la bàn: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        isDismissible: true,
      );
    }
  }

  /// Start listening to sensor data streams
  void _startListening() {
    // Listen to compass data
    _compassSubscription = _sensorService.compassDataStream.listen(
      (data) {
        // Skip updates if rotation is locked (freeze all compass state)
        if (_isRotationLocked.value) {
          return; // Don't update anything when locked
        }
        
        // Throttle updates to reduce UI lag (60 FPS max)
        final now = DateTime.now();
        if (now.difference(_lastUpdateTime).inMilliseconds >= _updateThrottleMs) {
          _lastUpdateTime = now;
          
          _compassData.value = data;
          _updateRotationAngle(data.heading);
          _updateCurrentDirection(data.heading);
        }
      },
      onError: (error) {
        // Handle sensor error
        _isCompassAvailable.value = false;
        Get.snackbar(
          'Lỗi la bàn',
          'Không thể đọc dữ liệu từ cảm biến từ tính',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          isDismissible: true,
        );
      },
    );

    // Listen to availability
    _availabilitySubscription = _sensorService.isAvailableStream.listen(
      (available) {
        _isCompassAvailable.value = available;
        if (!available) {
          Get.snackbar(
            'Cảnh báo',
            'Cảm biến la bàn không khả dụng',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            isDismissible: true,
          );
        }
      },
    );

    // Listen to calibration accuracy
    _calibrationSubscription = _sensorService.calibrationAccuracyStream.listen(
      (accuracy) => _calibrationAccuracy.value = accuracy,
    );
  }

  /// Update rotation angle with enhanced smooth animation
  void _updateRotationAngle(double heading) {
    final newAngle = -heading; // Negative to rotate compass correctly
    
    // Handle 360-0 degree transition smoothly
    final currentAngle = _rotationAngle.value;
    var diff = newAngle - currentAngle;
    
    // Normalize difference to [-180, 180] range for shortest path
    while (diff > 180) {
      diff -= 360;
    }
    while (diff < -180) {
      diff += 360;
    }
    
    // Enhanced smoothing with adaptive dampening
    if (diff.abs() > 0.3) { // Lower threshold for smoother updates
      // Variable dampening based on difference magnitude
      double dampening;
      if (diff.abs() > 90) {
        dampening = 0.15; // Faster for large movements
      } else if (diff.abs() > 30) {
        dampening = 0.20; // Medium speed
      } else {
        dampening = 0.35; // Slower for small movements (smoother)
      }
      
      // Apply smooth transition
      _rotationAngle.value = currentAngle + (diff * dampening);
    }
  }

  /// Update current direction based on heading
  void _updateCurrentDirection(double heading) {
    final direction = DirectionInfo.getByHeading(heading);
    _currentDirection.value = direction;
  }

  /// Switch between basic and personal compass modes
  void switchMode(CompassMode mode) {
    _compassMode.value = mode;
    
    if (mode == CompassMode.personal && !_hasPersonalInfo.value) {
      // Need to collect personal info first
      return;
    }
  }

  /// Set personal information for feng shui calculations
  void setPersonalInfo(int year, bool male) {
    _birthYear.value = year;
    _isMale.value = male;
    _hasPersonalInfo.value = true;
    
    // Calculate feng shui result
    _calculateFengShui();
    
    // Switch to personal mode
    _compassMode.value = CompassMode.personal;
  }

  /// Clear personal information
  void clearPersonalInfo() {
    _birthYear.value = 0;
    _isMale.value = true;
    _hasPersonalInfo.value = false;
    _fengShuiResult.value = null;
    _compassMode.value = CompassMode.basic;
  }

  /// Calculate feng shui result based on personal info
  void _calculateFengShui() {
    if (_hasPersonalInfo.value) {
      final result = _fengShuiCalculator.calculateFengShuiResult(
        _birthYear.value,
        _isMale.value,
      );
      _fengShuiResult.value = result;
    }
  }

  /// Get feng shui direction type for current heading
  FengShuiDirectionResult? getCurrentFengShuiDirection() {
    if (_fengShuiResult.value == null || _currentDirection.value == null) {
      return null;
    }
    
    return _fengShuiResult.value!.getDirectionType(
      _currentDirection.value!.baGuaDirection
    );
  }

  /// Start compass calibration
  Future<bool> startCalibration() async {
    if (!_isCompassAvailable.value) return false;
    
    _isCalibrating.value = true;
    _calibrationProgress.value = 0.0;
    
    final success = await _sensorService.startCalibration();
    
    if (success) {
      // Monitor calibration progress with proper cleanup
      _calibrationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        final progress = _sensorService.calibrationProgress;
        _calibrationProgress.value = progress;
        
        if (progress >= 1.0) {
          timer.cancel();
          _calibrationTimer = null; // Clear reference
          _finishCalibration();
        }
      });
    } else {
      _isCalibrating.value = false;
    }
    
    return success;
  }

  /// Finish calibration
  void _finishCalibration() {
    final success = _sensorService.finishCalibration();
    _isCalibrating.value = false;
    _calibrationProgress.value = 0.0;
    
    if (success) {
      Get.snackbar(
        'Hiệu chỉnh thành công',
        'La bàn đã được hiệu chỉnh và sẵn sàng sử dụng',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
    } else {
      Get.snackbar(
        'Hiệu chỉnh thất bại',
        'Vui lòng thử lại và xoay thiết bị theo hình số 8',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
    }
  }

  /// Pause compass (for performance)
  void pauseCompass() {
    _sensorService.pause();
    // Compass paused successfully
  }

  /// Resume compass
  void resumeCompass() {
    _sensorService.resume();
    // Compass resumed successfully
  }
  
  /// Check if compass is currently active
  bool get isActive => _compassSubscription != null && !_compassSubscription!.isPaused;

  /// Dispose all subscriptions and timers
  void _disposeSubscriptions() {
    _compassSubscription?.cancel();
    _availabilitySubscription?.cancel();
    _calibrationSubscription?.cancel();
    _calibrationTimer?.cancel(); // Fix timer memory leak
    _calibrationTimer = null;
  }

  // === ZOOM FUNCTIONALITY ===
  
  /// Set zoom level
  void setZoomLevel(double zoom) {
    _zoomLevel.value = zoom.clamp(1.0, 3.0);
  }
  
  /// Reset zoom to default
  void resetZoom() {
    _zoomLevel.value = 1.0;
  }
  
  /// Toggle rotation lock - freeze entire compass state when locked
  void toggleRotationLock() {
    if (!_isRotationLocked.value) {
      // Locking: capture current complete state
      _lockedAngle.value = _rotationAngle.value;
      _lockedCompassData.value = _compassData.value;
      _lockedDirection.value = _currentDirection.value;
      _isRotationLocked.value = true;
    } else {
      // Unlocking: resume live rotation
      _isRotationLocked.value = false;
    }
    // Removed snackbar notification - icon change is enough visual feedback
  }
  
  /// Trigger zoom in from button
  void triggerZoomIn() {
    _zoomAction.value = 'in';
    // Reset action after a short delay to allow widget to process
    Future.delayed(const Duration(milliseconds: 50), () {
      _zoomAction.value = '';
    });
  }
  
  /// Trigger zoom out from button
  void triggerZoomOut() {
    _zoomAction.value = 'out';
    // Reset action after a short delay to allow widget to process
    Future.delayed(const Duration(milliseconds: 50), () {
      _zoomAction.value = '';
    });
  }
  
  /// Trigger reset zoom from button
  void triggerResetZoom() {
    _zoomAction.value = 'reset';
    resetZoom();
    // Reset action after a short delay to allow widget to process
    Future.delayed(const Duration(milliseconds: 50), () {
      _zoomAction.value = '';
    });
  }

  /// Get compass heading in text format
  String get headingText {
    final heading = _compassData.value.heading;
    // Show 1 decimal place for more precision
    return '${heading.toStringAsFixed(1)}°';
  }

  /// Get direction name in Vietnamese
  String get directionText {
    return _currentDirection.value?.vietnameseName ?? '--';
  }

  /// Get BaGua direction name
  String get baGuaText {
    return _currentDirection.value?.chineseName ?? '--';
  }

  /// Check if compass needs calibration
  bool get needsCalibration => _calibrationAccuracy.value < 0.5;

  /// Toggle 24 mountains display
  void toggle24Mountains() {
    _show24Mountains.value = !_show24Mountains.value;
  }
  
  /// Get current mountain (from 24 mountains)
  String getCurrentMountain() {
    if (_currentDirection.value == null) return '--';
    
    final heading = _compassData.value.heading;
    final direction = _currentDirection.value!;
    
    // Calculate which of the 3 mountains in this direction
    final directionRange = direction.endDegree > direction.startDegree
        ? direction.endDegree - direction.startDegree
        : (360 - direction.startDegree) + direction.endDegree;
    
    final mountainSize = directionRange / 3;
    
    double relativeHeading;
    if (direction.startDegree > direction.endDegree) {
      // Handle wrap around (North)
      relativeHeading = heading >= direction.startDegree 
          ? heading - direction.startDegree
          : (360 - direction.startDegree) + heading;
    } else {
      relativeHeading = heading - direction.startDegree;
    }
    
    final mountainIndex = (relativeHeading / mountainSize).floor().clamp(0, 2);
    return direction.mountains[mountainIndex];
  }
  
  // === SCREENSHOT FUNCTIONALITY ===
  
  /// Take screenshot of compass with metadata
  Future<void> takeCompassScreenshot() async {
    if (_isCapturingScreenshot.value) return; // Prevent multiple captures
    
    try {
      _isCapturingScreenshot.value = true;
      
      // No snackbar - using isCapturingScreenshot flag for UI indicator instead
      
      // Capture screenshot with optimized quality
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10), // GPU sync
        pixelRatio: 2.0, // High quality for sharing
      );
      
      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }
      
      // Generate filename with compass data
      final timestamp = DateTime.now();
      final heading = _compassData.value.heading.toInt();
      final direction = _currentDirection.value?.vietnameseName ?? 'Unknown';
      final filename = 'Compass_${heading}deg_${direction}_${timestamp.millisecondsSinceEpoch}.png';
      
      // Save to temp directory first
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/$filename';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(imageBytes);
      
      // Show share dialog
      await _showScreenshotShareDialog(tempFile, heading, direction);
      
    } catch (e) {
      // Screenshot failed
      Get.snackbar(
        'Lỗi chụp ảnh',
        'Không thể chụp ảnh la bàn: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 2),
        isDismissible: true,
      );
    } finally {
      _isCapturingScreenshot.value = false;
    }
  }
  
  /// Show screenshot share dialog with options
  Future<void> _showScreenshotShareDialog(File imageFile, int heading, String direction) async {
    // Get full direction info with BaGua name
    final directionInfo = _currentDirection.value;
    final fullDirectionText = directionInfo != null 
        ? 'Hướng: ${directionInfo.vietnameseName} (${directionInfo.chineseName})'
        : 'Hướng: $direction';
    
    // Get compass title and personal info
    final compassTitle = _compassMode.value == CompassMode.personal ? 'La bàn cá nhân' : 'La bàn cơ bản';
    
    String personalInfo = '';
    if (_compassMode.value == CompassMode.personal && _fengShuiResult.value != null) {
      final kua = _fengShuiResult.value!.personalInfo.kuaNumber;
      final fengShuiDirection = getCurrentFengShuiDirection();
      personalInfo = '\nQuái số: $kua';
      if (fengShuiDirection != null) {
        personalInfo += ' - ${fengShuiDirection.name}';
      }
    }
    
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF020931),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 320, // Fixed width for consistent layout
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title - Dynamic based on compass mode
                Text(
                  compassTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFCD45),
                    fontFamily: 'SVN Gilroy',
                  ),
                ),
                const SizedBox(height: 8),
                
                // Compass info with full direction and BaGua + personal info
                Text(
                  '$heading° - $fullDirectionText$personalInfo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontFamily: 'SVN Gilroy',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                
                // Preview image (maintain aspect ratio, show full image)
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCD45), width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain, // Show full image without cropping
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons with circle button style (same as BasicCompassView)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Save to Gallery button
                    _buildDialogCircleButton(
                      icon: Icons.save_alt,
                      label: 'Lưu ảnh',
                      onTap: () async {
                        Get.back(); // Close dialog
                        await _saveToGallery(imageFile, heading, direction);
                      },
                    ),
                    
                    // Share button
                    _buildDialogCircleButton(
                      icon: Icons.share,
                      label: 'Chia sẻ',
                      onTap: () async {
                        Get.back(); // Close dialog
                        await _shareScreenshot(imageFile, heading, direction);
                      },
                    ),
                    
                    // Close button
                    _buildDialogCircleButton(
                      icon: Icons.close,
                      label: 'Đóng',
                      onTap: () {
                        Get.back(); // Close dialog
                        // Clean up temp file
                        imageFile.delete().catchError((_) {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build dialog circle button with consistent styling (same as BasicCompassView)
  Widget _buildDialogCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circle button with gradient border (same as BasicCompassView)
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFDC24C),
                Color(0xFFFCF5D0),
                Color(0xFFD78F40),
                Color(0xFFFFFACA),
                Color(0xFFD78F40),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(1), // Inner border effect
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF101847), // Background #27326D equivalent
                  Color(0xFF303C7B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                borderRadius: BorderRadius.circular(99),
                onTap: onTap,
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFF5E29F),
                      Color(0xFFDEC87D),
                      Color(0xFFD3AA45),
                      Color(0xFFF2DC98),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Icon(
                    icon,
                    color: Colors.white, // Will be masked by gradient
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontFamily: 'SVN Gilroy',
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  /// Share screenshot with system share dialog
  Future<void> _shareScreenshot(File imageFile, int heading, String direction) async {
    try {
      // Get full direction info with BaGua name for sharing
      final directionInfo = _currentDirection.value;
      final fullDirectionText = directionInfo != null 
          ? '${directionInfo.vietnameseName} (${directionInfo.chineseName})'
          : direction;
      
      // Dynamic compass type for sharing message
      final compassType = _compassMode.value == CompassMode.personal ? 'La bàn cá nhân' : 'La bàn cơ bản';
      
      // Add personal info if available
      String personalText = '';
      if (_compassMode.value == CompassMode.personal && _fengShuiResult.value != null) {
        final personalInfo = _fengShuiResult.value!.personalInfo;
        final fengShuiDirection = getCurrentFengShuiDirection();
        personalText = '\nQuái số: ${personalInfo.kuaNumber}';
        if (fengShuiDirection != null) {
          personalText += ' - ${fengShuiDirection.name}';
        }
      }
      
      final String message = '$compassType: $heading° - Hướng: $fullDirectionText$personalText\nTừ ứng dụng La bàn Phong thuỷ';
      
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: message,
        subject: 'Ảnh $compassType - $heading° $fullDirectionText',
      );
      
      // Note: Share.shareXFiles doesn't return whether sharing was successful or cancelled
      // So we don't show a success message to avoid misleading the user
      
    } catch (e) {
      // Share failed
      Get.snackbar(
        'Lỗi chia sẻ',
        'Không thể chia sẻ ảnh: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      // Clean up temp file
      imageFile.delete().catchError((_) {});
    }
  }
  
  /// Save screenshot to device gallery using GAL package
  Future<void> _saveToGallery(File imageFile, int heading, String direction) async {
    try {
      // Check if GAL has access permission
      final bool hasAccess = await Gal.hasAccess();
      
      if (!hasAccess) {
        // Request access using GAL's built-in permission system
        final bool requestResult = await Gal.requestAccess();
        if (!requestResult) {
          Get.snackbar(
            'Cần quyền truy cập',
            'Vui lòng cấp quyền truy cập Photo Library để lưu ảnh',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.warning, color: Colors.white),
            duration: const Duration(seconds: 4),
          );
          return;
        }
      }
      
      // Generate descriptive filename with compass data
      final timestamp = DateTime.now();
      final cleanDirection = direction.replaceAll(' ', '_').replaceAll('/', '_');
      final filename = 'Compass_${heading}deg_${cleanDirection}_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.png';
      
      // Create temp file with custom name for GAL
      final Directory tempDir = await getTemporaryDirectory();
      final String customPath = '${tempDir.path}/$filename';
      final File customFile = await imageFile.copy(customPath);
      
      // Save to gallery using GAL package - automatically handles platform differences
      // This will save to Photos on iOS and Gallery/Pictures on Android
      await Gal.putImage(
        customFile.path,
        album: 'Compass', // Create album named "Compass"
      );
      
      // Clean up custom temp file
      await customFile.delete().catchError((_) {});
      
      // Success feedback with more specific message
      Get.snackbar(
        'Đã lưu ảnh thành công',
        Platform.isAndroid 
            ? 'Ảnh đã được lưu vào Gallery > Album "Compass"'
            : 'Ảnh đã được lưu vào Photos > Album "Compass"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
      
    } on GalException catch (e) {
      // Gallery save error: ${e.type}
      
      String errorMessage;
      switch (e.type) {
        case GalExceptionType.accessDenied:
          errorMessage = 'Không có quyền truy cập Photo Library. Vui lòng cấp quyền trong Settings.';
          break;
        case GalExceptionType.notEnoughSpace:
          errorMessage = 'Không đủ bộ nhớ để lưu ảnh.';
          break;
        case GalExceptionType.notSupportedFormat:
          errorMessage = 'Định dạng ảnh không được hỗ trợ.';
          break;
        case GalExceptionType.unexpected:
        default:
          errorMessage = 'Lỗi không xác định khi lưu ảnh.';
          break;
      }
      
      Get.snackbar(
        'Lỗi lưu ảnh',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 5),
      );
      
    } catch (e) {
      // Unexpected error during save
      Get.snackbar(
        'Lỗi lưu ảnh',
        'Không thể lưu ảnh: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } finally {
      // Clean up temp file after saving attempt
      imageFile.delete().catchError((_) {});
    }
  }
}