import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/topic_repository.dart';

class TopicController extends GetxController {
  final _repository = TopicRepository();

  final isLoading = false.obs;
  final topicList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final selectedTab = 0.obs;

  final tabs = ['全部', '我发起', '我参与', '我关注'];

  @override
  void onInit() {
    super.onInit();
    loadTopics();
  }

  Future<void> loadTopics() async {
    isLoading.value = true;
    try {
      final result = await _repository.getTopicList();
      if (result['success'] == true) {
        topicList.value = result['data'] ?? [];
        totalCount.value = result['count'] ?? 0;
      } else {
        _loadMock();
      }
    } catch (e) {
      _loadMock();
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    loadTopics();
  }

  void _loadMock() {
    final mock = [
      {
        'id': 1,
        'title': '关于新产品研发的讨论',
        'content': '大家对新产品的研发方向有什么建议吗？',
        'creator': '张经理',
        'avatar': '',
        'participantCount': 8,
        'replyCount': 23,
        'createdDate': '2024-01-15 09:30',
        'lastReplyDate': '2024-01-15 14:20',
        'isPinned': true,
        'isFollowed': false,
      },
      {
        'id': 2,
        'title': '技术部周会纪要',
        'content': '本周工作总结及下周计划',
        'creator': '李总监',
        'avatar': '',
        'participantCount': 5,
        'replyCount': 12,
        'createdDate': '2024-01-14 16:00',
        'lastReplyDate': '2024-01-14 18:30',
        'isPinned': false,
        'isFollowed': true,
      },
      {
        'id': 3,
        'title': '年终奖发放方案讨论',
        'content': '请大家积极发言，集思广益',
        'creator': '王主管',
        'avatar': '',
        'participantCount': 15,
        'replyCount': 45,
        'createdDate': '2024-01-12 10:00',
        'lastReplyDate': '2024-01-15 11:00',
        'isPinned': true,
        'isFollowed': true,
      },
      {
        'id': 4,
        'title': '新员工培训安排',
        'content': '请各位组长配合完成新员工培训',
        'creator': '陈经理',
        'avatar': '',
        'participantCount': 6,
        'replyCount': 8,
        'createdDate': '2024-01-10 14:00',
        'lastReplyDate': '2024-01-11 09:00',
        'isPinned': false,
        'isFollowed': false,
      },
      {
        'id': 5,
        'title': '关于优化工作流程的建议',
        'content': '建议使用新的项目管理工具，提升效率',
        'creator': '我',
        'avatar': '',
        'participantCount': 4,
        'replyCount': 15,
        'createdDate': '2024-01-08 11:30',
        'lastReplyDate': '2024-01-09 16:20',
        'isPinned': false,
        'isFollowed': false,
      },
    ];
    topicList.value = mock;
    totalCount.value = mock.length;
  }
}
