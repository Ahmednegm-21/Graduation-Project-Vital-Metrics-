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

/// Network/Connection Exceptions
class NetworkException extends ApiException {
  NetworkException([String? message])
      : super(
          message: message ?? 'No internet connection. Please check your network.',
        );
}

/// Timeout Exception
class TimeoutException extends ApiException {
  TimeoutException([String? message])
      : super(
          message: message ?? 'Request timed out. Please try again.',
        );
}

/// Server Error
class ServerException extends ApiException {
  ServerException([String? message, int? statusCode])
      : super(
          message: message ?? 'Server error. Please try again later.',
          statusCode: statusCode,
        );
}

/// Unauthorized (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException([String? message])
      : super(
          message: message ?? 'Session expired. Please login again.',
          statusCode: 401,
        );
}

/// Forbidden (403)
class ForbiddenException extends ApiException {
  ForbiddenException([String? message])
      : super(
          message: message ?? 'You don\'t have permission to access this.',
          statusCode: 403,
        );
}

/// Not Found (404)
class NotFoundException extends ApiException {
  NotFoundException([String? message])
      : super(
          message: message ?? 'The requested resource was not found.',
          statusCode: 404,
        );
}

/// Validation Error (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String? message,
    this.errors,
  }) : super(
          message: message ?? 'Validation failed.',
          statusCode: 422,
          data: errors,
        );
}

/// Bad Request (400)
class BadRequestException extends ApiException {
  BadRequestException([String? message])
      : super(
          message: message ?? 'Invalid request.',
          statusCode: 400,
        );
}

/// Generic HTTP Exception
class HttpException extends ApiException {
  HttpException({
    required super.message,
    required int super.statusCode,
  });
}