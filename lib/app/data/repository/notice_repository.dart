import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

import '../providers/api_provider.dart';

/// 通知公告仓库
class NoticeRepository {
  NoticeRepository({ApiProvider? api, GetStorage? storage})
      : _api = api ?? ApiProvider(),
        _storage = storage ?? GetStorage();

  final ApiProvider _api;
  final GetStorage _storage;

  /// 通知列表
  /// [page] 从 1 开始；[pageSize] 默认 20；[type] 可选 'all' | 'unread'
  Future<Map<String, dynamic>> getNoticeList({
    int page = 1,
    int pageSize = 20,
    String type = 'all',
  }) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/notice/list',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          'type': type,
        },
      );
      if (response.data is Map) {
        final data = response.data as Map;
        return {
          'success': true,
          'data': data['data'] ?? data,
          'total': data['total'] ?? (data['data'] is List ? (data['data'] as List).length : 0),
        };
      }
      return {'success': true, 'data': [], 'total': 0};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'total': 0};
    } catch (e) {
      return {'success': false, 'message': '获取通知列表失败', 'data': [], 'total': 0};
    }
  }

  /// 通知详情
  Future<Map<String, dynamic>> getNoticeDetail(String id) async {
    try {
      final response = await _api.dioInstance.get('/oa/notice/detail', queryParameters: {'id': id});
      if (response.data != null) {
        // 标记已读
        await _storage.write('notice_read_$id', DateTime.now().toIso8601String());
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': '通知不存在'};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取通知详情失败'};
    }
  }

  /// 未读数
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.dioInstance.get('/oa/notice/unreadCount');
      if (response.data is Map) {
        return (response.data['count'] as num?)?.toInt() ?? 0;
      }
      if (response.data is int) return response.data as int;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// 标记全部已读
  Future<bool> markAllRead() async {
    try {
      await _api.dioInstance.post('/oa/notice/markAllRead');
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isRead(String id) {
    return _storage.hasData('notice_read_$id');
  }
}
