import 'package:get/get.dart';
import '../../../app/data/repository/crm_business_repository.dart';

class CrmChannelController extends GetxController {
  final _repository = CrmBusinessRepository();

  final isLoading = false.obs;
  final channelList = <dynamic>[].obs;
  final totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadChannels();
  }

  Future<void> loadChannels() async {
    isLoading.value = true;
    try {
      final result = await _repository.getChannelList();
      if (result['success'] == true) {
        channelList.value = result['data'] ?? [];
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

  void _loadMock() {
    final mock = [
      {
        'id': 1,
        'name': '华东大区',
        'manager': '张经理',
        'leads': 25,
        'deals': 8,
        'amount': 1250000.0,
        'rate': '32%',
      },
      {
        'id': 2,
        'name': '华南大区',
        'manager': '李总监',
        'leads': 32,
        'deals': 12,
        'amount': 1880000.0,
        'rate': '37%',
      },
      {
        'id': 3,
        'name': '华北大区',
        'manager': '王主管',
        'leads': 18,
        'deals': 5,
        'amount': 680000.0,
        'rate': '28%',
      },
      {
        'id': 4,
        'name': '西部渠道',
        'manager': '陈经理',
        'leads': 15,
        'deals': 3,
        'amount': 350000.0,
        'rate': '20%',
      },
    ];
    channelList.value = mock;
    totalCount.value = mock.length;
  }
}
