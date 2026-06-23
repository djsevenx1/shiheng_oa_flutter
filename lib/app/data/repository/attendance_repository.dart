import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

import '../providers/api_provider.dart';
import '../services/location_service.dart';

class AttendanceRecord {
  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.type, // 'in' / 'out'
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.status, // 'normal' / 'late' / 'early' / 'absent'
  });

  final String id;
  final String userId;
  final String type;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String address;
  final String status;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    DateTime ts;
    final t = json['timestamp'];
    if (t is int) {
      ts = DateTime.fromMillisecondsSinceEpoch(t);
    } else if (t is String) {
      ts = DateTime.tryParse(t) ?? DateTime.now();
    } else {
      ts = DateTime.now();
    }
    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'in',
      timestamp: ts,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'normal',
    );
  }
}

class AttendanceRepository {
  AttendanceRepository({ApiProvider? api, GetStorage? storage, LocationService? location})
      : _api = api ?? ApiProvider(),
        _storage = storage ?? GetStorage(),
        _location = location ?? LocationService();

  final ApiProvider _api;
  final GetStorage _storage;
  final LocationService _location;

  /// 今日打卡状态
  Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      final response = await _api.dioInstance.get('/oa/attendance/today');
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取打卡状态失败'};
    }
  }

  /// 打卡历史
  Future<Map<String, dynamic>> getHistory({String? from, String? to, int page = 1, int pageSize = 30}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/attendance/history',
        queryParameters: {'from': from ?? '', 'to': to ?? '', 'page': page, 'pageSize': pageSize},
      );
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取历史记录失败'};
    }
  }

  /// 上班打卡 / 下班打卡
  /// [type] 'in' / 'out'
  /// 真实流程：申请权限 -> 拉取定位 -> 提交到后端
  Future<Map<String, dynamic>> punch({required String type, String remark = ''}) async {
    try {
      // 1) 拉取真实定位
      final loc = await _location.getCurrentLocation();
      // 2) 提交到后端
      final response = await _api.dioInstance.post(
        '/oa/attendance/punch',
        data: {
          'type': type,
          'latitude': loc['latitude'],
          'longitude': loc['longitude'],
          'address': loc['address'],
          'city': loc['city'],
          'source': loc['source'] ?? 'baidu',
          'remark': remark,
          'clientTime': DateTime.now().toIso8601String(),
        },
      );
      if (response.data is Map) {
        final data = response.data as Map;
        if (data['success'] == true) {
          return {'success': true, 'data': data['data'] ?? data};
        }
        return {'success': false, 'message': data['message']?.toString() ?? '打卡失败'};
      }
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      // 定位失败也允许后端根据时间 + IP 兜底
      try {
        final response = await _api.dioInstance.post(
          '/oa/attendance/punch',
          data: {
            'type': type,
            'latitude': 0.0,
            'longitude': 0.0,
            'address': '',
            'source': 'fallback',
            'remark': '定位失败: $e',
            'clientTime': DateTime.now().toIso8601String(),
          },
        );
        return {'success': true, 'data': response.data, 'warn': '定位失败，已使用网络定位'};
      } on dio.DioException catch (e2) {
        return {'success': false, 'message': ApiProvider.normalize(e2).message};
      } catch (_) {
        return {'success': false, 'message': '打卡失败: $e'};
      }
    }
  }
}
