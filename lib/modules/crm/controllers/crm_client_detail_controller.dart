import 'package:get/get.dart';
import '../../../app/data/repository/crm_repository.dart';

class CrmClientDetailController extends GetxController {
  final _repository = CrmRepository();

  final isLoading = false.obs;
  final clientId = 0.obs;
  final client = <String, dynamic>{}.obs;
  final businessList = <dynamic>[].obs;
  final salesOrderList = <dynamic>[].obs;
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['clientId'] != null) {
      clientId.value = args['clientId'];
      loadDetail();
    }
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.getClientDetail(clientId.value),
        _repository.getClientBusiness(clientId.value),
        _repository.getClientSalesOrder(clientId.value),
      ]);

      if (results[0]['success'] == true) {
        client.value = results[0]['data'] ?? {};
      } else {
        _loadMockDetail();
      }
      if (results[1]['success'] == true) {
        businessList.value = results[1]['data'] ?? [];
      } else {
        _loadMockBusiness();
      }
      if (results[2]['success'] == true) {
        salesOrderList.value = results[2]['data'] ?? [];
      } else {
        _loadMockSalesOrder();
      }
    } catch (e) {
      _loadMockDetail();
      _loadMockBusiness();
      _loadMockSalesOrder();
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    activeTab.value = index;
  }

  void _loadMockDetail() {
    client.value = {
      'id': clientId.value,
      'name': '华联科技股份有限公司',
      'type': '重点客户',
      'contact': '王经理',
      'phone': '13800138001',
      'email': 'wang@huallian.com',
      'address': '江苏省南京市',
      'industry': '电子制造',
      'level': 'A',
      'website': 'www.huallian.com',
      'createdDate': '2023-06-15',
      'amount': 125800.0,
      'remark': '重要战略客户，需重点维护',
    };
  }

  void _loadMockBusiness() {
    businessList.value = [
      {
        'id': 1,
        'name': '控制器采购项目',
        'amount': 58000.0,
        'stage': '商务谈判',
        'probability': 70,
        'date': '2024-01-10',
      },
      {
        'id': 2,
        'name': '电源模块合作',
        'amount': 32000.0,
        'stage': '需求确认',
        'probability': 50,
        'date': '2024-01-05',
      },
    ];
  }

  void _loadMockSalesOrder() {
    salesOrderList.value = [
      {
        'id': 1,
        'orderNo': 'SO20240115001',
        'product': '电子元件一批',
        'amount': 35800.0,
        'status': '已发货',
        'date': '2024-01-15',
      },
      {
        'id': 2,
        'orderNo': 'SO20240108002',
        'product': '控制器模块',
        'amount': 25600.0,
        'status': '已完成',
        'date': '2024-01-08',
      },
      {
        'id': 3,
        'orderNo': 'SO20231220003',
        'product': '电源组件',
        'amount': 64400.0,
        'status': '已完成',
        'date': '2023-12-20',
      },
    ];
  }
}
