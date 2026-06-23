import '../providers/api_provider.dart';

class AttendanceRepository {
  final _api = ApiProvider();

  /// 获取考勤记录列表
  Future<Map<String, dynamic>> getAttendanceList({int month = 1, int page = 1, int pageSize = 20}) async {
    try {
      final response = await _api.dioInstance.get('/oa/attendance/initList', queryParameters: {
        'limit': pageSize,
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
        'filtersStr': response.data?['filtersStr'] ?? '',
      };
    } catch (e) {
      return {'success': false, 'message': '获取考勤列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      final response = await _api.dioInstance.get('/oa/attendance/today');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取今日状态失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getMonthStats(int month) async {
    try {
      final response = await _api.dioInstance.get('/oa/attendance/stats', queryParameters: {'month': month});
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取月度统计失败: $e'};
    }
  }

  Future<Map<String, dynamic>> checkIn({
    required String location,
    required String address,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/attendance/checkIn', data: {
        'location': location,
        'address': address,
        'lat': lat,
        'lng': lng,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '签到失败: $e'};
    }
  }

  Future<Map<String, dynamic>> checkOut({
    required String location,
    required String address,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/attendance/checkOut', data: {
        'location': location,
        'address': address,
        'lat': lat,
        'lng': lng,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '签退失败: $e'};
    }
  }

  Future<Map<String, dynamic>> submitLeave(dynamic formData) async {
    try {
      final response = await _api.dioInstance.post('/oa/attendance/leave', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '提交请假失败: $e'};
    }
  }
}
