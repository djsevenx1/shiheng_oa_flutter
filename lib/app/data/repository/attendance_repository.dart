import '../providers/api_provider.dart';

class AttendanceRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getTodayStatus() async {
    try {
      final response = await _api.dioInstance.get('/attendance/today');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取今日状态失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getMonthStats(int month) async {
    try {
      final response = await _api.dioInstance.get('/attendance/stats', queryParameters: {'month': month});
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取月度统计失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getAttendanceList({int month = 1, int page = 1, int pageSize = 20}) async {
    try {
      final response = await _api.dioInstance.get('/attendance/list', queryParameters: {
        'month': month,
        'page': page,
        'pageSize': pageSize,
      });
      return {'success': true, 'data': response.data?['list'] ?? []};
    } catch (e) {
      return {'success': false, 'message': '获取考勤列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> checkIn({
    required String location,
    required String address,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _api.dioInstance.post('/attendance/checkIn', data: {
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
      final response = await _api.dioInstance.post('/attendance/checkOut', data: {
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
      final response = await _api.dioInstance.post('/attendance/leave', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '提交请假失败: $e'};
    }
  }
}
