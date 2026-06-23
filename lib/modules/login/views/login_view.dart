import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/core/app_config.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  // 关键改动：保证短屏（含键盘弹起）时也能滚到登录按钮。
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60.h),
                        // Logo
                        Center(
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.business,
                              size: 44.w,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        // Title
                        Center(
                          child: Text(
                            '时恒电子',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Center(
                          child: Text(
                            '移动办公平台',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white70,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SizedBox(height: 32.h),
                        _buildErrorBanner(controller),
                        // Login Form
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '欢迎登录',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '请输入您的账号和密码',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              // Server Address
                              TextField(
                                controller: controller.serverController,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: '服务器地址',
                                  hintStyle: const TextStyle(color: AppTheme.gray400, fontSize: 15),
                                  prefixIcon: const Icon(Icons.cloud_outlined, color: AppTheme.gray400, size: 22),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Username
                              TextField(
                                controller: controller.usernameController,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: '用户名',
                                  hintStyle: const TextStyle(color: AppTheme.gray400, fontSize: 15),
                                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.gray400, size: 22),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              // Password
                              Obx(() => TextField(
                                controller: controller.passwordController,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                                obscureText: !controller.isPasswordVisible.value,
                                decoration: InputDecoration(
                                  hintText: '密码',
                                  hintStyle: const TextStyle(color: AppTheme.gray400, fontSize: 15),
                                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.gray400, size: 22),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.isPasswordVisible.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppTheme.gray400,
                                      size: 22,
                                    ),
                                    onPressed: controller.togglePasswordVisibility,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                              )),
                              SizedBox(height: 16.h),
                              // Remember me
                              Row(
                                children: [
                                  Obx(() => Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: controller.toggleRememberMe,
                                    activeColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  )),
                                  Text(
                                    '记住密码',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      '忘记密码?',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 50.h,
                                child: Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value ? null : controller.login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.w,
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          '登 录',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                )),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),
                        // Version
                        Center(
                          child: Text(
                            '版本 2.0.0',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withAlpha(128),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        const Spacer(),
                        SizedBox(height: kBottomNavigationBarHeight),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 顶部错误 banner：短文案 + 关闭按钮，调试细节放在副标题里
  Widget _buildErrorBanner(LoginController c) {
    return Obx(() {
      final msg = c.errorBanner.value;
      if (msg == null || msg.isEmpty) return const SizedBox.shrink();
      final detail = c.errorBannerDetail.value;
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Material(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '登录失败：$msg',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (AppConfig.verboseErrors && detail != null && detail.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            detail,
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 11.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade700, size: 18.w),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: c.clearError,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
