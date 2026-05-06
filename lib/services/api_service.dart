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

    _dio.interceptors.add(LogInterceptor(
      requestBody:  true,
      responseBody: true,
    ));
  }

  // GET — returns Map
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

  // GET — returns List directly (for water-intakes, sleeps)
  Future<List<dynamic>> getAsList(
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
      final data = response.data;
      // Backend returns array directly
      if (data is List) return data;
      // Backend wraps in { data: [...] }
      if (data is Map && data['data'] is List) return data['data'] as List;
      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST
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

  // PUT
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

  // PATCH
  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: body,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE
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

  // Convert DioException to ApiException
  ApiException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return NetworkException();
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return TimeoutException();
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode;
      final data       = e.response?.data;

      String message = 'An error occurred';
      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
      }

      switch (statusCode) {
        case 400: return BadRequestException(message);
        case 401: return UnauthorizedException(message);
        case 403: return ForbiddenException(message);
        case 404: return NotFoundException(message);
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
          return HttpException(message: message, statusCode: statusCode ?? 0);
      }
    }

    return ApiException(message: e.message ?? 'An unexpected error occurred');
  }

  void dispose() => _dio.close();
}