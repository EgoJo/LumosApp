import SwiftUI
import Combine

/// 全局状态：当前 Tab、Onboarding 进度、本地 Mock 数据、当前弹层等
final class AppState: ObservableObject {
    // 导航
    @Published var currentTab: LumosTab = .today
    
    // Onboarding（3 题）
    @Published var onboardingStep: OnboardingStep = .q1
    @Published var hasFinishedOnboarding: Bool = false
    
    // 今日接管状态
    @Published var hasTakenOverToday: Bool = false

    // 问题 + 观点流 + 消息（本地 Mock）
    @Published var todayQuestion: Question
    @Published var pastQuestions: [Question]
    @Published var myViewpoints: [Viewpoint]
    @Published var discoverFeed: [Viewpoint]
    @Published var messages: [MessageItem]
    @Published var probedViewpointIDs: Set<UUID> = []
    
    // 弹层
    @Published var activeSheet: ActiveSheet?
    
    init() {
        // 根据 PDF / HTML 里的文案初始化一批 Mock 数据
        todayQuestion = Question(
            id: UUID(),
            text: "35岁拿了大礼包想退休，你最可能去做什么？",
            answeredCount: 47,
            dateLabel: nil,
            isToday: true
        )
        
        pastQuestions = [
            Question(
                id: UUID(),
                text: "如果现在离职，你最可能去做什么？",
                answeredCount: 31,
                dateLabel: "昨天",
                isToday: false
            ),
            Question(
                id: UUID(),
                text: "最近改变了什么之前一直坚持的判断？",
                answeredCount: 58,
                dateLabel: "周一",
                isToday: false
            ),
            Question(
                id: UUID(),
                text: "工作之外，你最近在认真对待什么？",
                answeredCount: 24,
                dateLabel: "周日",
                isToday: false
            )
        ]
        
        myViewpoints = [
            // q1 — 35岁大礼包（今日问题）
            Viewpoint(
                id: UUID(),
                ownerName: "阿基米德",
                ownerTitle: "产品经理",
                ownerBio: nil,
                isMine: true,
                question: "35岁拿了大礼包想退休，你最可能去做什么？",
                answer: "可能会去做乐队吧。不是那种想靠音乐赚钱的，就是纯粹想跟几个真正喜欢音乐的人，做出一点点让自己觉得有意思的东西。互联网做久了，太多时候都在优化，在迭代，在找更大规模。但好的东西不一定需要规模。",
                tags: ["人生"],
                probeCount: 3,
                timeLabel: "今天"
            ),
            // q2 — 工作之外（pastQuestions[2]）
            Viewpoint(
                id: UUID(),
                ownerName: "阿基米德",
                ownerTitle: "产品经理",
                ownerBio: nil,
                isMine: true,
                question: "工作之外，你最近在认真对待什么？",
                answer: "在学吉他。不是因为觉得会很酷，是因为想知道一件事从零开始学会是什么感觉，上一次有这种体验可能是大学。一个技能从「完全不会」到「能弹出一首歌」，那个过程里的挫败感和小成就感，现在想起来都很真实。",
                tags: ["人生", "随想"],
                probeCount: 0,
                timeLabel: "今天"
            ),
            // q3 — 最近改变的判断（pastQuestions[1]）
            Viewpoint(
                id: UUID(),
                ownerName: "阿基米德",
                ownerTitle: "产品经理",
                ownerBio: nil,
                isMine: true,
                question: "最近改变了什么之前一直坚持的判断？",
                answer: "以前觉得产品要极简，功能越少越好。最近开始觉得这是一个懒人逻辑——真正的极简是把复杂藏起来，而不是把功能砍掉。用户感受到的简单，背后可能是工程师和产品经理承担了所有的复杂度。",
                tags: ["产品", "判断"],
                probeCount: 1,
                timeLabel: "今天"
            )
        ]
        
        // 今日问题优先排在第一位，确保演示时 feed 顶部与今日 Tab 话题一致
        discoverFeed = [
            // ① 今日问题 — 触发「咖啡馆/面对面」分支
            Viewpoint(
                id: UUID(),
                ownerName: "林晓",
                ownerTitle: "产品总监",
                ownerBio: "做了十年产品，越来越想做一件和规模无关的事。",
                isMine: false,
                question: "35岁拿了大礼包想退休，你最可能去做什么？",
                answer: "可能会去开一家很小的咖啡馆，但不是那种网红咖啡馆。就是一个让我可以每天跟真实的人面对面聊天的地方。做了这么多年产品，越来越觉得我们在帮用户「连接」，但自己反而越来越难跟人真正连接了。",
                tags: ["人生", "退休"],
                probeCount: 5,
                timeLabel: "刚刚"
            ),
            // ② 今日问题 — 触发「技术/从零开始」分支
            Viewpoint(
                id: UUID(),
                ownerName: "李明",
                ownerTitle: "设计师",
                ownerBio: "设计师，最近在想怎么把数字审美搬到物理世界。",
                isMine: false,
                question: "35岁拿了大礼包想退休，你最可能去做什么？",
                answer: "想从零开始学一门手艺，可能是木工。数字产品做久了，太想做一件真实的、摸得到的东西。上一次有这种感觉是上大学时手工做了一把椅子，之后十几年好像再也没有这种完成感。",
                tags: ["人生", "手艺"],
                probeCount: 2,
                timeLabel: "3小时前"
            ),
            // ③ 离职问题 — 触发「技术/从零开始」分支
            Viewpoint(
                id: UUID(),
                ownerName: "陈磊",
                ownerTitle: "工程负责人",
                ownerBio: "工程师，相信五年后很重要的事现在看起来都没用。",
                isMine: false,
                question: "如果现在离职，你最可能去做什么？",
                answer: "去研究一个真正从零开始的技术方向。不是那种追热点的，是那种别人觉得没用但我觉得五年后会很重要的东西。",
                tags: ["技术"],
                probeCount: 2,
                timeLabel: "2小时前"
            ),
            // ④ 离职问题 — 触发「咖啡馆/面对面」分支
            Viewpoint(
                id: UUID(),
                ownerName: "苏妍",
                ownerTitle: "内容创作者",
                ownerBio: "内容创作者，在寻找二十人以内的真实社区。",
                isMine: false,
                question: "如果现在离职，你最可能去做什么？",
                answer: "找一个面对面聊天的社区，不需要很大，20个人就够。线上内容做了五年，最缺的反而是这个——一张桌子，几个人，聊一件真正有意思的事。",
                tags: ["人生", "社群"],
                probeCount: 3,
                timeLabel: "昨天"
            ),
            // ⑤ 判断改变问题 — fallback 分支
            Viewpoint(
                id: UUID(),
                ownerName: "王思远",
                ownerTitle: "创业者",
                ownerBio: "创业者，不融资活着，慢慢想清楚自己在做什么。",
                isMine: false,
                question: "最近改变了什么之前一直坚持的判断？",
                answer: "以前觉得创始人要大量融资才叫成功，现在觉得不融资才是最长久的护城河。融资让你跑快，但也让你没办法停下来想清楚自己到底在做什么。",
                tags: ["创业", "判断"],
                probeCount: 4,
                timeLabel: "2天前"
            ),
            // ⑥ 工作之外问题 — fallback 分支
            Viewpoint(
                id: UUID(),
                ownerName: "张颖",
                ownerTitle: "前投资人",
                ownerBio: "前投资人，现在只想把判断写下来变成真正属于自己的东西。",
                isMine: false,
                question: "工作之外，你最近在认真对待什么？",
                answer: "在写一本没人约稿的书。不是为了出版，是为了把一些判断固化下来——写出来才真的变成自己的东西，光放在脑子里会慢慢蒸发。",
                tags: ["写作", "人生"],
                probeCount: 6,
                timeLabel: "3天前"
            )
        ]
        
        // 初始消息列表为空，等用户实际发起追问后再逐步填充
        messages = []
    }
    
