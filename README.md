# 时恒 OA 移动办公平台 (Flutter)

基于 Flutter 3.24 实现的现代化移动办公应用，从老旧的 Ionic v1 + AngularJS 完整迁移而来。

## 功能模块

| 模块 | 说明 |
|------|------|
| 启动页/登录 | 启动屏 + 账号密码登录 |
| 首页 | 4 Tab 导航（仪表盘/工作流/报表/更多） |
| 流程审批 | 列表/详情/发起表单（动态字段） |
| 报表 | 报表中心 + 库存报表 + 时恒专属报表 |
| CRM | 客户/商机/销售订单/销售渠道 |
| 考勤签到 | 实时打卡 + 月度统计 + 历史记录 |
| 项目管理 | 项目列表 + 详情（含合同、文件） |
| 任务管理 | 任务列表/详情/创建（带评论） |
| 话题讨论 | 4 状态 Tab + 发起话题 |
| 档案管理 | 6 类档案分类 |
| 公司文件 | 5 类文件网格 |
| 收藏 | 我的收藏（分组） |
| 地图 | 基于高德地图的位置服务 |
| 基础 | 帮助中心、公司信息、版本、关于 |

## 编译方式

### 通过 GitHub Actions（推荐）

1. 推送代码到 `main` 分支自动触发编译
2. 在仓库的 **Actions** 页面下载编译产物
3. 或推送 `v*` tag 自动发布 Release

```bash
# 触发编译
git push origin main

# 发布新版本
git tag v1.0.0
git push origin v1.0.0
```

### 本地编译

```bash
# 获取依赖
flutter pub get

# 编译 Debug APK
flutter build apk --debug

# 编译 Release APK（推荐）
flutter build apk --release --split-per-abi

# 编译 App Bundle（用于 Google Play）
flutter build appbundle --release
```

编译产物位于：
- `build/app/outputs/flutter-apk/app-release.apk`（通用包）
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`（32位）
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`（64位）
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`（x86模拟器）
- `build/app/outputs/bundle/release/app-release.aab`（Google Play）

## 编译产物说明

| 文件 | 大小 | 用途 |
|------|------|------|
| `shiheng-oa-debug.apk` | 较大 | 调试用，含调试信息 |
| `shiheng-oa-release.apk` | 中等 | 通用包，所有架构 |
| `shiheng-oa-armeabi-v7a.apk` | 较小 | 32位 ARM（旧设备） |
| `shiheng-oa-arm64-v8a.apk` | 较小 | 64位 ARM（推荐） |
| `shiheng-oa-x86_64.apk` | 较小 | 64位 x86（模拟器） |
| `shiheng-oa-release.aab` | - | Google Play 上架 |

## 技术栈

- **Flutter 3.24.5** / Dart 3.12
- **GetX 4.7** - 路由 + 状态管理
- **dio 5.9** - HTTP 客户端
- **flutter_screenutil** - 屏幕适配
- **fl_chart** - 图表
- **amap_flutter_map** - 高德地图
- **permission_handler** - 权限管理

## 项目结构

```
lib/
├── app/
│   ├── data/
│   │   ├── providers/     # API 提供器
│   │   └── repository/    # 11 个业务仓库
│   ├── routes/            # 25+ 路由
│   └── themes/            # 主题
├── modules/               # 22 个业务模块
│   ├── splash/
│   ├── login/
│   ├── home/
│   ├── workflow/
│   ├── report/
│   ├── crm/
│   ├── attendance/
│   ├── project/
│   ├── task/
│   ├── topic/
│   ├── archive/
│   ├── company_file/
│   ├── sh_report/
│   ├── favorite/
│   ├── help/
│   ├── company/
│   ├── version/
│   ├── settings/
│   └── map/
└── main.dart
```

## 开发

```bash
# 检查环境
flutter doctor

# 运行
flutter run

# 分析
flutter analyze
```

## License

© 2024 厦门时恒电子科技有限公司
