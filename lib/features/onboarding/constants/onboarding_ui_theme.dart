import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingUITheme {
  static const Color backgroundColor = Color(0xFF0A1628); // Dark navy background
  static const Color primaryTextColor = Colors.white;
  static const Color buttonColor = Color(0xFF4C5CE6); // Blue button color
  static const Color inactiveIndicatorColor = Color(0xFF374151);
  static const Color activeIndicatorColor = Color(0xFFFDC24C); // Golden color

  // Text styles
  static TextStyle get titleTextStyle => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: primaryTextColor,
    height: 1.2,
  );

  static TextStyle get descriptionTextStyle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: primaryTextColor.withOpacity(0.8),
    height: 1.4,
  );

  static TextStyle get buttonTextStyle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Button styles
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    color: buttonColor,
    borderRadius: BorderRadius.circular(24.r),
  );

  // Page indicator styles
  static double get indicatorWidth => 32.w;
  static double get indicatorHeight => 4.h;
  static double get indicatorSpacing => 8.w;

  // Spacing
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: 24.w);
  static double get contentSpacing => 48.h;
}