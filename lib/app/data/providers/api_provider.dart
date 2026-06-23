import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiProvider {
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;
  ApiProvider._internal();

  final _storage = GetStorage();

  // 基础配置 - 默认服务器地址（用户可在登录页修改并自动保存）
  static const String _defaultBaseUrl = 'http://njsh2012.5i178.com:9090';
  static const String apiPrefix = '/oa';
  static const String _storageBaseUrlKey = 'serverBaseUrl';

  // 初始化为默认地址（init() 中会从存储读取覆盖）
  String _baseUrl = _defaultBaseUrl;
  late final dio.Dio _dio;

  String get baseUrl => _baseUrl;
  String get fullBaseUrl {
    try {
      return _dio.options.baseUrl;
    } catch (_) {
      return '$_baseUrl$apiPrefix';
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
      _dio.options.baseUrl = normalized + apiPrefix;
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
      baseUrl: _baseUrl + apiPrefix,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加 token
        final token = _storage.read('token');
        if (token != null) {
          options.headers['token'] = token;
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
        return handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _storage.erase();
          Get.offAllNamed('/login');
          Get.snackbar(
            '登录已过期',
            '请重新登录',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

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
}
