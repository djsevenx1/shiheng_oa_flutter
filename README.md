#  OA 移动办公平台 - Flutter 重构版

> 原生 OA 系统的 Flutter 重构版本,基于老 App 接口完全重写 UI 与交互,保留后端业务能力,提升首屏速度与可维护性。

![Flutter](https://img.shields.io/badge/Flutter-3.22.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.4%2B-0175C2?logo=dart)
![Android](https://img.shields.io/badge/Android-5.0%2B-3DDC84?logo=android)
![Version](https://img.shields.io/badge/version-v2.8.0-61428F)
![License](https://img.shields.io/badge/license-Proprietary-red)

---

## 功能模块

> 注:本表只列**当前 App 实际挂在入口上**的模块。其他业务模块(任务/项目/话题/档案/报表/收藏/通知)的代码与路由已实现,后续按需暴露到"更多"页。

| 模块 | 说明 |
|------|------|
| 启动页 | 启动预热服务器连接 + 自动登录判断 |
| 登录 | 服务器地址 / 用户名 / 密码 / 记住密码 / 自动登录 |
| 首页仪表盘 | 3 Tab 导航(最新 / 流程 / 更多),下拉刷新,公告/待办 |
| 流程审批 | 列表 / 详情 / 动态字段发起表单 / 审批操作 / 提交后回退 |
| 通讯录 | 成员列表 / 拼音搜索 / 点击电话调用系统拨号 |
| 设置 | 深色模式 / 加速 GitHub 代理 / 消息通知 / 清除缓存 / 版本 |
| 公司信息 | 品牌展示 + 简介 + 联系信息 |
| 关于版本 | 版本号 / 检查更新 / 更新日志 |
| 帮助中心 | 帮助文档 / 联系客服 |

## 编译与发布

### 通过 GitHub Actions(推荐)

```bash
# 1. 推送代码到 main 自动触发编译
git push origin main

# 2. 打 tag 触发发布(force push 会替换已存在 tag)
git tag -fa v2.7.10 -m "v2.7.10: 登录页新增加速 GitHub 地址输入框"
git push origin v2.7.10 --force
```

Actions 编译完成后,会自动在 [Releases](https://github.com/djsevenx1/shiheng_oa_flutter/releases) 创建一个草稿,需要手动编辑发布说明后发布。

> Tip: tag 触发后,CI 编译产物(APK)会自动上传到 Release 草稿的 assets 中。

### 本地编译

```bash
# 获取依赖
flutter pub get

# 编译通用 Release APK(推荐)
flutter build apk --release

# 编译分架构包(32/64 位)
flutter build apk --release --split-per-abi

# 编译 Debug(带调试信息)
flutter build apk --debug
```

编译产物:
- `build/app/outputs/flutter-apk/app-release.apk` - 通用包
- `build/app/outputs/flutter-apk/app-{armeabi-v7a,arm64-v8a,x86_64}-release.apk` - 分架构包

## 技术栈

| 类别 | 选型 |
|------|------|
| 框架 | **Flutter 3.22.2** / Dart 3.4+ |
| 状态管理 / 路由 | **GetX 4.7** |
| HTTP 客户端 | **dio 5.x**(开启 keep-alive / gzip / 性能埋点) |
| 本地存储 | **get_storage** |
| 屏幕适配 | **flutter_screenutil** |
| 图表 | **fl_chart** |
| 图片缓存 | **cached_network_image** |
| 骨架屏 | **shimmer** |
| 国际化 | **flutter_localizations** (zh_CN) |
| 外部跳转 | **url_launcher** (tel:/https:/...) |
| 文件预览 | **flutter_pdfview** / **open_filex** / **file_picker** |
| 路径 | **path_provider** |
| 拼音搜索 | **lpinyin** |
| 通知 | **getuiflut** (个推) |

## 项目结构

```
lib/
├── main.dart                       # 入口,锁定竖屏/中文化/主题
├── app/
│   ├── core/
│   │   └── app_config.dart
│   ├── data/
│   │   ├── providers/
│   │   │   └── api_provider.dart   # 单例 Dio,keep-alive/gzip/超时/埋点
│   │   ├── repository/             # 18 个业务仓库
│   │   │   ├── auth_repository.dart
│   │   │   ├── dashboard_repository.dart
│   │   │   ├── workflow_repository.dart
│   │   │   ├── contacts_repository.dart
│   │   │   ├── name_dict_repository.dart
│   │   │   └── ... (其余业务仓库)
│   │   └── services/
│   │       ├── update_service.dart # 走 CF 代理检查 GitHub Releases
│   │       └── diag_log.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── themes/
│       └── app_theme.dart          # 浅色 + 深色双主题
└── modules/                        # 17 个业务模块
    ├── splash/                     # 启动页
    ├── login/                      # 登录页(服务器+凭据)
    ├── home/                       # 主页(4 Tab)
    │   └── views/tabs/             #   dashboard/workflow/more
    ├── workflow/                   # 流程(列表/详情/表单/选择器)
    ├── contacts/                   # 通讯录(拼音搜索+拨号)
    ├── task/                       # 任务
    ├── topic/                      # 话题
    ├── project/                    # 项目
    ├── report/                     # 报表中心
    ├── sh_report/                  # 时恒专属报表
    ├── archive/                    # 档案
    ├── notice/                     # 通知
    ├── favorite/                   # 收藏
    ├── settings/                   # 设置(主题/缓存/通知)
    ├── help/                       # 帮助
    ├── company/                    # 公司信息
    └── version/                    # 版本日志
```

## 核心特性

### 性能优化(v2.7.9)
- **HTTP keep-alive**:`maxConnectionsPerHost=6` / `idleTimeout=30s`,后续请求复用 TCP 连接
- **GZIP 压缩**:响应头 `Accept-Encoding: gzip`,JSON 体积压缩 70%+
- **连接预热**:`ApiProvider.warmup()` 在 splash 阶段主动发 GET /,触发 TCP 握手,首屏省 100-300ms
- **超时缩短**:30s/30s/30s → 8s/10s/12s,失败更快感知
- **并行加载**:首页 6 个接口一次性 `Future.wait`,首屏省 200-500ms
- **慢请求埋点**:`_PerfInterceptor` 自动记录每个请求耗时,>800ms 标 SLOW

### 网络配置(v2.7.10)
- **服务器地址**:登录页可改,持久化到 `GetStorage`,换服务器自动清旧登录态
- **加速 GitHub 代理**:登录页可改,默认 `https://tmdb-8d1.pages.dev`,值传给 `UpdateService` 用于检查更新/下载 APK
- **自动登录**:勾选后启动时静默登录,失败降级到登录页

### 深色模式(v2.7.7)
- 设置页开关实时切换 `GetMaterialApp.themeMode`
- 持久化到 `GetStorage`,启动恢复
- 暗色卡片 / 暗色 AppBar / 暗色输入框

### 中文化(v2.7.8)
- `flutter_localizations` + `locale=zh_CN`
- 文本选择菜单、Material 默认文案全部中文

### 名称字典(v2.7.5)
- `NameDictRepository` 启动时拉 `/oa/common/groups` + `/oa/u/initList`
- 流程详情/通知中的 ID 自动转中文名
- 缓存到本地,离线也能展示

## 开发

```bash
# 1. 检查环境
flutter doctor

# 2. 安装依赖
flutter pub get

# 3. 跑模拟器
flutter run

# 4. 静态分析
flutter analyze

# 5. 调试模式会自动输出请求耗时:
#    [API 124ms] 200 /oa/user/current
#    [SLOW 1234ms] 200 /oa/eve/getList/8
```

## 版本历史

完整版本日志见 [Releases](https://github.com/djsevenx1/shiheng_oa_flutter/releases),或 App 内"设置 → 关于 → 更新日志"。

最近几个版本:
- **v2.8.0** (2026-07-22) - 加速 GitHub 代理配置从登录页迁到"设置 > 网络"
- **v2.7.10** (2026-07-22) - 登录页新增加速 GitHub 地址输入框
- **v2.7.9** (2026-07-22) - 链接服务器速度优化(keep-alive/gzip/预热/并行)
- **v2.7.8** (2026-07-22) - 修复系统文本选择菜单英文
- **v2.7.7** (2026-07-22) - 深色模式真正生效
- **v2.7.6** (2026-07-22) - 通讯录点击电话拨号 + 强制竖屏
- **v2.7.5** (2026-07-22) - 流程详情字段 ID 转中文名

## 仓库

- 主仓库:[djsevenx1/shiheng_oa_flutter](https://github.com/djsevenx1/shiheng_oa_flutter)
- CI/CD:GitHub Actions
- 加速代理(默认):[tmdb-8d1.pages.dev](https://tmdb-8d1.pages.dev)

---

Copyright © 时恒电子. 内部使用,未经许可不得外传。
