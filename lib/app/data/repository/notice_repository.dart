import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 通知/消息仓库（对接老 OA `/oa/message/*` 接口）
/// 真实接口映射见 docs/api-mapping.md
class NoticeRepository {
  NoticeRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 通知列表（POST /oa/message/initList）
  /// [condition]: { search: {isRead: 0/1} } 或空
  /// 返回 {success, data: List<Map>, count, message}
  Future<Map<String, dynamic>> getNoticeList({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    final offset = (page - 1) * pageSize;
    try {
      final response = await _api.dioInstance.post(
        '/oa/message/initList?offset=$offset&limit=$pageSize',
        data: unreadOnly
            ? {
                'condition': {
                  'search': {'isRead': {'eq': 0}},
                }
              }
            : null,
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取通知失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 通知详情
  Future<Map<String, dynamic>> getNoticeDetail(String id) async {
    try {
      final response = await _api.dioInstance.get('/oa/message/getDetail/id/$id');
      if (response.data != null) {
        // 同时把 isRead 标记到本地
        if (response.data is Map) {
          await _api.dioInstance.post('/oa/message/edit', data: {
            'id': id,
            'isRead': 1,
          }).catchError((_) => null);
        }
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': '通知不存在'};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取详情失败: $e'};
    }
  }

  /// 未读数（/oa/message/count）
  Future<int> getUnreadCount() async {
    try {
      final response = await _api.dioInstance.get('/oa/message/count');
      final data = response.data;
      if (data is Map) {
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      if (data is int) return data;
      if (data is num) return data.toInt();
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// 标记单条已读
  Future<bool> markRead(String id) async {
    try {
      await _api.dioInstance.post('/oa/message/edit', data: {'id': id, 'isRead': 1});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 标记全部已读（后端没专门接口，逐条 edit；超过 50 条时只标前 50）
  Future<bool> markAllRead() async {
    try {
      final list = await getNoticeList(page: 1, pageSize: 50, unreadOnly: true);
      if (list['success'] != true) return false;
      final data = (list['data'] as List?) ?? [];
      for (final n in data) {
        final id = n['id']?.toString();
        if (id != null && id.isNotEmpty) {
          await _api.dioInstance.post('/oa/message/edit', data: {'id': id, 'isRead': 1}).catchError((_) => null);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 回复（/oa/message/reply）
  Future<Map<String, dynamic>> reply({
    required String id,
    required String content,
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/message/reply', data: {
        'id': id,
        'content': content,
      });
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '回复失败: $e'};
    }
  }

  Map<String, dynamic> _parseListResponse(dynamic data) {
    if (data is Map) {
      final list = (data['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final count = (data['count'] as num?)?.toInt() ?? list.length;
      return {'success': true, 'data': list, 'count': count};
    }
    if (data is List) {
      final list = data.cast<Map<String, dynamic>>();
      return {'success': true, 'data': list, 'count': list.length};
    }
    return {'success': true, 'data': [], 'count': 0};
  }
}
