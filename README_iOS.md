## Lumos 原生 iOS 工程说明（骨架）

你现在这个 `lumos` 文件夹里，将放的是 **可直接用于 Xcode 的 Swift 源码骨架**，而不是前端 HTML。后续只要按下面步骤在 Xcode 里建一个工程，把这些文件拖进去，就能得到一个可以上架的原生 App 壳（功能目前用本地 Mock 数据和本地状态机）。服务端部分后续再接。

### 一、在 Xcode 里创建 SwiftUI 工程

1. 打开 Xcode → `File > New > Project…`
2. 选择 **iOS > App** → `Next`
3. 填写：
   - Product Name：`Lumos`
   - Interface：`SwiftUI`
   - Language：`Swift`
4. 选一个目录保存，比如：`~/Desktop/LumosNative`（名字随意）。

> 下面我给你的所有 `.swift` 文件，都默认放在你当前这个 `~/Desktop/lumos` 目录下。你可以直接拖进刚建的 Xcode 工程（勾选 “Copy items if needed”）。

### 二、文件一览（我在当前目录会生成这些 Swift 文件）

- `LumosApp.swift`  
  - App 入口，配置全局 `AppState` 环境对象，启动后进入 `RootTabView`。

- `AppState.swift`  
  - 全局状态管理（`ObservableObject`），包含：
    - Onboarding 步骤（3 题语音建立分身）  
    - 今日问题 / 往期问题列表  
    - 分身观点流（我的主页）  
    - 发现页 Feed  
    - 消息 / 追问列表  
  - 所有数据目前都是 **本地 Mock**，方便你先验证体验。

- `RootTabView.swift`  
  - 整体的 Tab 结构，对应 PRD 的 4 个 Tab：
    - `今日`（Today）
    - `发现`（Discover）
    - `分身`（Avatar）
    - `消息`（Messages）
  - 用 SwiftUI 自定义 TabBar，而不是系统默认的 `TabView` 样式，以贴近你在 HTML 里那版视觉。

- `TodayView.swift`  
  - 对应 PRD 的 F01 + Onboarding 逻辑：
    - 顶部问候 + 今日问题卡片（大问题卡 + “用语音回答” CTA）  
    - 3 题 Onboarding（进度条 + 当前题号 + 文案规范）  
    - 录音 / 分身生成 / 预览 / 成功的 Flow：  
      - 这里 **先不接真实录音**，用本地计时 + 动效 Placeholder，文案完全按 PRD 走。  
    - Onboarding 完成后切换到 “Normal” 状态：  
      - 今日分身回答卡片（可以进详情）  
      - 往期问题列表（分身是否已回答 / 我是否接管）。

- `AvatarView.swift`  
  - 对应 PRD 的 F04（观点流主页）+ 一部分 F05 提示：
    - 头像 + 名字 + 一行简介 + 分身对齐率进度条  
    - “邀请朋友校准分身” 提醒卡（先不接 H5 链接，只做 UI 和点击事件）  
    - 话题筛选 Chips（全部 / 职场 / 人生 / 创业 / 随想）  
    - 观点流卡片（问题小字 + 分身回答 + 追问数 + 时间）。

- `DiscoverView.swift`  
  - 对应 PRD 的 `发现` Tab：  
    - 用本地 Mock 列出几个高质量用户的观点流卡片。  
    - 每个卡片底部有 “追问” CTA，点进去走 “智能追问” 流程（Overlay）。

- `MessagesView.swift`  
  - 对应 PRD 的 `消息` 模块 + “真人接管” 入口：  
    - 列出几条 Mock 消息：  
      - 某个用户分身回复了你  
      - 你的分身收到追问  
      - 真人接管提示  
    - 这里先只做列表和简单的点击反馈（Toast/弹层），不做完整聊天界面，后续可以再加。

