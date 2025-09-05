import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/compass_responsive.dart';
import '../../../config/assets_path.dart';

import '../controllers/compass_controller.dart';
import '../constants/compass_theme.dart';
import 'animated_compass_rotation.dart';

/// Ultra-optimized zoomable compass with InteractiveViewer and gesture controls
class ZoomableImageCompass extends StatefulWidget {
  final double size;
  final bool showFengShui;
  final bool show24Mountains;
  final double minZoom;
  final double maxZoom;

  const ZoomableImageCompass({
    super.key,
    this.size = 300,
    this.showFengShui = false,
    this.show24Mountains = true,
    this.minZoom = 1.0,
    this.maxZoom = 3.0,
  });

  @override
  State<ZoomableImageCompass> createState() => _ZoomableImageCompassState();
}

class _ZoomableImageCompassState extends State<ZoomableImageCompass> 
    with TickerProviderStateMixin {
  // Static compass image widget - created once, never rebuilt
  late final Widget _staticCompassImage;
  
  // Zoom control
  final TransformationController _transformationController = TransformationController();
  late AnimationController _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;
  
  // Current zoom level for UI feedback
  double _currentZoom = 1.0;
  
  @override
  void initState() {
    super.initState();
    _staticCompassImage = _createStaticCompassImage();
    
    // Initialize zoom animation controller
    _zoomAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Listen to transformation changes
    _transformationController.addListener(_onTransformationChanged);
    
    // Listen to zoom trigger from controller
    _listenToZoomTrigger();
  }

  void _listenToZoomTrigger() {
    final controller = Get.find<CompassController>();
    // Listen to zoom action changes - process each action independently
    controller.zoomActionObs.listen((action) {
      if (mounted && action != null && action.isNotEmpty) {
        switch (action) {
          case 'in':
            zoomIn();
            break;
          case 'out':
            zoomOut();
            break;
          case 'reset':
            resetZoom();
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final matrix = _transformationController.value;
    final newZoom = matrix.getMaxScaleOnAxis();
    
    // Only update if zoom changed significantly (performance optimization)
    if ((_currentZoom - newZoom).abs() > 0.01) {
      _currentZoom = newZoom;
      
      // Update controller zoom state (no setState needed since no UI depends on it)
      final controller = Get.find<CompassController>();
      controller.setZoomLevel(newZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompassController>();
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Zoomable compass with rotation - wrap with GestureDetector for double-tap
          GestureDetector(
            onDoubleTap: () {
              final currentZoom = _transformationController.value.getMaxScaleOnAxis();
              final targetZoom = currentZoom > 1.5 ? 1.0 : 2.0;
              _animateZoomTo(targetZoom);
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: widget.minZoom,
              maxScale: widget.maxZoom,
              constrained: true, // Keep compass constrained to viewport
              // Disable panning - only allow zoom
              panEnabled: false, // IMPORTANT: No dragging/panning allowed
              scaleEnabled: true, // Keep zoom enabled
              // Optimize performance
              clipBehavior: Clip.none,
              // No boundary margin needed since panning is disabled
              boundaryMargin: EdgeInsets.zero,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Rotating compass image with smooth animation
                  Obx(() => SmoothRotationTransition(
                    angle: controller.isRotationLocked 
                        ? controller.lockedAngle * math.pi / 180
                        : controller.rotationAngle * math.pi / 180,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutQuad,
                    child: _staticCompassImage,
                  )),
                  
                  // Fixed crosshair lines - zoom with compass but don't rotate
                  _buildCrosshairLines(),
                  
                  // Triangle indicator at top - zoom with compass but don't rotate
                  _buildTriangleIndicator(),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }



  /// Create static compass image - called once only in initState
  Widget _createStaticCompassImage() {
    // Basic compass always uses base_compass.png
    // Personal compass uses PersonalZoomableImageCompass for dynamic selection
    final imagePath = CompassPath.baseCompass;
        
    return RepaintBoundary( // Critical: prevents repaints during rotation
      child: Image.asset(
        imagePath,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain, // Keep aspect ratio without cropping
        // Optimize for device resolution - higher cache for zoom
        cacheWidth: (widget.size * 4).round(), // 4x for crisp zoom rendering
        cacheHeight: (widget.size * 4).round(),
        // Handle loading
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          return wasSynchronouslyLoaded 
              ? child 
              : AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: child,
                );
        },
        // Handle errors
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      ),
    );
  }

  /// Build error widget when image fails to load
  Widget _buildErrorWidget() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: CompassTheme.cardBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: CompassTheme.borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: CompassTheme.secondaryTextColor,
              size: widget.size * 0.1,
            ),
            SizedBox(height: 8.ch),
            Text(
              'Compass\nImage\nError',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CompassTheme.secondaryTextColor,
                fontSize: widget.size * 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build fixed crosshair lines - 0°-180° and 90°-270°
  Widget _buildCrosshairLines() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Vertical line: 0° to 180° (North to South)
          Positioned(
            left: widget.size / 2 - 1, // Center horizontally, minus half line width
            top: 0,
            child: Container(
              width: 2,
              height: widget.size,
              color: const Color(0xFFAC3737).withOpacity(0.7),
            ),
          ),
          
          // Horizontal line: 90° to 270° (East to West)
          Positioned(
            left: 0,
            top: widget.size / 2 - 1, // Center vertically, minus half line width
            child: Container(
              width: widget.size,
              height: 2,
              color: const Color(0xFFAC3737).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build triangle indicator at top (0° position) using design image asset
  Widget _buildTriangleIndicator() {
    return Positioned(
      top: -20.ch, // Push triangle higher up
      left: widget.size / 2 - 14.cw, // Center horizontally, minus half triangle width
      child: Image.asset(
        CompassPath.triangleIndicator,
        width: 28.cw,
        height: 28.ch,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if image fails to load
          return Container(
            width: 28.cw,
            height: 28.ch,
            decoration: BoxDecoration(
              color: const Color(0xFF771718),
              borderRadius: BorderRadius.circular(2.cr),
              border: Border.all(
                width: 1,
                color: const Color(0xFFF5E29F),
              ),
            ),
          );
        },
      ),
    );
  }

  // Public methods for external zoom control
  void zoomIn() {
    final currentZoom = _transformationController.value.getMaxScaleOnAxis();
    final targetZoom = math.min(currentZoom * 1.5, widget.maxZoom);
    _animateZoomTo(targetZoom);
  }

  void zoomOut() {
    final currentZoom = _transformationController.value.getMaxScaleOnAxis();
    final targetZoom = math.max(currentZoom / 1.5, widget.minZoom);
    _animateZoomTo(targetZoom);
  }

  void resetZoom() {
    _animateZoomTo(1.0);
  }
  
  // Get current zoom level
  double getCurrentZoom() {
    return _transformationController.value.getMaxScaleOnAxis();
  }
  
  // Quick zoom to specific level
  void zoomTo(double zoom) {
    _animateZoomTo(zoom.clamp(widget.minZoom, widget.maxZoom));
  }

  // Animate zoom to specific level with smooth transition - zoom to center
  void _animateZoomTo(double targetZoom) {
    final currentMatrix = _transformationController.value;
    final currentZoom = currentMatrix.getMaxScaleOnAxis();
    
    if ((targetZoom - currentZoom).abs() < 0.01) return;

    // Calculate center point of the compass
    final centerX = widget.size / 2;
    final centerY = widget.size / 2;
    
    // Get current translation
    final currentTranslation = currentMatrix.getTranslation();
    
    // Calculate new translation to keep center point fixed during zoom
    final zoomRatio = targetZoom / currentZoom;
    final newTranslationX = currentTranslation.x + (centerX - currentTranslation.x) * (1 - zoomRatio);
    final newTranslationY = currentTranslation.y + (centerY - currentTranslation.y) * (1 - zoomRatio);
    
    // Create target matrix that zooms into center
    final targetMatrix = Matrix4.identity()
      ..translate(newTranslationX, newTranslationY)
      ..scale(targetZoom);

    _zoomAnimation = Matrix4Tween(
      begin: currentMatrix,
      end: targetMatrix,
    ).animate(CurvedAnimation(
      parent: _zoomAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _zoomAnimationController.reset();
    _zoomAnimationController.forward();

    _zoomAnimation!.addListener(() {
      _transformationController.value = _zoomAnimation!.value;
    });
  }
}