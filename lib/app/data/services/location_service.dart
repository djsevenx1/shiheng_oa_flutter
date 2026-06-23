import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:fl_amap/fl_amap.dart';

/// 统一的位置服务封装：默认使用百度定位，备选高德 fl_amap。
class LocationService {
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  /// 百度定位结果回调
  BMFLoCallback? _baiduCallback;

  /// 申请位置权限
  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) return true;
    final bg = await Permission.locationAlways.request();
    return bg.isGranted || status.isGranted;
  }

  /// 单次获取位置（百度优先，高德 fl_amap 备选）
  /// 返回 {latitude, longitude, address, province, city, district, street, source}
  Future<Map<String, dynamic>> getCurrentLocation() async {
    if (!await requestPermission()) {
      throw '未授予定位权限';
    }
    return _getBaiduLocation();
  }

  /// 使用百度定位 SDK
  Future<Map<String, dynamic>> _getBaiduLocation() async {
    final completer = _CompleterOnce<Map<String, dynamic>>();

    _baiduCallback = BMFLoCallback(
      onSuccess: (Map<String, dynamic> result) async {
        final loc = result['location'] as Map<String, dynamic>?;
        if (loc == null) {
          completer.fail('百度定位无数据');
          return;
        }
        final lat = loc['latitude'] as double? ?? 0.0;
        final lng = loc['longitude'] as double? ?? 0.0;
        completer.complete({
          'latitude': lat,
          'longitude': lng,
          'radius': loc['radius'] as double? ?? 0.0,
          'direction': loc['direction'] as double? ?? 0.0,
          'address': loc['address']?.toString() ?? '',
          'province': loc['province']?.toString() ?? '',
          'city': loc['city']?.toString() ?? '',
          'district': loc['district']?.toString() ?? '',
          'street': loc['street']?.toString() ?? '',
          'source': 'baidu',
        });
      },
      onError: (int code, String message) {
        completer.fail('百度定位失败 ($code): $message');
      },
    );

    try {
      await FlutterBmflocation.initLocationService(_baiduCallback!);
      await FlutterBmflocation.startLocation();
    } catch (e) {
      debugPrint('baidu init failed, fallback to fl_amap: $e');
      try {
        await FlutterBmflocation.stopLocation();
      } catch (_) {}
      return _getAmapLocation();
    }

    return completer.future.timeout(const Duration(seconds: 15), onTimeout: () {
      return _getAmapLocation();
    });
  }

  /// 使用 fl_amap（高德）定位
  Future<Map<String, dynamic>> _getAmapLocation() async {
    try {
      // fl_amap 在初始化时需要先 set key（高德开放平台申请的 API Key）
      await FlAMap().setAMapKey(iosKey: '', androidKey: '');
      await FlAMapLocation().initialize();
      final loc = await FlAMapLocation().getLocation();
      return {
        'latitude': loc.latitude,
        'longitude': loc.longitude,
        'radius': 0.0,
        'direction': 0.0,
        'address': loc.address ?? '',
        'province': loc.province ?? '',
        'city': loc.city ?? '',
        'district': loc.district ?? '',
        'street': loc.street ?? '',
        'source': 'amap',
      };
    } catch (e) {
      throw 'fl_amap 定位失败: $e';
    }
  }

  Future<void> stop() async {
    try {
      await FlutterBmflocation.stopLocation();
    } catch (_) {}
    try {
      await FlAMapLocation().stopLocation();
    } catch (_) {}
  }
}

/// 一次性 completer（first complete wins）。
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