    // MARK: - Onboarding
    
    func startOnboardingRecording() {
        activeSheet = .onboardingRecording
    }
    
    func showOnboardingPreview() {
        activeSheet = .onboardingPreview
    }
    
    func confirmCurrentOnboardingAnswer() {
        if let next = onboardingStep.next() {
            onboardingStep = next
            activeSheet = .onboardingRecording
        } else {
            // 3 题完成
            hasFinishedOnboarding = true
            activeSheet = .onboardingDone
        }
    }
    
    func finishOnboarding() {
        hasFinishedOnboarding = true
        activeSheet = nil
        // Onboarding 回答的都是「今天」的题，更新日期标签
        for i in pastQuestions.indices {
            pastQuestions[i].dateLabel = "今天"
        }
        seedMessagesAfterOnboarding()
    }

    /// Onboarding 完成后，注入一批模拟「分身已在工作」的预置消息
    private func seedMessagesAfterOnboarding() {
        guard messages.isEmpty else { return }  // 避免重复注入
        messages = [
            MessageItem(
                id: UUID(),
                title: "林晓追问了你的分身",
                preview: "你说互联网做久了越来越难跟人真正连接，我也有这种感觉——你是从什么时候开始意识到这件事的？",
                timeLabel: "刚刚",
                isUnread: true,
                kind: .myPersona
            ),
            MessageItem(
                id: UUID(),
                title: "陈磊追问了你的分身",
                preview: "乐队这个想法有没有推进过？还是说现在还只是一个念头？",
                timeLabel: "5分钟前",
                isUnread: true,
                kind: .myPersona
            ),
            MessageItem(
                id: UUID(),
                title: "林晓的分身回复了你",
                preview: "我觉得连接不真实的那一刻，是我发现自己在会议里说的话和心里想的话已经完全不一样了……",
                timeLabel: "10分钟前",
                isUnread: true,
                kind: .otherPersona
            ),
            MessageItem(
                id: UUID(),
                title: "分身今日动态",
                preview: "分身今天已回答 3 个追问，对齐率从 42% 提升至 47%。",
                timeLabel: "今天",
                isUnread: false,
                kind: .system
            ),
        ]
    }
    
