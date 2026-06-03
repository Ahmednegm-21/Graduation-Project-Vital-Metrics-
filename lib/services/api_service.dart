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

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    );
  }

  // =====================================================
  // GET
  // =====================================================

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options:
            headers != null
                ? Options(headers: headers)
                : null,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================
  // GET AS LIST
  // =====================================================

  Future<List<dynamic>> getAsList(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options:
            headers != null
                ? Options(headers: headers)
                : null,
      );

      final data = response.data;

      if (data is List) {
        return data;
      }

      if (data is Map) {
        if (data['data'] is List) {
          return List<dynamic>.from(
            data['data'],
          );
        }

        if (data['activities'] is List) {
          return List<dynamic>.from(
            data['activities'],
          );
        }

        if (data['items'] is List) {
          return List<dynamic>.from(
            data['items'],
          );
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================
  // POST
  // =====================================================

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options:
            headers != null
                ? Options(headers: headers)
                : null,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================
  // PUT
  // =====================================================

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options:
            headers != null
                ? Options(headers: headers)
                : null,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================
  // PATCH
  // =====================================================

  Future<dynamic> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: body,
        options:
            headers != null
                ? Options(headers: headers)
                : null,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================
  // DELETE
  // =====================================================

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options:
            headers != null
                ? Options(headers: headers)
                : null,
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // =====================================================
  // ERROR HANDLER
  // =====================================================

  ApiException _handleDioError(
    DioException e,
  ) {
    if (e.type ==
            DioExceptionType.connectionError ||
        e.type ==
            DioExceptionType.unknown) {
      return NetworkException();
    }

    if (e.type ==
            DioExceptionType.connectionTimeout ||
        e.type ==
            DioExceptionType.receiveTimeout ||
        e.type ==
            DioExceptionType.sendTimeout) {
      return TimeoutException();
    }

    if (e.type ==
        DioExceptionType.badResponse) {
      final statusCode =
          e.response?.statusCode;

      final data =
          e.response?.data;

      String message =
          'An error occurred';

      if (data is Map) {
        final rawMessage =
            data['message'];

        if (rawMessage is String) {
          message = rawMessage;
        } else if (rawMessage
            is List) {
          message =
              rawMessage.join(', ');
        } else if (rawMessage !=
            null) {
          message =
              rawMessage.toString();
        }
      }

      switch (statusCode) {
        case 400:
          return BadRequestException(
            message,
          );

        case 401:
          return UnauthorizedException(
            message,
          );

        case 403:
          return ForbiddenException(
            message,
          );

        case 404:
          return NotFoundException(
            message,
          );

        case 422:
          return ValidationException(
            message: message,
            errors:
                data is Map<String, dynamic> &&
                        data['errors']
                            is Map<String,
                                dynamic>
                    ? data['errors']
                        as Map<String,
                            dynamic>
                    : null,
          );

        case 500:
        case 502:
        case 503:
          return ServerException(
            message,
            statusCode,
          );

        default:
          return HttpException(
            message: message,
            statusCode:
                statusCode ?? 0,
          );
      }
    }

    return ApiException(
      message:
          e.message ??
          'An unexpected error occurred',
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  void dispose() {
    _dio.close();
  }
}