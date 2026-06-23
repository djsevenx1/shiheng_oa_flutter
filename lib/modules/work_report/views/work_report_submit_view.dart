import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../app/widgets/rich_text_editor.dart';
import '../controllers/work_report_controller.dart';

class WorkReportSubmitView extends GetView<WorkReportSubmitController> {
  const WorkReportSubmitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('写汇报'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _typeSelector(),
            SizedBox(height: 16.h),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: '请输入汇报标题',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
            SizedBox(height: 16.h),
            RichTextEditor(
              hintText: '今日完成的工作、明天的计划、遇到的问题...',
              onChanged: controller.setContent,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : () async {
                      if (await controller.submit()) {
                        Get.back(result: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                          )
                        : const Text('提交', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeSelector() {
    return Obx(() => Row(
          children: [
            _typeBtn('daily', '日报'),
            SizedBox(width: 8.w),
            _typeBtn('weekly', '周报'),
            SizedBox(width: 8.w),
            _typeBtn('monthly', '月报'),
          ],
        ));
  }

  Widget _typeBtn(String value, String label) {
    return Obx(() {
      final selected = controller.type.value == value;
      return GestureDetector(
        onTap: () => controller.setType(value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              )),
        ),
      );
    });
  }
}
