import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;

import 'env_config.dart';
import '../utils/logger_utils.dart';
import '../utils/network_utils.dart';

/// API Provider - Exact copy from working lich-am version
class ApiProvider extends GetxService {
  late Dio _dio;
  final String baseUrl = '';
  final bool enableLogging;

  // Singleton pattern - exact match with lich-am
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;

  ApiProvider._internal({
    this.enableLogging = true, // Enable logging for debugging
  }) {
    _init();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    // Dio already initialized in constructor
  }

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl.isEmpty ? EnvConfig.apiUrl : baseUrl,
        connectTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
        receiveTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
        sendTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Match lich-am logging exactly
    if (enableLogging && !EnvConfig.isProduction) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        logPrint: (obj) => print('[DIO] $obj'),
      ));
    }

    // Add interceptors - exact copy from lich-am but skip auth
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Skip auth token - lich-am also may not have valid token
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Match lich-am error handling exactly
        LoggerUtils.error('Dio Error: $e');
        return handler.next(e);
      },
    ));
  }

  // POST request - EXACT copy from lich-am
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      // Check connectivity if needed - EXACT match with lich-am
      if (!NetworkUtils.hasConnection) {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: 'No internet connection',
          type: DioExceptionType.connectionError,
        );
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      LoggerUtils.error('POST Error: $e');
      rethrow;
    }
  }

  // GET request - simplified from lich-am
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      LoggerUtils.error('GET Error: $e');
      rethrow;
    }
  }

  // Handle Dio errors - EXACT copy from lich-am
  dynamic _handleError(DioException e) {
    LoggerUtils.error('Dio Error: $e');
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw e; // Rethrow timeout errors
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400:
          case 401:
          case 403:
          case 404:
          case 409:
          case 500:
            break; // Log handled above
        }
        throw e; // Rethrow response errors
      case DioExceptionType.cancel:
        throw e;
      case DioExceptionType.connectionError:
        throw e;
      case DioExceptionType.badCertificate:
        throw e;
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          throw e;
        }
        throw e;
    }
  }

  /// Clean up resources
  void dispose() {
    _dio.close(force: true);
  }
}

/// API Exception types
enum ApiExceptionType {
  noInternet,
  timeout,
  httpError,
  parseError,
  cancelled,
  unknown,
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiExceptionType type;
  final dynamic details;

  const ApiException({
    required this.message,
    required this.statusCode,
    required this.type,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Type: $type)';
  }

  /// Check if this is a network error
  bool get isNetworkError => type == ApiExceptionType.noInternet;

  /// Check if this is a server error
  bool get isServerError => statusCode >= 500;

  /// Check if this is a client error
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case ApiExceptionType.noInternet:
        return 'Không có kết nối mạng. Vui lòng kiểm tra và thử lại.';
      case ApiExceptionType.timeout:
        return 'Kết nối quá chậm. Vui lòng thử lại.';
      case ApiExceptionType.cancelled:
        return 'Yêu cầu đã bị hủy.';
      default:
        return message;
    }
  }
}