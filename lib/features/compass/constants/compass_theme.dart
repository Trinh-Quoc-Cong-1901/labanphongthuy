import 'package:flutter/material.dart';

/// Compass theme constants matching Thuoc Lo Ban design system
class CompassTheme {
  CompassTheme._();

  // === COLOR SCHEME ===

  /// Primary background color - Deep navy blue matching Thuoc Lo Ban
  static const Color primaryBackground = Color(0xFF030D4C);

  /// Card and container background - Same as primary for seamless design
  static const Color cardBackground = Color(0xFF030D4C);

  /// Text colors
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFC7C7C7);
  static const Color inputTextColor = Colors.black;

  /// Input and form colors
  static const Color inputBackground = Colors.white;
  static const Color inputBorderColor = Colors.transparent;

  /// Compass specific colors
  static const Color compassAccentColor =
      Color(0xFFFFCD45); // Yellow/gold for center
  static const Color northIndicatorColor =
      Color(0xFFFF1616); // Bright red for north
  static const Color compassRingColor = Colors.white;

  /// Feng Shui colors
  static const Color goodDirectionColor = Color(0xFF00E8E8); // Bright cyan
  static const Color badDirectionColor = Color(0xFFFF1616); // Bright red
  static const Color neutralDirectionColor = Color(0xFFC7C7C7); // Light gray

  /// Status colors
  static const Color successColor = Color(0xFF00E8E8);
  static const Color errorColor = Color(0xFFFF1616);
  static const Color warningColor = Color(0xFFFFCD45);

  /// Transparent colors
  static const Color borderColor = Colors.white;
  static const Color dividerColor = Color(0x80FFFFFF); // 50% opacity white

  // === TYPOGRAPHY ===

  /// App title style
  static const TextStyle appTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
  );

  /// Section title style
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
  );

  /// Main header style
  static const TextStyle headerStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: primaryTextColor,
  );

  /// Sub header style
  static const TextStyle subHeaderStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: inputTextColor, // Black on colored backgrounds
  );

  /// Body text style
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: primaryTextColor,
    height: 1.5,
  );

  /// Body secondary text style
  static const TextStyle bodySecondaryStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: primaryTextColor,
  );

  /// Input text style
  static const TextStyle inputStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: inputTextColor,
  );

  /// Compass heading style (large numbers)
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );

  /// Compass direction style
  static const TextStyle directionStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  /// Compass small labels style
  static const TextStyle labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );

  /// Button text style
  static const TextStyle buttonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
  );

  // === LAYOUT DIMENSIONS ===

  /// Standard spacing values
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  /// Container dimensions
  static const double appBarHeight = 60.0;
  static const double bottomInfoHeight = 80.0;
  static const double cardPadding = 16.0;

  /// Border radius values
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 10.0;
  static const double borderRadiusL = 16.0;

  /// Icon sizes
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;

  // === COMPONENT STYLES ===

  /// AppBar decoration
  static BoxDecoration get appBarDecoration => const BoxDecoration(
        color: primaryBackground,
      );

  /// Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(borderRadiusM),
        border: Border.all(color: borderColor, width: 1),
      );

  /// Input decoration
  static InputDecoration get inputDecoration => InputDecoration(
        filled: true,
        fillColor: inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusM),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingM,
          vertical: spacingS,
        ),
        isDense: true,
      );

  /// Button decoration
  static BoxDecoration get buttonDecoration => BoxDecoration(
        color: compassAccentColor,
        borderRadius: BorderRadius.circular(borderRadiusM),
      );

  /// Compass container decoration
  static BoxDecoration get compassDecoration => BoxDecoration(
        color: cardBackground,
        shape: BoxShape.circle,
        border: Border.all(color: compassRingColor, width: 2),
      );

  // === ANIMATION DURATIONS ===

  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration scrollAnimation = Duration(milliseconds: 800);

  // === COMPASS SPECIFIC ===

  /// Compass colors for different feng shui directions
  static Color getFengShuiColor(bool isGood) {
    return isGood ? goodDirectionColor : badDirectionColor;
  }

  /// Get direction text style based on feng shui result
  static TextStyle getDirectionTextStyle(bool isGood) {
    return directionStyle.copyWith(
      color: isGood ? goodDirectionColor : badDirectionColor,
    );
  }

  /// Get calibration color based on accuracy
  static Color getCalibrationColor(double accuracy) {
    if (accuracy < 0.3) return errorColor;
    if (accuracy < 0.7) return warningColor;
    return successColor;
  }
}
