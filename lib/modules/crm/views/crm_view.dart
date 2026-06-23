import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import 'crm_client_view.dart';

class CrmView extends StatelessWidget {
  const CrmView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRM 客户管理'),
      ),
      body: const CrmClientView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('新增客户'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
