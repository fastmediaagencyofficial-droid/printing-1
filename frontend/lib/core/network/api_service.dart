import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  // In-memory token cache — avoids slow secure storage read on every request
  String? _cachedToken;

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'Content-Type': 'application/json'},
    ));

    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Use cached token — only read from storage on first request
        _cachedToken ??= await _storage.read(key: _tokenKey);
        if (_cachedToken != null) {
          options.headers['Authorization'] = 'Bearer $_cachedToken';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (err, handler) {
        _log.e('⛔ API Error [${err.response?.statusCode}]: ${err.requestOptions.uri}',
            error: err.message);
        // Do NOT redirect to login — app runs in guest mode
        handler.next(err);
      },
    ));

    return d;
  }

  /// Call this after saving a new token so the cache stays in sync.
  void updateCachedToken(String? token) => _cachedToken = token;
}

// ─── Token helpers ────────────────────────────────────────────────────────────
Future<void> saveToken(String token) async {
  ApiService.instance.updateCachedToken(token);
  await _storage.write(key: _tokenKey, value: token);
}

Future<String?> getToken() => _storage.read(key: _tokenKey);

Future<void> deleteToken() async {
  ApiService.instance.updateCachedToken(null);
  await _storage.delete(key: _tokenKey);
}

Future<bool> hasToken() async => (await getToken()) != null;
