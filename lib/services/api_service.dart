import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blueprint.dart';
import '../services/keys.dart';

class ApiService {
  static final _defaultBaseUrl = BackendAPI().BackendURL;
  static const _prefKeyUrl = 'backend_url';

  late Dio _dio;
  String _baseUrl = _defaultBaseUrl;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _loadUrl();
  }

  bool _isInitialized = false;

  Future<void> initialise() async {
    if (_isInitialized) return;

    await _loadUrl();
    _isInitialized = true;
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_prefKeyUrl) ?? _defaultBaseUrl;
    _dio.options.baseUrl = _baseUrl;
    _isInitialized = true;
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.trimRight().replaceAll(RegExp(r'/$'), '');
    _dio.options.baseUrl = _baseUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUrl, _baseUrl);
  }

  String get currentUrl => _baseUrl;

  Future<bool> checkHealth() async {
    try {
      final res = await _dio.get('/api/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Blueprint> generateBlueprint({
    required String problemStatement,
    String? context,
  }) async {
    try {
      final res = await _dio.post(
        '/api/generate',
        data: {
          'problem_statement': problemStatement,
          if (context != null && context.isNotEmpty) 'context': context,
        },
      );

      if (res.statusCode == 200) {
        final data = res.data is String ? jsonDecode(res.data) : res.data;
        final blueprintData = data['blueprint'] ?? data;
        return Blueprint.fromJson(blueprintData as Map<String, dynamic>);
      }
      throw ApiException('Server returned ${res.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ApiException('Connection timed out. Check your server URL.');
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw ApiException(
          'Server is taking too long. The AI is still thinking — try again.',
        );
      }
      final msg = e.response?.data?['detail'] ?? e.message ?? 'Network error';
      throw ApiException(msg.toString());
    }
  }

  Future<String> generateUiPreview({
    required String projectName,
    String? context,
  }) async {
    try {
      final res = await _dio.post(
        '/api/preview',
        data: {
          'problem_statement': projectName,
          if (context != null) 'context': context,
        },
      );
      return (res.data['html'] ?? '') as String;
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail']?.toString() ?? 'Preview failed',
      );
    }
  }

  Future<List<RuntimeFlowStep>> generateRuntimeFlow({
    required String projectName,
    String? context,
  }) async {
    try {
      final res = await _dio.post(
        '/api/runtime-flow',
        data: {
          'problem_statement': projectName,
          if (context != null) 'context': context,
        },
      );
      final steps = res.data['steps'] as List;
      return steps
          .map((s) => RuntimeFlowStep.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?['detail']?.toString() ?? 'Flow generation failed',
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
