import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// 统一的位置服务封装。
/// 使用社区标准 [Geolocator] 包（兼容 Flutter 3.22+，无需百度/高德原生 SDK）。
/// 真实部署时可在后端根据 lat/lng 反查行政区。
class LocationService {
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  /// 申请位置权限
  Future<bool> requestPermission() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      return serviceEnabled;
    } catch (e) {
      debugPrint('request permission failed: $e');
      return false;
    }
  }

  /// 单次获取位置
  /// 返回 {latitude, longitude, address, province, city, district, street, source}
  Future<Map<String, dynamic>> getCurrentLocation() async {
    if (!await requestPermission()) {
      throw '未授予定位权限';
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      return {
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'radius': pos.accuracy,
        'direction': pos.heading,
        'address': '',
        'province': '',
        'city': '',
        'district': '',
        'street': '',
        'source': 'geolocator',
      };
    } catch (e) {
      throw '定位失败: $e';
    }
  }

  Future<void> stop() async {
    // Geolocator 一次性定位无需 stop
  }
}

/// 一次性 completer（保留以便外部仍可引用）
class _CompleterOnce<T> {
  T? _value;
  Object? _error;
  bool _done = false;
  final List<Function> _waiters = [];

  void complete(T value) {
    if (_done) return;
    _done = true;
    _value = value;
    for (final w in _waiters) {
      w();
    }
  }

  void fail(Object error) {
    if (_done) return;
    _done = true;
    _error = error;
    for (final w in _waiters) {
      w();
    }
  }

  Future<T> get future {
    if (_done) {
      if (_error != null) throw _error!;
      return Future.value(_value as T);
    }
    return Future<T>(() async {
      while (!_done) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (_error != null) throw _error!;
      return _value as T;
    });
  }
}
