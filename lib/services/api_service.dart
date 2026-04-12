import 'package:dio/dio.dart';
import '../data/config/api_config.dart';
import '../data/exceptions/api_exception.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectionTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.headers(),
      ),
    );

    // Log requests/responses in debug mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  /// GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Convert DioException to ApiException
  ApiException _handleDioError(DioException e) {
    // No internet / connection failed
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return NetworkException();
    }

    // Request timed out
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return TimeoutException();
    }

    // Server returned an error response
    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final data       = e.response?.data;

      // Try to extract message from response body
      String message = 'An error occurred';
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
      }

      switch (statusCode) {
        case 400:
          return BadRequestException(message);
        case 401:
          return UnauthorizedException(message);
        case 403:
          return ForbiddenException(message);
        case 404:
          return NotFoundException(message);
        case 422:
          return ValidationException(
            message: message,
            errors: data is Map<String, dynamic>
                ? data['errors'] as Map<String, dynamic>?
                : null,
          );
        case 500:
        case 502:
        case 503:
          return ServerException(message, statusCode);
        default:
          return HttpException(
            message: message,
            statusCode: statusCode ?? 0,
          );
      }
    }

    return ApiException(message: e.message ?? 'An unexpected error occurred');
  }

  /// Dispose Dio instance
  void dispose() {
    _dio.close();
  }
}