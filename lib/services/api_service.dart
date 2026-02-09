import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../data/config/api_config.dart';
import '../data/exceptions/api_exception.dart';

/// Base API Service for all HTTP requests
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// GET Request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      
      final response = await _client
          .get(uri, headers: headers ?? ApiConfig.headers())
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    }
  }

  /// POST Request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      
      final response = await _client
          .post(
            uri,
            headers: headers ?? ApiConfig.headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    }
  }

  /// PUT Request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      
      final response = await _client
          .put(
            uri,
            headers: headers ?? ApiConfig.headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    }
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      
      final response = await _client
          .delete(uri, headers: headers ?? ApiConfig.headers())
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    }
  }

  /// Build URI with base URL and query parameters
  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final url = '${ApiConfig.baseUrl}$endpoint';
    final uri = Uri.parse(url);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters);
    }

    return uri;
  }

  /// Handle HTTP Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Try to decode response body
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      // If can't decode, create a simple error object
      body = {'message': response.body};
    }

    // Success
    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }

    // Error handling based on status code
    final message = body['message'] as String? ?? 'An error occurred';

    switch (statusCode) {
      case 400:
        throw BadRequestException(message);
      case 401:
        throw UnauthorizedException(message);
      case 403:
        throw ForbiddenException(message);
      case 404:
        throw NotFoundException(message);
      case 422:
        throw ValidationException(
          message: message,
          errors: body['errors'] as Map<String, dynamic>?,
        );
      case 500:
      case 502:
      case 503:
        throw ServerException(message, statusCode);
      default:
        throw HttpException(message: message, statusCode: statusCode);
    }
  }

  /// Dispose (clean up)
  void dispose() {
    _client.close();
  }
}