- `Overlays.swift`  
  - 把 PRD 里那些 “覆盖层 / 全屏弹层” 做成可复用 SwiftUI 视图：
    - Onboarding 录音 Overlay（不接真实录音，只做 UI + 计时）  
    - 分身预览 Overlay  
    - Onboarding 完成 Overlay（分身上线 + 初始对齐率）  
    - Avatar Answer Detail（今日分身回答详情）  
    - 智能追问 Overlay（F06）  
    - 其他用户详情 Overlay

- `Models.swift`  
  - 纯数据结构定义，方便以后接后端：
    - `Question` / `Answer` / `Viewpoint` / `Probe` / `UserProfile` / `MessageItem` 等。

- `DesignSystem.swift`  
  - 把你在 HTML 里那套设计 token 抽成 Swift 常量 + ViewModifier：  
    - 颜色 / 字体 / 阴影 / 圆角  
    - 常用组件（Primary Button、Chip、卡片样式等）。

> 注意：录音、通知权限、网络、AI 分身生成等，**本轮都不接真实服务**，全部用本地 Mock 和状态机模拟，严格按你 PDF 里的文案和状态机走。这样你可以先在真机上体验完整链路，再逐步换成真实服务。

### 三、Lumos 原生工程结构图（推荐组织方式）

下面是按照 **iOS 正式项目习惯** 推荐的结构，你可以在 Xcode 里用 Group 来对应这些文件夹（物理上是否建真文件夹都可以）：

```text
Lumos
├─ App/
│  ├─ LumosApp.swift          // App 入口，创建 AppState，挂 RootTabView
│  └─ AppState.swift          // 全局状态（当前 Tab、Onboarding、Mock 数据、当前弹层）
│
├─ Core/
│  ├─ Models.swift            // Question / Viewpoint / MessageItem 等纯数据结构
│  └─ DesignSystem.swift      // 设计系统：颜色、排版、按钮样式、DeviceShell 外壳
│
├─ Features/
│  ├─ Today/
│  │  └─ TodayView.swift      // 「今日」Tab：Onboarding 三题 + 正常态今日回答 + 往期问题
│  ├─ Discover/
│  │  └─ DiscoverView.swift   // 「发现」Tab：他人观点流列表 + 追问入口
│  ├─ Avatar/
│  │  └─ AvatarView.swift     // 「分身」Tab：头像 / Bio / 对齐率 / 观点流主页
│  └─ Messages/
│     └─ MessagesView.swift   // 「消息」Tab：分身相关通知列表（分身回复 / 真人来了 等）
│
├─ UI/
│  ├─ RootTabView.swift       // 自定义 Tab 容器，切换 4 个 Tab + 统一挂 sheet
│  └─ Overlays.swift          // 所有弹层：录音 / 分身预览 / Onboarding 完成 / 追问等
│
└─ Supporting/
   └─ README_iOS.md           // 本说明文档
```

后续如果你要接后端 / 权限，可以在 `Core/` 旁边再加：

- `Services/`：网络层（`QuestionService.swift`, `AuthService.swift` 等），负责真正打 API。  
- `Persistence/`：本地存储（UserDefaults / Keychain / 数据库）。  
- `Config/`：不同环境的配置（dev / staging / prod）。

### 四、接下来你要做什么

1. 在 Xcode 中创建好 `Lumos` SwiftUI 工程。
2. 回到 Finder，进入 `~/Desktop/lumos`：
   - 把这里的所有 `.swift` 文件 **全部拖进 Xcode 工程**（勾选 “Copy items if needed”）。
3. 在 Xcode 中删除默认自动生成的 `ContentView.swift` / `LumosApp.swift`（用我给你的替换）。
4. 选一个 iPhone 模拟器（例如 iPhone 15 Pro），`Cmd+R` 运行。

### 五、执行 PRD v2：本地 Demo 完整路径说明

> 这一节描述的是「当前这个 demo 实现到什么程度」、以及「每个按钮点下去会发生什么」。所有行为都只操作本地状态，不会访问真实后端或系统权限。

