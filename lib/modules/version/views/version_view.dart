import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/data/services/update_service.dart';
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
              '时恒电子',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              'OA 移动办公平台 v2.7.4',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 12.h),
            // 检查更新按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Get.dialog(const Center(child: CircularProgressIndicator()),
                      barrierDismissible: false);
                  final result = await UpdateService.checkUpdate();
                  Get.back();
                  if (result['hasUpdate'] == true) {
                    UpdateService.showUpdateDialog(result);
                  } else {
                    Get.snackbar('提示', result['error'] != null
                        ? '检查更新失败: ${result['error']}'
                        : '已是最新版本',
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                icon: Icon(Icons.system_update, size: 18.w, color: Colors.white),
                label: Text('检查更新', style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
            SizedBox(height: 24.h),
            _buildInfoCard(),
            SizedBox(height: 16.h),
            _buildUpdateLog(),
            SizedBox(height: 24.h),
            Text(
              '© 2024 OA 版权所有',
              style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
            ),
            SizedBox(height: 8.h),
            Text(
              'OA Mobile',
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _buildInfoRow('技术框架', 'Flutter 3.44'),
          _buildInfoRow('版本', 'v2.7.4 (Build 274)'),
          _buildInfoRow('发布时间', '2026-07-22'),
          _buildInfoRow('MD5', '—'),
          _buildInfoRow('适用平台', 'Android 5.0+'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('更新日志', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          SizedBox(height: 12.h),
          _buildLogItem('v2.7.4', '2026-07-22', [
            '新增全局名称字典:登录后异步拉取部门树+全员,缓存到本地',
            '流程详情/表单字段自动把 groupId/userId 转换为部门名/人名',
            '无网络或字典未加载时,回退显示原 ID 不影响主流程',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.7.3', '2026-07-22', [
            '最新页面支持下拉刷新:公告/动态/待处理流程均可下拉重新加载',
            '下拉 spinner 颜色与主紫色统一',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.7.2', '2026-07-22', [
            '修复流程详情"提交"按钮卡在当前页:发起人模式改走 submitWorkflow 接口(带 formData + flagPositive=null)',
            '区分审批人/发起人模式:审批人继续走 approveWorkflow,发起人改走 submitWorkflow',
            '异常路径也强制 Get.back 返回上一页,避免卡住',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.7.1', '2026-07-22', [
            '加回"时恒电子"品牌字样：启动页、公司信息页、关于版本页均显示完整品牌名',
            'Android 应用名保持为"时恒OA"',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.7.0', '2026-07-22', [
            '待处理审批提交后自动切到历史流程Tab并刷新',
            '优化首页待处理列表刷新：await确保刷新完成',
            '恢复App名称为时恒OA',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.9', '2026-07-22', [
            '修复审批提交后未返回上一页：改为无论成功失败都返回',
            '优化首页待处理刷新：并行请求+异常容错，确保返回后列表及时更新',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.8', '2026-07-22', [
            '去除硬编码服务器地址，改为登录页输入',
            '去除品牌字样',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.7', '2026-07-22', [
            '修复转交流程：选人后不再直接提交，改为暂存后填审批意见点"通过"才提交',
            '修复审批通过/拒绝后返回上一页并实时刷新首页待处理列表',
            '修复编译错误：approve/reject 中 userInfo 未定义',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.6', '2026-07-22', [
            '修复审批流程编译错误',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.5', '2026-07-22', [
            '修复审批"非法审批"错误：approve/reject payload 缺少 name/groupId/fileIds 字段',
            '与 forwardWorkflow 保持一致，补全后端必需字段',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.4', '2026-07-22', [
            '新增自动登录：登录页勾选后下次启动自动登录',
            '登录页输入框修复三星手机兼容（v2.6.3）',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.3', '2026-07-22', [
            '修复三星手机输入框不显示文字：边框改为可见浅灰色',
            '关闭自动纠错和建议（三星键盘兼容）',
            '密码框支持回车直接登录',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.2', '2026-07-22', [
            '设置页优化：去除"业务模块"和"其他"标题，合并为一个列表',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.1', '2026-07-22', [
            '修复CF代理URL格式：改用path-based路由（跟LunaTV-Mobile一致）',
            'API: /github/repos/.../releases/latest',
            '下载: /github/asset/.../v2.6.0/...apk',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.6.0', '2026-07-22', [
            '修复通讯录搜索：后端不支持humanSearch参数，改为本地过滤',
            '支持按姓名/工号/手机号/部门/角色搜索',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.9', '2026-07-22', [
            '应用内更新套上 CF Pages 代理加速(tmdb-8d1.pages.dev)',
            'API检查和APK下载均优先走代理，失败自动回退直连',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.8', '2026-07-22', [
            '修复审批记录actionId=6显示为"退回"，实际应为"转交"',
            '新增应用内更新：版本页"检查更新"按钮，自动下载安装APK',
            'App启动时自动检查新版本',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.7', '2026-07-22', [
            '修复已处理流程点击崩溃：API返回String时显示友好提示而非类型转换异常',
            '修复主页通知列表审批后不刷新：返回时自动刷新待办和动态列表',
            '所有JSON解析加类型安全检查，避免异常数据导致崩溃',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.6', '2026-07-22', [
            '审批/拒绝/转交成功后显示后端返回的提示信息（如"已提交库房审批"）',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.5', '2026-07-22', [
            '修复通知功能：改用企业微信推送(/oa/wechat/pushText)替代站内消息',
            '通知内容包含发送人姓名和流程名称',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.4', '2026-07-22', [
            '修复审批/转交操作成功后误报"网络错误"：后端返回HTTP 500但操作已生效',
            '失败时自动重新加载详情验证操作是否实际生效',
            '所有操作错误提示改为显示后端实际错误信息',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.3', '2026-07-22', [
            '修复转交功能：不发完整 formData（含 logs 导致 payload 过大/序列化失败）',
            '改进错误提示：显示后端实际错误信息而非通用"网络错误"',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.2', '2026-07-22', [
            '修复转交功能报数据库死锁：补全 payload 字段(name/groupId/formData/fileIds)',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.1', '2026-07-22', [
            '修复审批模式判断：与老 App 一致，state>0 即显示审批人模式（拒绝/通过+转交/前加签/通知）',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.5.0', '2026-07-22', [
            '新增转交功能：审批人可将流程转交给其他人审批',
            '新增前加签功能：审批人可邀请其他人协助审批',
            '新增通知功能：审批人可通知其他用户查看流程',
            '选人弹窗支持搜索和多选',
          ]),
        ],
      ),
    );
  }

  Widget _buildLogItem(String version, String date, List<String> changes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(version, style: TextStyle(fontSize: 12.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            ),
            SizedBox(width: 8.w),
            Text(date, style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary)),
          ],
        ),
        SizedBox(height: 4.h),
        ...changes.map((c) => Padding(
          padding: EdgeInsets.only(left: 4.w, top: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•', style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
              SizedBox(width: 6.w),
              Expanded(child: Text(c, style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary, height: 1.4))),
            ],
          ),
        )),
      ],
    );
  }
}
