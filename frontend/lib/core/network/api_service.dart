import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

const _tokenKey = 'jwt_token';
final _log = Logger();
const _storage = FlutterSecureStorage();

// Navigation key used for programmatic routing outside the widget tree.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Singleton Dio instance with JWT auth interceptor.
class ApiService {
  ApiService._();
  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (err, handler) async {
        _log.e('API Error [${err.response?.statusCode}]: ${err.requestOptions.path}',
            error: err.message);
        if (err.response?.statusCode == 401) {
          // JWT expired or invalid — clear token and redirect to login
          await _storage.delete(key: _tokenKey);
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            GoRouter.of(ctx).go('/login');
          }
        }
        handler.next(err);
      },
    ));

    return d;
  }
}

// ─── Token helpers ────────────────────────────────────────────────────────────
Future<void> saveToken(String token) =>
    _storage.write(key: _tokenKey, value: token);

Future<String?> getToken() => _storage.read(key: _tokenKey);

Future<void> deleteToken() => _storage.delete(key: _tokenKey);

Future<bool> hasToken() async => (await getToken()) != null;