    // MARK: - Today 接管
    
    func openAvatarAnswerDetail() {
        activeSheet = .avatarAnswerDetail(
            question: todayQuestion.text,
            answer: myViewpoints.first(where: { $0.isMine })?.answer
                ?? "可能会做乐队。不是那种想靠音乐赚钱的，就是纯粹想跟几个真正喜欢音乐的人，做出一点点让自己觉得有意思的东西。"
        )
    }
    
    func takeOverToday() {
        hasTakenOverToday = true
    }
    
    func openProbe(for viewpoint: Viewpoint) {
        activeSheet = .probe(viewpoint)
    }

    func openUserProfile(for viewpoint: Viewpoint) {
        activeSheet = .userProfile(viewpoint)
    }
    
    func closeSheet() {
        activeSheet = nil
    }

    // MARK: - Settings & Invite
    
    func openSettings() {
        activeSheet = .settings
    }
    
    func openInviteCalibration() {
        activeSheet = .inviteCalibration
    }
    
    // MARK: - Messages
    
    func openMessageDetail(_ message: MessageItem) {
        if let index = messages.firstIndex(of: message) {
            var updated = message
            updated.isUnread = false
            messages[index] = updated
        }
        activeSheet = .messageDetail(message)
    }
    
    // 在本地 Mock 中记录一条追问消息（按「某人的分身」聚合）
    func sendProbe(to viewpoint: Viewpoint, text: String) {
        let title = "\(viewpoint.ownerName)的分身"
        probedViewpointIDs.insert(viewpoint.id)
        
        if let index = messages.firstIndex(where: { $0.title == title && $0.kind == .otherPersona }) {
            var updated = messages[index]
            updated.preview = text
            updated.timeLabel = "刚刚"
            updated.isUnread = true
            messages[index] = updated
        } else {
            let item = MessageItem(
                id: UUID(),
                title: title,
                preview: text,
                timeLabel: "刚刚",
                isUnread: true,
                kind: .otherPersona
            )
            messages.insert(item, at: 0)
        }
    }
    
    // MARK: - Past answers
    
    func openPastAnswer(for question: Question) {
        // 先精确命中，再用第一条 isMine 的观点作为 fallback，保证弹层总能打开
        let vp = myViewpoints.first(where: { $0.question == question.text && $0.isMine })
            ?? myViewpoints.first(where: { $0.isMine })
        if let vp {
            activeSheet = .pastAnswer(vp)
        }
    }
}

