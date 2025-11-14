import 'package:flutter/material.dart';

class ChatUITheme {
  // Colors - Updated to match app's gold/navy theme
  static const Color primaryColor = Color(0xFF2C3E50); // Navy like app
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color userMessageColor = Color(0xFFFDC24C); // Gold like app
  static const Color aiMessageColor = Color(0xFFFFFFFF);

  // Text Styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle appBarSubtitleStyle = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );

  static const TextStyle userMessageTextStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF2C3E50), // Dark text on gold background
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle aiMessageTextStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF333333),
    height: 1.4,
  );

  static const TextStyle timestampTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle inputHintStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );
}