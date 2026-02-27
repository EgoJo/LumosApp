import SwiftUI
import Combine

/// 全局状态：当前 Tab、Onboarding 进度、本地 Mock 数据、当前弹层等
final class AppState: ObservableObject {
    // 导航
    @Published var currentTab: LumosTab = .today
    
    // Onboarding（3 题）
    @Published var onboardingStep: OnboardingStep = .q1
    @Published var hasFinishedOnboarding: Bool = false
    
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
            Viewpoint(
                id: UUID(),
                ownerName: "阿基米德",
                ownerTitle: "产品经理",
                isMine: true,
                question: "如果现在离职，你最可能去做什么？",
                answer: "可能会做乐队。不是那种想靠音乐赚钱的，就是纯粹想跟几个真正喜欢音乐的人，做出一点点让自己觉得有意思的东西。互联网做久了，太多时候都在优化，在迭代，在找更大规模。但好的东西不一定需要规模。",
                tags: ["职场", "人生"],
                probeCount: 3,
                timeLabel: "2天前"
            ),
            Viewpoint(
                id: UUID(),
                ownerName: "阿基米德",
                ownerTitle: "产品经理",
                isMine: true,
                question: "最近改变了什么之前一直坚持的判断？",
                answer: "以前觉得产品要极简，功能越少越好。最近开始觉得这是一个懒人逻辑——真正的极简是把复杂藏起来，而不是把功能砍掉。",
                tags: ["产品", "判断"],
                probeCount: 1,
                timeLabel: "4天前"
            )
        ]
        
        discoverFeed = [
            Viewpoint(
                id: UUID(),
                ownerName: "林晓",
                ownerTitle: "产品总监",
                isMine: false,
                question: "35岁拿了大礼包想退休，你最可能去做什么？",
                answer: "可能会去开一家很小的咖啡馆，但不是那种网红咖啡馆。就是一个让我可以每天跟真实的人面对面聊天的地方。做了这么多年产品，越来越觉得我们在帮用户「连接」，但自己反而越来越难跟人真正连接了。",
                tags: ["人生", "退休"],
                probeCount: 5,
                timeLabel: "刚刚"
            ),
            Viewpoint(
                id: UUID(),
                ownerName: "陈磊",
                ownerTitle: "工程负责人",
                isMine: false,
                question: "如果现在离职，你最可能去做什么？",
                answer: "去研究一个真正从零开始的技术方向。不是那种追热点的，是那种别人觉得没用但我觉得五年后会很重要的东西。",
                tags: ["技术"],
                probeCount: 2,
                timeLabel: "2小时前"
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
        activeSheet = nil
    }
    
    // MARK: - Probe
    
    func openProbe(for viewpoint: Viewpoint) {
        activeSheet = .probe(viewpoint)
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
        if let vp = myViewpoints.first(where: { $0.question == question.text && $0.isMine }) {
            activeSheet = .pastAnswer(vp)
        }
    }
}

