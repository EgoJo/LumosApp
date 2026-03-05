# Lumos · iOS

*你的分身，帮你被同频的人找到。*

原生 iOS 工程（SwiftUI），本地 Mock Demo，无后端依赖。Onboarding、语音回答、分身预览、观点流、智能追问、用户主页、消息通知、真人接管等完整链路均可在模拟器 / 真机上走通。

---

## 快速开始

1. 打开 Xcode → `File > New > Project…` → **iOS > App**
2. Product Name `Lumos`，Interface `SwiftUI`，Language `Swift`
3. 将仓库中所有 `.swift` 文件拖入工程，勾选 **Copy items if needed**
4. 删除 Xcode 自动生成的 `ContentView.swift`
5. 选择 iPhone 模拟器（推荐 iPhone 15 Pro）→ `Cmd+R`

> 工程无第三方依赖，不需要 CocoaPods / SPM。

---

## 文件一览

| 文件 | 职责 |
|------|------|
| `LumosApp.swift` | App 入口，创建 `AppState`，挂载 `RootTabView` |
| `AppState.swift` | 全局状态：Tab、Onboarding 进度、Mock 数据、弹层路由、所有 action 方法 |
| `Models.swift` | 数据结构：`Question` / `Viewpoint` / `MessageItem` / `ActiveSheet` 枚举 |
| `DesignSystem.swift` | 设计 Token（颜色 / 字体）、`PrimaryButtonStyle`、`ChipView`、`DeviceShell` |
| `RootTabView.swift` | 4 Tab 容器 + 自定义 TabBar（消息红点动态联动）+ 统一 sheet 路由 |
| `TodayView.swift` | 今日 Tab：Onboarding 3 题 / 正式态分身回答卡 / 往期回答列表 |
| `AvatarView.swift` | 分身 Tab：头像、对齐率、邀请校准、话题筛选、我的观点流 |
| `DiscoverView.swift` | 发现 Tab：6 条观点 feed、用户主页入口、本地搜索 |
| `MessagesView.swift` | 消息 Tab：分区列表、未读标记、空态引导 |
| `Overlays.swift` | 全部 10 个弹层 Sheet |

---

## 推荐 Xcode Group 结构

```
Lumos
├─ App/         LumosApp.swift, AppState.swift
├─ Core/        Models.swift, DesignSystem.swift
├─ Features/    TodayView.swift, DiscoverView.swift, AvatarView.swift, MessagesView.swift
├─ UI/          RootTabView.swift, Overlays.swift
└─ Supporting/  README.md
```

---

## 功能模块

### 今日 Tab

**Onboarding 态**（首次启动，3 题完成前）

- 横向进度条 + 当前题号
- 深色问题卡 + 「用语音回答」CTA
- 点击 → `RecordingSheet`（本地计时模拟录音，≥ 3 秒后可提交）
- 提交 → `PreviewSheet`（展示分身 Mock 回答）→ 确认推进下一题
- 3 题全部完成 → `OnboardingDoneSheet`（对齐率 42%）→ 分身上线

**正式态**（Onboarding 完成后）

- 分身今日回答卡（回答摘要 + 追问状态）
- 接管前：「我来接管」按钮（琥珀色状态提示）
- 接管后：「真人已接管，今日已回复」+ 「修改回复」入口
- 往期回答列表，点击进入 `PastAnswerDetailSheet`

### 发现 Tab

- 6 条 Mock 观点 feed（今日问题对应的排在最前）
- 点击卡片**头像区域** → `UserProfileSheet`（该用户的完整观点主页）
- 点击「追问」→ `ProbeSheet`（预设追问 3 条，按回答关键词自动匹配分支；支持自定义，≥ 10 字发送）
- 每条观点只能追问一次，已追问变灰
- 右上角搜索 → 本地模糊匹配（人名 / 职称 / 问题 / 回答）

### 分身 Tab

- 头像 + 名字 + 简介 + 分身对齐率进度条
- 「邀请朋友校准分身」→ `InviteCalibrationSheet`（Mock 链接）
- 话题筛选 Chips：全部 / 职场 / 人生 / 创业 / 随想
- 我的观点流列表

### 消息 Tab

- Onboarding 完成后自动注入 4 条预置消息，模拟「分身已在工作」：
  - 2 条 `myPersona`（有人追问了你的分身）
  - 1 条 `otherPersona`（你追问的分身回复了）
  - 1 条 `system`（分身今日动态，对齐率更新）
- 分两区展示：**对你分身的追问** / **分身世界的其他动静**
- 点击消息 → 标记已读 + 打开 `MessageDetailSheet`
- 全部消息已读后，TabBar 红点自动消失
- 从发现页发起追问后，消息自动写入列表（按分身聚合）

---

## 弹层路由速查

| 触发路径 | 弹层 |
|---------|------|
| 今日 → 用语音回答 | `RecordingSheet` |
| RecordingSheet → 提交 | `PreviewSheet` |
| PreviewSheet → 第 3 题确认 | `OnboardingDoneSheet` |
| 今日 → 我来接管 / 修改回复 | `AvatarAnswerDetailSheet` |
| 今日 → 往期回答列表 | `PastAnswerDetailSheet` |
| 发现 → 点击头像区域 | `UserProfileSheet` |
| 发现 / 用户主页 → 追问 | `ProbeSheet` |
| 今日 Header → 设置按钮 | `SettingsSheet` |
| 分身 → 邀请校准卡 | `InviteCalibrationSheet` |
| 消息 → 消息行 | `MessageDetailSheet` |

---

## Mock 说明

本 Demo 所有数据均为本地内存 Mock，不请求任何系统权限或网络：

| 能力 | Mock 方式 |
|------|-----------|
| 语音录音 | 本地计时 + 动效，不录制真实音频 |
| 分身生成 | 3 条硬编码回答文案 |
| 分身对齐率 | 固定常量（42% / 68% / 73%） |
| 消息推送 | Onboarding 完成后一次性注入 |
| 邀请链接 | Mock URL，复制按钮只改本地状态 |
| 数据持久化 | 无，App 重启后重置 |

---

## 后续接入方向

接入真实后端时，建议在 `Core/` 旁新增：

```
Services/      网络层（QuestionService、AuthService 等）
Persistence/   本地存储（UserDefaults / Keychain）
Config/        环境配置（dev / staging / prod）
```

优先级：用户认证 → 语音转文字 + 分身生成 → 每日问题推送 → 分身对齐率算法 → 追问实时推送。
