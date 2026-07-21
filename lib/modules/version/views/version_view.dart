import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/themes/app_theme.dart';

class VersionView extends StatelessWidget {
  const VersionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于版本')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.apps, color: Colors.white, size: 60.w),
            ),
            SizedBox(height: 16.h),
            Text(
              '时恒电子 OA',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              '版本 v2.4.2',
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '已是最新版本',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.success),
              ),
            ),
            SizedBox(height: 24.h),
            _buildInfoCard(),
            SizedBox(height: 16.h),
            _buildUpdateLog(),
            SizedBox(height: 24.h),
            Text(
              '© 2024 时恒电子 版权所有',
              style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
            ),
            SizedBox(height: 8.h),
            Text(
              '南京时恒电子科技有限公司',
              style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow('技术框架', 'Flutter 3.44'),
          _buildInfoRow('版本', 'v2.4.2 (Build 242)'),
          _buildInfoRow('发布时间', '2026-07-21'),
          _buildInfoRow('MD5', '—'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateLog() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '更新日志',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 12.h),
          _buildLogItem('v2.4.2', '2026-07-21', [
            '明细区域模仿老App：紫色标题栏+编辑按钮+新增明细按钮',
            '点击编辑弹出明细编辑弹窗',
            '新增明细后自动弹出编辑框',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.4.1', '2026-07-21', [
            '改回放弃+提交两按钮（去掉同意/拒绝）',
            '修复放弃按钮没反应：底部栏移到Scaffold.bottomNavigationBar',
            '底部栏脱离body的Obx，避免重建导致点击事件丢失',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.4.0', '2026-07-21', [
            '详情页添加审批意见输入框（之前没有导致提交无反应）',
            '底部按钮改为放弃+拒绝+同意三按钮',
            '放弃按钮清空审批意见后返回',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.9', '2026-07-21', [
            '修复表单自动填值：controller创建顺序+getCurrentUser返回值处理',
            '增加debug日志排查autoFill问题',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.8', '2026-07-21', [
            '修复表单自动填值不显示（TextFormField initialValue 不更新）',
            '改用 TextEditingController 实现自动填值后 UI 更新',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.7', '2026-07-21', [
            '提交后重新加载详情验证是否成功',
            '放弃按钮不再禁用，随时可点击',
            '失败统一提示"网络错误，请重试"',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.6', '2026-07-21', [
            '提交后检查成功/失败状态',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.5', '2026-07-21', [
            '修复流程tab文字看不见（紫底紫字）',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.4', '2026-07-21', [
            '修复首页发起流程缺少modId参数（先选流程类型再填表单）',
            '版本页版本号和日志同步更新',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.3', '2026-07-21', [
            '历史流程列表显示材料名称（异步加载）',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.2', '2026-07-21', [
            '流程表单自动填写字段不再锁定，可编辑修改',
            '去掉没用的业务功能入口（项目/任务/话题/报表等）',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.1', '2026-07-21', [
            '首页最新动态改为待处理流程',
            '首页报表入口改为发起流程',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.3.0', '2026-07-21', [
            '详情页重写：tableSchema渲染表单+明细表格',
            '历史流程接口修复（/oa/pro/initList）',
            '底部提交/放弃按钮',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.2.9', '2026-07-21', [
            '修复审批记录字段映射（name/actionId/createdDate）',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.2.6', '2026-07-21', [
            '流程tab改为待处理+历史流程（去掉已发起/已审批）',
            '修复流程详情页空白（错误显示+时间戳格式化+formData过滤）',
            'App签名keystore放入仓库，CI直接签名编译',
            '同步版本号到设置/版本页',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.2.5', '2026-07-21', [
            '修复流程列表为空（token认证+HTML响应检测）',
            '修复流程提交后不跳转',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.0.0', '2023-08-10', [
            '新增任务管理',
            '优化流程审批',
          ]),
        ],
      ),
    );
  }

  Widget _buildLogItem(String version, String date, List<String> changes) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(version, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
              SizedBox(width: 8.w),
              Text(date, style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary)),
            ],
          ),
          SizedBox(height: 8.h),
          ...changes.map((c) => Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                Expanded(child: Text(c, style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
