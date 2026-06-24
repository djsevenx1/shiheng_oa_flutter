import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/app_config.dart';

/// 统一的业务错误结构，避免把 [dio.DioException] 整段抛到 UI。
class ApiError {
  ApiError({
    required this.message,
    this.statusCode,
    this.kind = ApiErrorKind.unknown,
  });

  /// 给用户看的友好提示。
  final String message;

  /// HTTP 状态码（如果有）。
  final int? statusCode;

  /// 错误分类。
  final ApiErrorKind kind;

  @override
  String toString() => 'ApiError($kind, $statusCode): $message';
}

enum ApiErrorKind {
  /// 1xx/2xx 不会出现这里。
  unauthorized, // 401
  forbidden, // 403
  notFound, // 404
  client, // 其它 4xx
  server, // 5xx
  timeout, // 连接/接收/发送超时
  network, // 没有响应、DNS 失败等
  canceled, // 请求被取消
  unknown,
}

class ApiProvider {
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;
  ApiProvider._internal();

  final _storage = GetStorage();

  // 基础配置 - 默认服务器地址（用户可在登录页修改并自动保存）
  static const String _defaultBaseUrl = 'http://njsh2012.5i178.com:9090';
  static const String _storageBaseUrlKey = 'serverBaseUrl';

  // 初始化为默认地址（init() 中会从存储读取覆盖）
  String _baseUrl = _defaultBaseUrl;
  late final dio.Dio _dio;

  String get baseUrl => _baseUrl;
  String get fullBaseUrl {
    try {
      return _dio.options.baseUrl;
    } catch (_) {
      return _baseUrl;
    }
  }

  /// Dio 实例（保持向后兼容，自动确保已初始化）
  dio.Dio get dioInstance {
    _ensureInitialized();
    return _dio;
  }

