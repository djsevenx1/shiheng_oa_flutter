import 'package:get/get.dart';
import '../../../app/data/repository/sh_report_repository.dart';

class ShReportController extends GetxController {
  final _repository = ShReportRepository();

  final isLoading = false.obs;
  final summary = <String, dynamic>{}.obs;
  final productionList = <dynamic>[].obs;
  final salesByMonth = <dynamic>[].obs;
  final topProducts = <dynamic>[].obs;
  final selectedPeriod = '本月'.obs;

  final periods = ['本周', '本月', '本季度', '本年度'];

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final result = await _repository.getReportSummary();
      if (result['success'] == true) {
        summary.value = result['data'] ?? {};
      } else {
        // /* MOCK-DISABLED */;  // mock disabled
      }
    } catch (e) {
      // /* MOCK-DISABLED */;  // mock disabled
    }
    // /* MOCK-DISABLED */;  // mock disabled
    // /* MOCK-DISABLED */;  // mock disabled
    isLoading.value = false;
  }

  void _loadMockSummary() {
    summary.value = {
      'revenue': 3580000.0,
      'revenueChange': 12.5,
      'orderCount': 156,
      'orderChange': 8.3,
      'customerCount': 86,
      'customerChange': -2.1,
      'productionCount': 12580,
      'productionChange': 15.6,
    };
  }

  void _loadMockProduction() {
    productionList.value = [
      {'id': 1, 'product': '电子元件A型', 'plan': 5000, 'actual': 4850, 'rate': 97, 'date': '2024-01-15'},
      {'id': 2, 'product': '控制器模块B', 'plan': 800, 'actual': 820, 'rate': 102, 'date': '2024-01-15'},
      {'id': 3, 'product': '电源组件C', 'plan': 1200, 'actual': 1180, 'rate': 98, 'date': '2024-01-14'},
      {'id': 4, 'product': 'PCB 主板', 'plan': 3000, 'actual': 2950, 'rate': 98, 'date': '2024-01-14'},
      {'id': 5, 'product': '外壳组件D', 'plan': 2000, 'actual': 1900, 'rate': 95, 'date': '2024-01-13'},
      {'id': 6, 'product': '连接器组件', 'plan': 5000, 'actual': 5100, 'rate': 102, 'date': '2024-01-13'},
    ];
  }

  void _loadMockSales() {
    salesByMonth.value = [
      {'month': '8月', 'amount': 280},
      {'month': '9月', 'amount': 320},
      {'month': '10月', 'amount': 350},
      {'month': '11月', 'amount': 290},
      {'month': '12月', 'amount': 410},
      {'month': '1月', 'amount': 358},
    ];

    topProducts.value = [
      {'name': '电子元件A型', 'amount': 580, 'percent': 28},
      {'name': '控制器模块B', 'amount': 420, 'percent': 20},
      {'name': '电源组件C', 'amount': 380, 'percent': 18},
      {'name': 'PCB 主板', 'amount': 320, 'percent': 15},
      {'name': '其他', 'amount': 380, 'percent': 19},
    ];
  }
}
