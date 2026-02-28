# Lumos · iOS

原生 iOS 工程（SwiftUI），基于 [Lumos 产品概念文档](https://github.com/EgoJo/LumosApp) 与执行 PRD 的 **本地 Mock Demo**：今日问题、语音回答、分身预览、观点流、智能追问、消息与真人接管等链路均可走通，不接真实后端。

---

## Lumos 原生 iOS 工程说明（骨架）

你现在这个仓库里，是 **可直接用于 Xcode 的 Swift 源码**。在 Xcode 里建好工程、把 `.swift` 文件加入工程后，即可得到一个可运行的 App 壳（功能目前用本地 Mock 和状态机）。服务端后续再接。

### 一、在 Xcode 里创建 SwiftUI 工程

1. 打开 Xcode → `File > New > Project…`
2. 选择 **iOS > App** → `Next`
3. 填写：
   - Product Name：`Lumos`
   - Interface：`SwiftUI`
   - Language：`Swift`
4. 选一个目录保存（如 `~/Desktop/LumosApp`）。

> 将本仓库中的 `.swift` 文件拖进 Xcode 工程（勾选 “Copy items if needed”）。

### 二、文件一览

| 文件 | 说明 |
|------|------|
| `LumosApp.swift` | App 入口，全局 `AppState`，根视图 `RootTabView` |
| `AppState.swift` | 全局状态：Tab、Onboarding、今日/往期问题、观点流、消息、弹层 |
| `RootTabView.swift` | 4 个 Tab（今日 / 发现 / 分身 / 消息）+ 统一 sheet |
| `TodayView.swift` | 今日 Tab：Onboarding 3 题 + 常态今日回答 + 往期回答列表 |
| `AvatarView.swift` | 分身 Tab：头像、对齐率、邀请校准、话题筛选、观点流 |
| `DiscoverView.swift` | 发现 Tab：他人观点流卡片 + 追问入口 + 本地搜索 |
| `MessagesView.swift` | 消息 Tab：对你分身的追问 / 其他动静，空态引导 |
| `Overlays.swift` | 所有弹层：录音、分身预览、完成、今日详情、追问、设置、邀请校准、消息详情、往期详情等 |
| `Models.swift` | 数据结构：`Question` / `Viewpoint` / `MessageItem` / `ActiveSheet` 等 |
| `DesignSystem.swift` | 颜色、按钮样式、DeviceShell 外壳等 |

> 录音、网络、AI 生成等 **均为本地 Mock**，便于先跑通体验再接真实服务。

### 三、推荐工程结构（Xcode Group）

```text
Lumos
├─ App/         LumosApp.swift, AppState.swift
├─ Core/        Models.swift, DesignSystem.swift
├─ Features/    Today/, Discover/, Avatar/, Messages/
├─ UI/          RootTabView.swift, Overlays.swift
└─ Supporting/  README.md, README_iOS.md
```

### 四、运行

1. 在 Xcode 中打开工程，确认所有 `.swift` 已加入 Target。
2. 选择 iPhone 模拟器（如 iPhone 15 Pro），`Cmd+R` 运行。

### 五、执行 PRD v2：本地 Demo 路径摘要

- **今日**：设置入口、Onboarding 3 题（录音 → 分身预览 → 完成）、今日分身回答 + 我来接管、往期回答点击进详情。
- **发现**：观点流列表、追问（每条仅一次）、本地搜索。
- **分身**：邀请朋友校准、话题筛选、我的观点流。
- **消息**：空态引导、对你分身的追问 / 其他动静分区、点击进消息详情（完整展示追问内容）。

详细说明见 **README_iOS.md**。
