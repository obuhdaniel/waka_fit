import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api_config.dart';

class ApiService {
  final Dio _dio;

  ApiService({String? token})
      : 
        _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: ApiConfig.getHeaders(token),
        )) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to request if available
        // getIdToken(false) gets the cached token, or refreshes it if expired.
          final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('🚀 Request: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Response: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioError error, handler) {
        print('❌ Error: ${error.type} - ${error.message}');
        if (error.response != null) {
          print('Response data: ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, dynamic data) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String path, dynamic data) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }

  // Update token dynamically
  void updateToken(String newToken) {
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
  }

  // Cancel token for cleanup
  CancelToken createCancelToken() {
    return CancelToken();
  }
}