  /// 切换服务器地址（如用户在登录页输入）并持久化
  void setBaseUrl(String url) {
    if (url.isEmpty) return;
    String normalized = url.trim();
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'http://$normalized';
    }
    _baseUrl = normalized;
    // 初始化 _dio（如果还没初始化）
    _ensureInitialized();
    // 更新 baseUrl
    try {
      _dio.options.baseUrl = normalized;
    } catch (_) {}
    // 持久化
    try {
      _storage.write(_storageBaseUrlKey, normalized);
    } catch (_) {}
  }

  void _ensureInitialized() {
    try {
      // 触发一次访问，如果未初始化会抛 LateInitializationError
      _dio.options.baseUrl;
    } catch (_) {
      init();
    }
  }

  /// 初始化（自动从存储读取上次保存的地址）
  void init() {
    // 读取保存的地址
    try {
      final saved = _storage.read(_storageBaseUrlKey);
      if (saved != null && saved.toString().isNotEmpty) {
        _baseUrl = saved.toString();
      } else {
        _baseUrl = _defaultBaseUrl;
      }
    } catch (_) {
      _baseUrl = _defaultBaseUrl;
    }

    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) {
        // 关键改动：老 OA 用 Spring Security form login，登录和很多业务接口都返 302
        // (location: /#/main/home 才是真成功；location: /login.jsp 是 session 失效)
        // 我们让 2xx 和 3xx 都不抛，业务层根据 status + location 自己判断
        return status != null && status < 400;
      },
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 关键修复：老 OA Spring Security 在很多 GET 接口上要求带 XHR 头
        // 否则返 400 错误（"HTTP Status 400 - Required request parameter is not present"）
        // 不带这个头会导致 bulletin/task 等接口全军覆没
        'X-Requested-With': 'XMLHttpRequest',
      },
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // 关键修复：老 OA Spring Security 几乎所有 GET 接口都要求带 XHR 头
        // 否则返 400 错误。即使 base headers 里加了，options.headers 会被覆盖，
        // 所以在拦截器里强制补一个（业务代码如果显式传了 XHR 头就跳过）
        if (options.headers['X-Requested-With'] == null) {
          options.headers['X-Requested-With'] = 'XMLHttpRequest';
        }

        // 添加 token
        final token = _storage.read('token');
        if (token != null) {
          options.headers['token'] = token;
        }

        // 添加 JSESSIONID cookie
        final jsessionId = _storage.read('JSESSIONID');
        if (jsessionId != null && options.headers['Cookie'] == null) {
          options.headers['Cookie'] = jsessionId.toString();
        }

        // 添加用户信息
        final userInfo = _storage.read('userInfo');
        if (userInfo != null && userInfo['id'] != null) {
          if (options.queryParameters.isEmpty) {
            options.queryParameters = {};
          }
          options.queryParameters['userId'] = userInfo['id'];
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 关键修复：老 OA Spring Security 在 session 失效时返回 302 + location:/login.jsp
        // 之前 dio validateStatus 只接受 2xx，会直接抛异常；
        // 现在我们改成 < 400 接受，业务层继续处理 — 但这里额外做一次自动处理
        // （如果后续响应是 /login.jsp，直接转成 401 让业务层知道要重新登录）
        if (response.statusCode != null &&
            response.statusCode! >= 300 &&
            response.statusCode! < 400) {
          final loc = response.headers.value('location') ?? '';
          if (loc.contains('login') || loc.contains('error')) {
            // 模拟一个 401 让业务层知道
            return handler.reject(dio.DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: dio.DioExceptionType.badResponse,
            ));
          }
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        // 关键修复：401 时只清 token，保留 JSESSIONID（不影响下次重试）；
        // UI 跳转交给业务 controller 处理。
        if (error.response?.statusCode == 401) {
          _storage.remove('token');
          _storage.remove('userInfo');
        }

        // 调试模式：把异常信息打印到 console，便于排查
        debugPrint('[API ERROR] ${error.requestOptions.method} ${error.requestOptions.uri} '
            '→ ${error.response?.statusCode ?? error.type} | ${error.message}');

        return handler.next(error);
      },
    ));
  }

  // GET 请求
  Future<dio.Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    _ensureInitialized();
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST 请求
  Future<dio.Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    _ensureInitialized();
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  // PUT 请求
  Future<dio.Response> put(String path, {dynamic data}) async {
    _ensureInitialized();
    return await _dio.put(path, data: data);
  }

  // DELETE 请求
  Future<dio.Response> delete(String path, {dynamic data}) async {
    _ensureInitialized();
    return await _dio.delete(path, data: data);
  }

  // —— 业务错误归一化 —— //

  /// 把任意 Dio/网络异常转成 [ApiError]，供 UI 层直接展示。
  static ApiError normalize(Object error) {
    if (error is dio.DioException) {
      final code = error.response?.statusCode;
      switch (error.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          return ApiError(
            message: '请求超时，请检查网络',
            statusCode: code,
            kind: ApiErrorKind.timeout,
          );
        case dio.DioExceptionType.badResponse:
          if (code == 401) {
            return ApiError(message: '登录已过期，请重新登录', statusCode: code, kind: ApiErrorKind.unauthorized);
          } else if (code == 403) {
            return ApiError(message: '没有访问权限', statusCode: code, kind: ApiErrorKind.forbidden);
          } else if (code == 404) {
            return ApiError(message: '资源不存在', statusCode: code, kind: ApiErrorKind.notFound);
          } else if (code != null && code >= 500) {
            return ApiError(message: '服务暂时不可用，请稍后再试', statusCode: code, kind: ApiErrorKind.server);
          } else if (code != null && code >= 400) {
            return ApiError(message: '请求异常 (HTTP $code)', statusCode: code, kind: ApiErrorKind.client);
          }
          return ApiError(message: '请求失败', statusCode: code, kind: ApiErrorKind.client);
        case dio.DioExceptionType.cancel:
          return ApiError(message: '请求已取消', statusCode: code, kind: ApiErrorKind.canceled);
        case dio.DioExceptionType.connectionError:
        case dio.DioExceptionType.badCertificate:
        case dio.DioExceptionType.unknown:
          return ApiError(message: '网络连接失败', statusCode: code, kind: ApiErrorKind.network);
      }
    }
    return ApiError(message: '未知错误', kind: ApiErrorKind.unknown);
  }

  /// 调试时把异常细节拼成一行，便于 UI 折叠展示。
  static String debugDetail(Object error) {
    if (!AppConfig.verboseErrors) return '';
    if (error is dio.DioException) {
      final method = error.requestOptions.method;
      final url = error.requestOptions.uri;
      final code = error.response?.statusCode;
      return '[$method $url${code != null ? ' · HTTP $code' : ''}]';
    }
    return '';
  }
}
