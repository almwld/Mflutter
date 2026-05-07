import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// =============================================================================
/// ApiClient - عميل API
/// =============================================================================
/// يتعامل مع طلبات HTTP
/// =============================================================================

class ApiClient {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String>? defaultHeaders;

  const ApiClient({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // طلب GET
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنفيذ طلب GET
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await http
          .get(
            uri,
            headers: _mergeHeaders(headers),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت');
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // طلب POST
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنفيذ طلب POST
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .post(
            uri,
            headers: _mergeHeaders(headers, contentType: 'application/json'),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت');
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // طلب PUT
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنفيذ طلب PUT
  Future<ApiResponse> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .put(
            uri,
            headers: _mergeHeaders(headers, contentType: 'application/json'),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت');
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // طلب DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  /// تنفيذ طلب DELETE
  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .delete(
            uri,
            headers: _mergeHeaders(headers),
          )
          .timeout(timeout);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error('لا يوجد اتصال بالإنترنت');
    } on TimeoutException {
      return ApiResponse.error('انتهت مهلة الاتصال');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  /// بناء URI
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// دمج الترويسات
  Map<String, String> _mergeHeaders(
    Map<String, String>? headers, {
    String? contentType,
  }) {
    final merged = <String, String>{};
    if (defaultHeaders != null) {
      merged.addAll(defaultHeaders!);
    }
    if (headers != null) {
      merged.addAll(headers);
    }
    if (contentType != null) {
      merged['Content-Type'] = contentType;
    }
    return merged;
  }

  /// معالجة الاستجابة
  ApiResponse _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data);
      } catch (_) {
        return ApiResponse.success(response.body);
      }
    } else {
      return ApiResponse.error(
        'خطأ في الخادم: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}

/// =============================================================================
/// ApiResponse - استجابة API
/// =============================================================================

class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? error;
  final int? statusCode;

  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(dynamic data) => ApiResponse._(
        isSuccess: true,
        data: data,
      );

  factory ApiResponse.error(String error, {int? statusCode}) => ApiResponse._(
        isSuccess: false,
        error: error,
        statusCode: statusCode,
      );
}