import 'dart:ui' as ui;

/// Compass-specific responsive system based on 375x812 design baseline
/// Similar to numerology responsive but specific for compass feature
class CompassResponsive {
  // Design baseline dimensions (iPhone X/11/12 standard)
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;
  
  // Get current screen dimensions
  static double get screenWidth => ui.window.physicalSize.width / ui.window.devicePixelRatio;
  static double get screenHeight => ui.window.physicalSize.height / ui.window.devicePixelRatio;
  
  // Scale factors
  static double get scaleWidth => screenWidth / designWidth;
  static double get scaleHeight => screenHeight / designHeight;
  static double get scaleText => scaleWidth; // Use width-based scaling for text
}

/// Extension for compass-specific responsive values
extension CompassResponsiveExtension on num {
  /// Compass Scaled Pixel (for font sizes, icon sizes)
  double get csp => this * CompassResponsive.scaleText;
  
  /// Compass Width (for horizontal spacing, width values)
  double get cw => this * CompassResponsive.scaleWidth;
  
  /// Compass Height (for vertical spacing, height values)  
  double get ch => this * CompassResponsive.scaleHeight;
  
  /// Compass Radius (for border radius, circular elements)
  double get cr => this * CompassResponsive.scaleWidth;
}