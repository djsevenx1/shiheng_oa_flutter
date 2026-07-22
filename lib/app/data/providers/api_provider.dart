import 'package:dio/dio.dart' as dio;
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';

import '../../core/app_config.dart';
import '../services/diag_log.dart';

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

  // 基础配置 - 默认服务器地址（用户在登录页输入并自动保存）
  static const String _defaultBaseUrl = '';
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
      // 性能优化：超时从 30s 缩短到 8s/12s,失败能更快被感知
      connectTimeout: const Duration(seconds: 8),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 12),
      // 长连接
      persistentConnection: true,
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) {
        // 关键改动：老 OA 用 Spring Security form login，登录和很多业务接口都返 302
        // (location: /#/main/home 才是真成功；location: /login.jsp 是 session 失效)
        // 我们让 2xx 和 3xx 都不抛，业务层根据 status + location 自己判断
        return status != null && status < 400;
      },
      headers: {
        'Accept': 'application/json',
        // 性能优化：告诉服务端支持 gzip 响应,JSON 体积通常能压缩 70%+
        'Accept-Encoding': 'gzip',
      },
    ));

    // 关键修复：dio 5.x 在 Android 上 dart:io 的 HttpClient 不会自动把 set-cookie
    // 暴露到 response.headers。这是 HttpClient 的历史行为。
    // 我们用 onHttpClientCreate 配置 HttpClient 让它接受所有 cookies。
    // 同时启用 keep-alive,让多个请求复用同一个 TCP 连接,避免每次都三次握手
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // 允许 set-cookie 中任何 cookie 头被解析
        client.badCertificateCallback = (cert, host, port) => false;
        // 性能优化：30s 内的 keep-alive 连接会被复用
        client.idleTimeout = const Duration(seconds: 30);
        // 单 host 最大 6 个并发连接
        client.maxConnectionsPerHost = 6;
        return client;
      },
    );

    // 性能埋点拦截器
    _dio.interceptors.add(_PerfInterceptor());

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // 关键：老 App AuthFilter.java 第45-61行逻辑：
        // 如果请求带 token header，后端用它作为 login_name 查库获取密码并自动认证
        // 所以每次请求都必须带 token=loginName，否则 session 失效后会被 302 到 login.jsp
        final userInfo = _storage.read('userInfo');
        String? loginName;
        if (userInfo is Map) {
          loginName = userInfo['loginName']?.toString() ??
              userInfo['username']?.toString() ??
              userInfo['name']?.toString();
        }
        if (loginName != null && loginName.isNotEmpty) {
          options.headers['token'] = loginName;
        }

        // 添加 JSESSIONID cookie
        final jsessionId = _storage.read('JSESSIONID');
        if (jsessionId != null && options.headers['Cookie'] == null) {
          options.headers['Cookie'] = jsessionId.toString();
        }

        // 调试日志：放在最后，看到最终所有 headers
        DiagLog.write('REQ', '${options.method} ${options.uri} '
            'headers=${options.headers} qs=${options.queryParameters}');

        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 自动提取 set-cookie 中的 JSESSIONID 存到 storage（关键修复：dio 5.x 在 Android 上
        // headers.value('set-cookie') 在多 cookie 时会抛，且 auth_repository 解析易失败。
        // 我们在这里统一处理，所有响应（包括 200/302）都扫描 set-cookie，找到 JSESSIONID 就存）
        try {
          final list = response.headers['set-cookie'];
          String raw = '';
          if (list != null && list.isNotEmpty) {
            raw = list.map((e) => e?.toString() ?? '').join('\n');
          }
          if (raw.isEmpty) {
            try {
              raw = response.headers.value('set-cookie') ?? '';
            } catch (_) {}
          }
          if (raw.isNotEmpty) {
            final m = RegExp(r'JSESSIONID=([^;,\s]+)').firstMatch(raw);
            if (m != null) {
              final jsid = 'JSESSIONID=${m.group(1)}';
              final old = _storage.read('JSESSIONID');
              if (old != jsid) {
                _storage.write('JSESSIONID', jsid);
                debugPrint('[AUTO] stored JSESSIONID: $jsid (was: $old)');
                DiagLog.write('AUTO', 'stored JSESSIONID: $jsid (was: $old)');
              }
            }
          }
        } catch (e) {
          debugPrint('[AUTO] set-cookie scan error: $e');
        }

        // 调试日志：记录 status + location + content-type + set-cookie + body 前 500 字符
        final loc = response.headers.value('location') ?? '';
        final ct = response.headers.value('content-type') ?? '';
        String sc = '';
        try {
          final list = response.headers['set-cookie'];
          if (list != null && list.isNotEmpty) {
            sc = list.join(' | ');
          }
          if (sc.isEmpty) {
            try {
              sc = response.headers.value('set-cookie') ?? '';
            } catch (_) {}
          }
        } catch (_) {}
        String body = '';
        try {
          final d = response.data;
          if (d is String) {
            body = d.length > 500 ? '${d.substring(0, 500)}...' : d;
          } else if (d != null) {
            body = d.toString().length > 500
                ? '${d.toString().substring(0, 500)}...'
                : d.toString();
          }
        } catch (_) {}
        DiagLog.write('RES', '${response.requestOptions.method} ${response.requestOptions.uri} '
            '→ ${response.statusCode} ct=$ct loc=$loc sc=$sc body=$body');

        // 关键修复：老 OA Spring Security 在 session 失效时返回 302 + location:/login.jsp
        // 但 followRedirects=true 时 dio 会自动跟随到 /login.jsp 返回 200 + HTML
        // _parseListResponse 收到 HTML 会当作空数据返回，导致用户看到空列表无错误
        // 解决：检测 302 重定向到 login + 检测 HTML 响应，都转为认证失败
        if (response.statusCode != null &&
            response.statusCode! >= 300 &&
            response.statusCode! < 400) {
          // 复用上面已声明的 loc
          if (loc.contains('login') || loc.contains('error')) {
            // 302 重定向到登录页 = session 失效
            return handler.reject(dio.DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: dio.DioExceptionType.badResponse,
              error: '登录已过期，请重新登录',
            ));
          }
        }

        // 检测被重定向后返回的 HTML（login.jsp 的内容）
        // 复用上面已声明的 ct (content-type)
        if (ct.contains('text/html')) {
          String bodyStr = '';
          try {
            final d = response.data;
            if (d is String) bodyStr = d;
            else if (d != null) bodyStr = d.toString();
          } catch (_) {}
          if (bodyStr.contains('login') || bodyStr.contains('<html') || bodyStr.contains('password')) {
            return handler.reject(dio.DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: dio.DioExceptionType.badResponse,
              error: '登录已过期，请重新登录',
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
        DiagLog.write('ERR', '${error.requestOptions.method} ${error.requestOptions.uri} '
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

  /// 性能优化：连接预热。splash 阶段主动发一个 HEAD/GET,触发 TCP 握手 + TLS
  /// 这样后面真正业务请求过来时不用重新建连接,首屏能省 100-300ms
  Future<bool> warmup() async {
    if (_baseUrl.isEmpty) return false;
    try {
      final r = await _dio.get(
        '/',
        options: dio.Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          // 预热失败不要影响主流程
          validateStatus: (s) => s != null && s < 600,
        ),
      );
      return r.statusCode != null && r.statusCode! < 500;
    } catch (_) {
      return false;
    }
  }

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
          // 优先使用拦截器中设置的自定义 error 消息（如"登录已过期"）
          if (error.error is String && (error.error as String).isNotEmpty) {
            return ApiError(message: error.error as String, statusCode: code, kind: ApiErrorKind.unauthorized);
          }
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

/// 性能埋点拦截器:记录每个请求耗时,慢请求会单独高亮,方便定位瓶颈
class _PerfInterceptor extends dio.Interceptor {
  static const _kStart = '_perf_start';

  @override
  void onRequest(dio.RequestOptions options, dio.RequestInterceptorHandler handler) {
    options.extra[_kStart] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(dio.Response response, dio.ResponseInterceptorHandler handler) {
    _log(response.requestOptions, response.statusCode, null);
    handler.next(response);
  }

  @override
  void onError(dio.DioException err, dio.ErrorInterceptorHandler handler) {
    _log(err.requestOptions, err.response?.statusCode, err.message ?? err.type.toString());
    handler.next(err);
  }

  void _log(dio.RequestOptions opts, int? status, String? err) {
    if (!kDebugMode) return;
    final start = opts.extra[_kStart] as int?;
    if (start == null) return;
    final dur = DateTime.now().millisecondsSinceEpoch - start;
    final path = opts.path;
    if (dur > 800) {
      debugPrint('[SLOW ${dur}ms] $status $path $err');
      DiagLog.write('SLOW', '${dur}ms $status $path $err');
    } else {
      debugPrint('[API ${dur}ms] $status $path');
    }
  }
}
