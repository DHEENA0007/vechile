import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiService {
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static String? get token => _token;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Token $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    String url = '${AppConfig.baseUrl}$endpoint';
    if (params != null && params.isNotEmpty) {
      url += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    }

    final response = await http.get(Uri.parse(url), headers: _headers);
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.patch(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
      headers: _headers,
    );
    if (response.statusCode == 204) {
      return {'success': true};
    }
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> multipartPost(
    String endpoint, {
    Map<String, String>? fields,
    File? file,
    String fileField = 'image',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConfig.baseUrl}$endpoint'),
    );

    if (_token != null) {
      request.headers['Authorization'] = 'Token $_token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (file != null) {
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is List) {
        return {'results': body, 'success': true};
      }
      return body is Map<String, dynamic>
          ? body
          : {'data': body, 'success': true};
    } else if (response.statusCode == 401) {
      throw ApiException(
        'Unauthorized. Please login again.',
        response.statusCode,
      );
    } else {
      String message = 'Something went wrong';
      if (body is Map) {
        if (body.containsKey('detail')) {
          message = body['detail'];
        } else if (body.containsKey('non_field_errors')) {
          message = (body['non_field_errors'] as List).first;
        } else {
          message = body.values.first is List
              ? (body.values.first as List).first.toString()
              : body.values.first.toString();
        }
      }
      throw ApiException(message, response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
