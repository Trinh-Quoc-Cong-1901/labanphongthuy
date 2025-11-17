/// Environment configuration - EXACT match with lich-am
class EnvConfig {
  // API Base URL - exact match with lich-am
  static const String apiUrl = 'https://cloudrun-v2.xemlicham.com';

  // Timeout in milliseconds - exact match with lich-am
  static int get apiTimeout => 30000;

  // Environment settings - exact match with lich-am
  static const String environment = 'development';
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';

  // Model Configuration - Match lich-am exactly
  static const String defaultModel = 'openai';

  // API Endpoints
  static const String chatEndpoint = '/api/chat';
  static const String modelsEndpoint = '/api/models';

  // Debug Settings - simplified to match needs
  static const bool enableApiLogging = false; // Match lich-am
  static const bool enableDebugMode = true;

  // Headers - Match Lich Am app exactly
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get full API endpoint URL
  static String getEndpoint(String path) {
    return '$apiUrl$path';
  }

  /// Get chat endpoint URL
  static String get chatUrl => getEndpoint(chatEndpoint);

  /// Get models endpoint URL
  static String get modelsUrl => getEndpoint(modelsEndpoint);
}