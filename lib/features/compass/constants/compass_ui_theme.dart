import 'package:flutter/material.dart';
import '../utils/compass_responsive.dart';

/// Compass UI Theme - shared with numerology feature
/// Using SVN Gilroy font family and consistent styling
class CompassUITheme {
  // Private constructor to prevent instantiation
  CompassUITheme._();

  // Background colors
  static const Color backgroundColor = Color(0xFF020931);
  static const Color cardBackground = Color(0xFF040F4E);

  // Text colors
  static const Color primaryTextColor = Colors.white;
  static const Color cardLabelColor = Color(0xFFFFEFC4);

  // Gradient colors for card border
  static const List<Color> cardBorderGradient = [
    Color(0xFFFDC24C),
    Color(0xFFFCF5D0),
    Color(0xFFD78F40),
    Color(0xFFFFFFACA),
    Color(0xFFD78F40),
  ];

  // Card styling - using compass responsive system (375x812 baseline)
  static double get cardBorderRadius => 16.0.cr;
  static double get cardSpacing => 16.0.cw;
  static double get cardVerticalPadding => 24.0.ch;
  static double get cardImageSize => 120.0.ch;
  static double get cardImageTextSpacing => 12.0.ch;

  // Layout spacing - using compass responsive system
  static double get screenPadding => 16.0.cw;
  static double get titleDescriptionSpacing => 15.0.ch;
  static double get descriptionCardsSpacing => 25.0.ch;

  // Font sizes - using compass scaled pixels
  static double get appBarTitleSize => 20.0.csp;
  static double get descriptionTextSize => 18.0.csp;
  static double get cardLabelSize => 18.0.csp;

  // Font weights
  static const FontWeight appBarTitleWeight = FontWeight.bold;
  static const FontWeight descriptionWeight = FontWeight.w500;
  static const FontWeight cardLabelWeight = FontWeight.bold;

  // Text styles - using ScreenUtil getters
  static TextStyle get appBarTitleStyle => TextStyle(
        fontSize: appBarTitleSize,
        fontWeight: appBarTitleWeight,
        color: primaryTextColor,
        fontFamily: 'SVN Gilroy', // Same as numerology feature
      );

  static TextStyle get descriptionTextStyle => TextStyle(
        fontSize: descriptionTextSize,
        fontWeight: descriptionWeight,
        color: primaryTextColor,
        fontFamily: 'SVN Gilroy',
      );

  static TextStyle get cardLabelStyle => TextStyle(
        fontSize: cardLabelSize,
        fontWeight: cardLabelWeight,
        color: cardLabelColor,
        fontFamily: 'SVN Gilroy',
      );

  // Note: Decorations will be created inline with ScreenUtil for responsiveness
}
