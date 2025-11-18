import 'package:shared_preferences/shared_preferences.dart';

/// Simple auth storage for tokens
class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save auth token
  static Future<void> saveToken(String token) async {
    await init();
    await _prefs!.setString(_tokenKey, token);
  }

  /// Get auth token
  static String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  /// Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    await init();
    await _prefs!.setString(_refreshTokenKey, token);
  }

  /// Get refresh token
  static String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
  }

  /// Clear all auth data
  static Future<void> clearAuth() async {
    await init();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_refreshTokenKey);
  }

  /// Check if has token
  static bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// Set a test token for development - matching Lich Am format
  static Future<void> setTestToken() async {
    // Try some possible tokens that might work with the API
    const testTokens = [
      'lao_dai_token_2024',
      'xemlicham_api_key',
      'labanphongthuy_token',
      'lao_dai_api_secret',
      'test-api-token-2024',
    ];

    // Try the first token for now
    const testToken = 'lao_dai_token_2024';
    await saveToken(testToken);
    print('AuthStorage: Using test token: $testToken');
  }
}