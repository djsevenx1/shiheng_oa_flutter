import 'package:get/get.dart';
import '../../../app/data/repository/project_repository.dart';

class ProjectDetailController extends GetxController {
  final _repository = ProjectRepository();

  final isLoading = false.obs;
  final projectId = 0.obs;
  final project = <String, dynamic>{}.obs;
  final contracts = <dynamic>[].obs;
  final files = <dynamic>[].obs;
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['projectId'] != null) {
      projectId.value = args['projectId'];
      loadDetail();
    }
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.getProjectDetail(projectId.value),
        _repository.getProjectContracts(projectId.value),
        _repository.getProjectFiles(projectId.value),
      ]);

      if (results[0]['success'] == true) {
        project.value = results[0]['data'] ?? {};
      } else {
        // /* MOCK-DISABLED */;  // mock disabled
      }
      if (results[1]['success'] == true) {
        contracts.value = results[1]['data'] ?? [];
      } else {
        // /* MOCK-DISABLED */;  // mock disabled
      }
      if (results[2]['success'] == true) {
        files.value = results[2]['data'] ?? [];
      } else {
        // /* MOCK-DISABLED */;  // mock disabled
      }
    } catch (e) {
      // /* MOCK-DISABLED */;  // mock disabled
      // /* MOCK-DISABLED */;  // mock disabled
      // /* MOCK-DISABLED */;  // mock disabled
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    activeTab.value = index;
  }

  void _loadMockProject() {
    project.value = {
      'id': projectId.value,
      'name': '智能控制器研发项目',
      'no': 'XM202401001',
      'status': '进行中',
      'progress': 65,
      'manager': '张经理',
      'members': '张经理,李工,王工,赵工,钱工',
      'startDate': '2024-01-01',
      'endDate': '2024-06-30',
      'budget': 850000.0,
      'customer': '华联科技',
      'description': '研发新一代智能控制器，集成 IoT 通信模块，支持远程监控和数据采集功能。',
      'createdDate': '2024-01-01',
    };
  }

  void _loadMockContracts() {
    contracts.value = [
      {
        'id': 1,
        'no': 'HT202401001',
        'name': '智能控制器采购合同',
        'amount': 580000.0,
        'status': '执行中',
        'date': '2024-01-10',
      },
      {
        'id': 2,
        'no': 'HT202401002',
        'name': '电子元件采购合同',
        'amount': 120000.0,
        'status': '已签订',
        'date': '2024-01-15',
      },
    ];
  }

  void _loadMockFiles() {
    files.value = [
      {'id': 1, 'name': '项目需求文档.docx', 'size': '256 KB', 'date': '2024-01-02', 'type': 'doc'},
      {'id': 2, 'name': '技术方案.pdf', 'size': '1.2 MB', 'date': '2024-01-05', 'type': 'pdf'},
      {'id': 3, 'name': '项目计划表.xlsx', 'size': '128 KB', 'date': '2024-01-08', 'type': 'xls'},
      {'id': 4, 'name': '原型设计图.fig', 'size': '4.5 MB', 'date': '2024-01-12', 'type': 'fig'},
      {'id': 5, 'name': '测试报告.pdf', 'size': '892 KB', 'date': '2024-02-15', 'type': 'pdf'},
    ];
  }
}
