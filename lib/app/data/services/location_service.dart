import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bmflocation/flutter_bmflocation.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';

/// 统一的位置服务封装：默认使用百度定位，备选高德定位。
class LocationService {
  LocationService._internal();
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;

  /// 当前使用的高德插件（备用）
  final AMapFlutterLocation _aMap = AMapFlutterLocation();

  /// 百度定位结果回调
  BMFLoCallback? _baiduCallback;

  /// 申请位置权限
  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) return true;

    // 申请后台位置（可选，1.0.4 用了后台定位用于打卡）
    final bg = await Permission.locationAlways.request();
    return bg.isGranted || status.isGranted;
  }

  /// 单次获取位置（百度）
  /// 返回 {latitude, longitude, address, province, city, district, street, adCode}
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
        // 解析百度返回
        final loc = result['location'] as Map<String, dynamic>?;
        if (loc == null) {
          completer.fail('百度定位无数据');
          return;
        }
        // 反向地理编码
        final lat = loc['latitude'] as double? ?? 0.0;
        final lng = loc['longitude'] as double? ?? 0.0;
        try {
          final geo = await FlutterBmflocation.bmfLocationCoordinateFromLocation(
            BMFCoordinate(lat, lng),
          );
          debugPrint('baidu geocode: $geo');
        } catch (_) {}
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
      // 百度初始化失败时回退到高德
      debugPrint('baidu init failed, fallback to amap: $e');
      try {
        await FlutterBmflocation.stopLocation();
      } catch (_) {}
      return _getAmapLocation();
    }

    return completer.future.timeout(const Duration(seconds: 15), onTimeout: () {
      // 超时也回退到高德
      return _getAmapLocation();
    });
  }

  /// 使用高德定位 SDK（备用）
  Future<Map<String, dynamic>> _getAmapLocation() async {
    final completer = _CompleterOnce<Map<String, dynamic>>();

    await _aMap.setApiKey('', ''); // 通过 AndroidManifest 配置 key
    _aMap
      ..onLocationChanged()
      ..onLocationChanged().listen((Map<String, Object> event) {
        final lat = (event['latitude'] as num?)?.toDouble() ?? 0.0;
        final lng = (event['longitude'] as num?)?.toDouble() ?? 0.0;
        if (lat == 0.0 && lng == 0.0) return;
        completer.complete({
          'latitude': lat,
          'longitude': lng,
          'address': event['address']?.toString() ?? event['poiName']?.toString() ?? '',
          'province': event['province']?.toString() ?? '',
          'city': event['city']?.toString() ?? '',
          'district': event['district']?.toString() ?? '',
          'street': event['street']?.toString() ?? '',
          'source': 'amap',
        });
      });

    await _aMap.startLocation();
    return completer.future.timeout(const Duration(seconds: 15), onTimeout: () {
      throw '定位超时';
    });
  }

  Future<void> stop() async {
    try {
      await FlutterBmflocation.stopLocation();
    } catch (_) {}
    try {
      await _aMap.stopLocation();
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
