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

  /// 今日打卡状态（从 initList 里筛今天的）
  Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      // 老 OA 没有 today 接口；拉一页 list 前端筛
      final response = await _api.dioInstance.get(
        '/oa/attendance/initList',
        queryParameters: {'limit': 50, 'offset': 0},
      );
      final data = response.data;
      final list = (data is Map && data['list'] is List) ? data['list'] as List : (data is List ? data : []);
      final today = DateTime.now();
      final todayStr = '${today.year.toString().padLeft(4, "0")}-${today.month.toString().padLeft(2, "0")}-${today.day.toString().padLeft(2, "0")}';
      final todays = list.where((e) {
        if (e is! Map) return false;
        final d = (e['createdDate'] ?? e['date'] ?? '').toString();
        return d.startsWith(todayStr);
      }).toList();
      return {'success': true, 'data': todays};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取打卡状态失败'};
    }
  }

  /// 月度统计（后端没专门接口，前端聚合）
  Future<Map<String, dynamic>> getMonthStats(int month) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/attendance/initList',
        queryParameters: {'limit': 200, 'offset': 0},
      );
      final data = response.data;
      final list = (data is Map && data['list'] is List) ? data['list'] as List : (data is List ? data : []);
      final monthStr = month.toString().padLeft(2, '0');
      int workDays = 0, late = 0, early = 0, leave = 0, absent = 0;
      for (final e in list) {
        if (e is! Map) continue;
        final d = (e['createdDate'] ?? e['date'] ?? '').toString();
        if (!d.contains('-${monthStr}-')) continue;
        workDays++;
        final status = (e['status'] ?? e['type'] ?? '').toString();
        if (status.contains('迟')) late++;
        else if (status.contains('早')) early++;
        else if (status.contains('假')) leave++;
        else if (status.contains('旷')) absent++;
      }
      return {
        'success': true,
        'data': {
          'workDays': workDays,
          'actualDays': workDays - absent,
          'lateCount': late,
          'earlyCount': early,
          'leaveCount': leave,
          'absentCount': absent,
        },
      };
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取月度统计失败'};
    }
  }

  /// 月度打卡明细（GET /oa/attendance/initList）
  Future<Map<String, dynamic>> getAttendanceList({required int month, int page = 1, int pageSize = 30}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/attendance/initList',
        queryParameters: {'limit': pageSize, 'offset': (page - 1) * pageSize},
      );
      final data = response.data;
      final list = (data is Map && data['list'] is List) ? data['list'] as List : (data is List ? data : []);
      final monthStr = month.toString().padLeft(2, '0');
      final filtered = list.where((e) {
        if (e is! Map) return false;
        final d = (e['createdDate'] ?? e['date'] ?? '').toString();
        return d.contains('-${monthStr}-');
      }).toList();
      return {'success': true, 'data': filtered, 'count': filtered.length};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取打卡列表失败'};
    }
  }

  /// 上班打卡（封装 punch）
  Future<Map<String, dynamic>> checkIn({
    String location = '',
    String address = '',
    double lat = 0.0,
    double lng = 0.0,
  }) async {
    return punch(type: 'in', remark: 'checkin @ $address');
  }

  /// 下班打卡
  Future<Map<String, dynamic>> checkOut({
    String location = '',
    String address = '',
    double lat = 0.0,
    double lng = 0.0,
  }) async {
    return punch(type: 'out', remark: 'checkout @ $address');
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
  /// [type] 'in' / 'out' / 'outdoor'
  /// 真实流程：申请权限 -> 拉取定位 -> 提交到后端
  Future<Map<String, dynamic>> punch({required String type, String remark = ''}) async {
    try {
      // 1) 拉取真实定位
      Map<String, dynamic> loc = {'latitude': 0.0, 'longitude': 0.0, 'address': '', 'source': 'fallback'};
      try {
        loc = await _location.getCurrentLocation();
      } catch (_) {}
      // 2) 提交到后端（老 OA 通用 add）
      final response = await _api.dioInstance.post(
        '/oa/attendance/add',
        data: {
          'type': type,
          'latitude': loc['latitude'],
          'longitude': loc['longitude'],
          'address': loc['address'],
          'city': loc['city'] ?? '',
          'source': loc['source'] ?? 'geolocator',
          'remark': remark,
          'createdDate': DateTime.now().toIso8601String(),
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
      return {'success': false, 'message': '打卡失败: $e'};
    }
  }
}
