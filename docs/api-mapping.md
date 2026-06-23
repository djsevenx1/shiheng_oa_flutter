# OA 后端真实接口映射（基于 njsh2012.5i178.com:9090 静态分析）

> 本文件由 `modules/*.js` + `modules/config/api.js` 反推得出（2026-06-23）。
> Spring Security 表单登录，`/login` 302 → JSESSIONID cookie。
> 所有业务接口都是 `POST/GET /oa/{module}/{action}` 风格。

## 通用接口模板（APIRead/APIReadWrite）

`this.name` 是模块名（如 `user`、`message`、`attendance`）。所有模块都遵循：

| 操作 | URL | Method | 参数 |
|---|---|---|---|
| 列表（分页） | `/oa/{name}/initList` 或 `/getPage` | GET / POST | `offset`, `limit`；POST 时 body 是 `pager.condition` |
| 列表（自定义） | `/oa/{name}/getList/{sqlKey}[/id/{id}]` | GET / POST | `fieldName` 写到 `scope[fieldName]` |
| 详情 | `/oa/{name}/getDetail/{fieldName}/{fieldValue}` | GET | — |
| 搜索 | `/oa/{name}/search` | POST | `filter` |
| 增 | `/oa/{name}/add[/{type}]` | POST | `formData` |
| 改 | `/oa/{name}/edit/` | POST | `formData` |
| 删 | `/oa/{name}/remove[/{type}]` | POST | `id` |
| 通用分页 | `/oa/common/getPage/{name}` | POST | `condition` |

## 8 个核心业务模块的接口

### 1. 通知/消息 (message) → 取代我之前写的 notice

| Flutter 字段 | URL | Method |
|---|---|---|
| `getList()` | `/oa/message/initList` | GET (offset/limit) |
| `getDetail(id)` | `/oa/message/getDetail/id/{id}` | GET |
| `markRead(id)` | `/oa/message/edit` (body: `{id, isRead: 1}`) | POST |
| `count()` | `/oa/message/count` | GET |
| `add()` | `/oa/message/add` | POST |
| `reply()` | `/oa/message/reply` | POST |
| `editReply()` | `/oa/message/editReply` | POST |

注意：老 OA 的"通知"是 message 系统，不是公告。Flutter 端 UI 标题要改成"消息"/"通知"。

### 2. 通讯录 (human + common)

| Flutter 字段 | URL | Method |
|---|---|---|
| 部门树 | `/oa/common/groups` | GET |
| 部门成员 | `/oa/human/initList?limit=N&offset=N` | GET |
| 部门成员 (按模板) | `POST /oa/human/initList/<modId>` body=`userIds` | POST |
| 成员搜索 | `POST /oa/u/initList?limit=N&offset=N` body=`{humanSearch: {name: "%X%"}}` | POST |
| 我的信息 | `/oa/human/getAccess` | GET |
| 用户详情 | `/oa/user/getUserOne?id={id}` | GET |
| 当前用户 | `/oa/user/current` | GET |

### 3. 我的申请 (workflow + flow)

老 OA 没有"我的申请"独立 tab，**实际是工作流的两个查询**：

| Flutter 字段 | URL | Method |
|---|---|---|
| 我发起的 | `/oa/flow/initList/running` 或 `/oa/wf/initList` | GET |
| 待我审批 | `/oa/flow/initList/todo` | GET |
| 我已审批 | `/oa/flow/initList/done` | GET |
| 流程详情 | `/oa/flow/getDetail/{formId}/{objectId}` | GET |
| 审批/同意/拒绝 | `/oa/flow/approve/` body=`{id, result, comment}` | POST |
| 撤回 | `/oa/flow/withdraw/` body=`{id}` | POST |
| 委派 | `/oa/flow/intervene/` | POST |

### 4. 工资条 / 知识库

老 OA 后端**没有 `/oa/payslip` `/oa/knowledge` 真实接口**。

| Flutter 字段 | URL | Method |
|---|---|---|
| 工资条 | 暂无 | — |
| 知识库 | 暂无 | — |

→ 这两个模块保留 mock 数据或直接灰显禁用按钮（避免"假数据"误导）。

### 5. 工作汇报

老 OA 后端**没有"工作汇报"独立模块**。可以用 `message` 模拟（type=dailyReport）或保留 mock。

### 6. 考勤 (attendance)

| Flutter 字段 | URL | Method |
|---|---|---|
| 本周签到列表 | `/oa/attendance/initList` | GET |
| 签到（新增） | `/oa/attendance/add` body=`{type:0/1/2, longi, lati, location, createdDate, createdTime}` | POST |
| 导出 | `/oa/attendance/exportAsExcel` | POST |

`type`: 0=上班, 1=下班, 2=外勤。

### 7. 任务 (task)

| Flutter 字段 | URL | Method |
|---|---|---|
| 任务列表 | `/oa/task/initList2?limit=100&filterName=Sub` | GET |
| 新建任务 | `/oa/task/addTask` | POST |
| 反馈 | `/oa/task/addFeedback` | POST |
| 反馈列表 | `/oa/task/getList/replies` | GET |

### 8. 二维码扫描 (无对应后端模块)

老 OA 没有 QR 模块。保留 mobile_scanner 仅作为扫码器，跳转靠 payload 里的 URL 走工作流或 webview。

## 推送（个推 / 微信 / RTX）

| 通道 | URL |
|---|---|
| 微信 pushNews | `/oa/wechat/pushNews` |
| 微信 pushText | `/oa/wechat/pushText` |
| RTX 消息 | `/rtx/sendRTX` |

IM 通道 `/oa/wefuck/*` 已经在 `oa.js` 配置好环信 appKey。

## 整改计划

1. **删所有 `_loadMockXxx` fallback**（按用户要求）
2. **`auth_repository`** 维持现状（登录走 `/login` 表单）
3. **新建 `notice_repository.dart` 改用 `message` 接口**
4. **改 `contacts_repository.dart` 用 `human` + `common/groups`**
5. **改 `my_application_repository.dart` 用 `workflow` 三个列表**
6. **改 `attendance_repository.dart` 用 `attendance` 真实接口**
7. **`payslip` / `knowledge` / `work_report` / `qr_scan` 直接禁用入口或加"演示数据"角标**
8. **`chat_list` 维持占位**（IM SDK 跟 Flutter 3.22 不兼容，等用户换 Flutter 3.27+ 再接）
