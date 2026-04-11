import 'package:dio/dio.dart';
import '../storage_service.dart';
import '../api_service.dart';
import '../session_expiry_notifier.dart';

/// Central Dio-based HTTP client with:
/// - Automatic Bearer token injection
/// - Silent 401 token refresh + retry
/// - Configurable base URL from [ApiService.baseUrl]
class CoreApiClient {
  late final Dio dio;
  final StorageService? _storageService;

  /// Whether a token refresh is currently in flight to avoid parallel refreshes.
  bool _isRefreshing = false;

  CoreApiClient({StorageService? storageService})
    : _storageService = storageService ?? StorageService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  /// Test-only constructor: accepts a pre-built [Dio] with no auth
  /// interceptors, avoiding platform-channel issues in unit tests.
  CoreApiClient.test({Dio? dioOverride}) : _storageService = null {
    dio =
        dioOverride ??
        Dio(
          BaseOptions(
            baseUrl: ApiService.baseUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
  }

  /// Standard endpoint timeout profile (10 seconds).
  Options standardTimeoutOptions({Options? base}) {
    final options = base ?? Options();
    return options.copyWith(
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
  }

  /// Material-related endpoint timeout profile (30 seconds).
  Options materialTimeoutOptions({Options? base}) {
    final options = base ?? Options();
    return options.copyWith(
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );
  }

  // ── Request Interceptor ────────────────────────────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageService?.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Error Interceptor (Token Refresh) ──────────────────────────────────

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid infinite loops when the refresh endpoint itself fails.
    if (err.requestOptions.path.contains('/auth/refresh-token')) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storageService?.getRefreshToken();
      if (refreshToken == null) {
        _isRefreshing = false;
        await _handleSessionExpired();
        return handler.next(err);
      }

      // Attempt to refresh the access token
      final refreshResponse = await Dio(
        BaseOptions(
          baseUrl: ApiService.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ).post('/auth/refresh-token', data: {'refreshToken': refreshToken});

      if (refreshResponse.statusCode == 200) {
        final newAccessToken = refreshResponse.data['accessToken'] as String;
        final newRefreshToken = refreshResponse.data['refreshToken'] as String;

        // Persist new tokens
        await _storageService?.saveTokens(newAccessToken, newRefreshToken);

        _isRefreshing = false;

        // Clone the failed request with the new token and retry
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await dio.fetch(retryOptions);
        return handler.resolve(retryResponse);
      }
    } on DioException {
      // Refresh itself failed — propagate original error
    } catch (_) {
      // Unexpected error during refresh
    }

    _isRefreshing = false;
    await _handleSessionExpired();
    handler.next(err);
  }

  Future<void> _handleSessionExpired() async {
    try {
      await _storageService?.clearAll();
      await _storageService?.clearChatCache();
    } catch (_) {
      // Keep behavior non-throwing during auth teardown.
    }

    SessionExpiryNotifier.notify();
  }
}
