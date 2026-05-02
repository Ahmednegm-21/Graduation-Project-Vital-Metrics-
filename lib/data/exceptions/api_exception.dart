/// Base API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

/// No internet connection
class NetworkException extends ApiException {
  NetworkException([String? message])
      : super(
          message: message ?? 'No internet connection. Please check your network and try again.',
        );
}

/// Request timed out
class TimeoutException extends ApiException {
  TimeoutException([String? message])
      : super(
          message: message ?? 'The request took too long. Please try again.',
        );
}

/// 500 / 502 / 503
class ServerException extends ApiException {
  ServerException([String? message, int? statusCode])
      : super(
          message: message != null && message != 'Internal Server Error'
              ? message
              : 'Something went wrong. Please try again.',
          statusCode: statusCode,
        );
}

/// 401
class UnauthorizedException extends ApiException {
  UnauthorizedException([String? message])
      : super(
          message: message ?? 'Your session has expired. Please sign in again.',
          statusCode: 401,
        );
}

/// 403
class ForbiddenException extends ApiException {
  ForbiddenException([String? message])
      : super(
          message: message ?? 'You don\'t have permission to do this.',
          statusCode: 403,
        );
}

/// 404
class NotFoundException extends ApiException {
  NotFoundException([String? message])
      : super(
          message: message ?? 'The requested resource was not found.',
          statusCode: 404,
        );
}

/// 422
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String? message,
    this.errors,
  }) : super(
          message: message ?? 'Please check your information and try again.',
          statusCode: 422,
          data: errors,
        );
}

/// 400
class BadRequestException extends ApiException {
  BadRequestException([String? message])
      : super(
          message: message ?? 'Invalid request. Please check your information.',
          statusCode: 400,
        );
}

/// Generic HTTP
class HttpException extends ApiException {
  HttpException({
    required super.message,
    required int super.statusCode,
  });
}