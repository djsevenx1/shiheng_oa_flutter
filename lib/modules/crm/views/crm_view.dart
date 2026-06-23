import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/themes/app_theme.dart';
import 'crm_client_view.dart';
import 'crm_business_view.dart';
import 'crm_sales_order_view.dart';
import 'crm_channel_view.dart';

class CrmView extends StatelessWidget {
  const CrmView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CRM 客户管理'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '客户'),
              Tab(text: '商机'),
              Tab(text: '订单'),
              Tab(text: '渠道'),
            ],
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
          ),
        ),
        body: const TabBarView(
          children: [
            CrmClientView(),
            CrmBusinessView(),
            CrmSalesOrderView(),
            CrmChannelView(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
