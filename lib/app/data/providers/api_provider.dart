import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiProvider {
  static final ApiProvider _instance = ApiProvider._internal();
  factory ApiProvider() => _instance;
  ApiProvider._internal();

  late dio.Dio _dio;
  final _storage = GetStorage();

  // 基础配置 - 时恒电子服务器
  static const String baseUrl = 'http://xmyjsss.gnway.cc:22178';
  static const String apiPrefix = '/oa';

  dio.Dio get dioInstance => _dio;

  void init() {
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: baseUrl + apiPrefix,
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
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST 请求
  Future<dio.Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  // PUT 请求
  Future<dio.Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  // DELETE 请求
  Future<dio.Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }
}