- **全局状态 & Mock 数据**
  - 所有业务数据（问题、观点流、消息）都在 `AppState` 里用内存 Mock 初始化。
  - `ActiveSheet` 统一管理所有弹层，包括：Onboarding 录音/预览/完成、Avatar 今日回答详情、智能追问、设置、邀请校准、消息详情。

- **今日（Today）Tab**
  - 顶部右侧小圆按钮：进入 `SettingsSheet`（设置 / 个人信息 · Mock）。
    - 可以切换通知相关的本地开关、点击「重置体验」回到今日页。
  - Onboarding 三题：
    - 点击「用语音回答」进入 `RecordingSheet`，用本地计时+动效模拟录音。
    - 提交后进入 `PreviewSheet`，展示「你的分身会这样说」，点「就是这个感觉」推进到下一题或完成。
    - 完成三题后进入 `OnboardingDoneSheet`，看到初始对齐率等文案，并引导回今日或去发现页。
  - Onboarding 完成后：
    - 今日卡片展示分身的今天回答，可点「我来接管」进入 `AvatarAnswerDetailSheet` 查看完整回答。
    - 下方展示分身往期回答的列表（纯展示，不展开详情）。

- **发现（Discover）Tab**
  - 列表：
    - 展示多个他人分身的观点卡片，数据来自 `discoverFeed`。
    - 每卡片底部有「追问」按钮，点击进入 `ProbeSheet`（智能追问）。
  - 右上角搜索按钮：
    - 打开 `DiscoverSearchSheet`（本地搜索 Overlay），对 `discoverFeed` 做模糊匹配。
    - 支持按人名 / 头衔 / 问题 / 回答内容搜索，仅影响本次搜索视图。

- **分身（Avatar）Tab**
  - 顶部展示头像、昵称、一句话简介和分身对齐率进度条。
  - 「邀请朋友校准分身」卡片：
    - 点击进入 `InviteCalibrationSheet`，展示一条 Mock 邀请链接 + 「复制」按钮（仅本地状态变化）+ 文案说明。
  - 话题 Chips：
    - 根据「全部 / 职场 / 人生 / 创业 / 随想」在本地过滤 `myViewpoints`。
  - 观点流列表：
    - 展示我的每条观点，包含问题、分身回答摘要、时间、追问数等（仅展示）。

- **消息（Messages）Tab**
  - 列表：
    - 展示若干 `MessageItem`：包含「某人的分身」会话、「我的分身收到追问」等。
    - 未读消息有浅色背景和状态标签（例如「分身回复中」「🔥 真人来了」）。
  - 点击任一消息：
    - 通过 `openMessageDetail(_:)` 将该条 `isUnread` 置为 false。
    - 弹出 `MessageDetailSheet` 展示标题、时间和预览内容，并说明完整聊天页留待接入真实后端再实现。

- **智能追问（ProbeSheet）行为**
  - 从「发现」列表中点击卡片底部的「追问」进入。
  - 顶部展示对方分身的回答摘要，中部提供若干预设追问选项 +「自己写一个问题」入口。
  - 预设追问文案会轻度根据回答内容关键词调整：
    - 回答里出现「咖啡馆 / 面对面聊天」等生活类词汇 → 用围绕人生选择 / 真实连接的追问。
    - 出现「技术 / 从零开始 / 五年后」等职业/技术类词汇 → 用围绕技术方向、风险与试验的追问。
    - 否则使用一组通用「判断动机 / 小步试验 / 突破瞬间」的追问。
  - 底部输入框要求 10 字以上才允许发送。
  - 点击「发送追问」：
    - 调用 `sendProbe(to:viewpoint,text:)` 在本地 `messages` 中写入/更新一条消息：
      - 按「某人的分身」聚合：同一 `ownerName` 的分身只保留一个会话，更新其 `preview` 和 `timeLabel`，并标记为未读。
    - 关闭当前 Overlay，回到上一个页面。

> 小结：现在这个 demo 的目标是——**从任何一个按钮点下去，你都能走到一个有意义的 Mock 界面或状态反馈**，但不会真正发网络请求或改动系统设置，适合在产品评审和真机体验中演示完整链路。

