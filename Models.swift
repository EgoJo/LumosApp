import Foundation

// 顶部 Tab
enum LumosTab: Hashable {
    case today
    case discover
    case avatar
    case messages
}

// Onboarding 步骤：3 题
enum OnboardingStep: Int {
    case q1 = 0
    case q2 = 1
    case q3 = 2
    
    var index: Int { rawValue }
    var displayIndex: Int { rawValue + 1 }
    static let total: Int = 3
    
    func next() -> OnboardingStep? {
        OnboardingStep(rawValue: rawValue + 1)
    }
}

struct Question: Identifiable, Hashable {
    let id: UUID
    let text: String
    let answeredCount: Int
    let dateLabel: String?    // 昨天 / 周一 …
    let isToday: Bool
}

struct Viewpoint: Identifiable, Hashable {
    let id: UUID
    let ownerName: String
    let ownerTitle: String?
    let isMine: Bool
    let question: String
    let answer: String
    let tags: [String]
    let probeCount: Int
    let timeLabel: String     // 刚刚 / 2天前 …
}

struct MessageItem: Identifiable, Hashable {
    enum Kind {
        case otherPersona
        case myPersona
        case system
    }
    
    let id: UUID
    let title: String
    var preview: String
    var timeLabel: String
    var isUnread: Bool
    let kind: Kind
}

// 用于统一管理当前弹层
enum ActiveSheet: Identifiable {
    case onboardingRecording
    case onboardingPreview
    case onboardingDone
    case avatarAnswerDetail
    case probe(Viewpoint)
    case settings
    case inviteCalibration
    case messageDetail(MessageItem)
    case pastAnswer(Viewpoint)
    
    var id: String {
        switch self {
        case .onboardingRecording: return "onboardingRecording"
        case .onboardingPreview:   return "onboardingPreview"
        case .onboardingDone:      return "onboardingDone"
        case .avatarAnswerDetail:  return "avatarAnswerDetail"
        case .probe(let vp):       return "probe-\(vp.id.uuidString)"
        case .settings:            return "settings"
        case .inviteCalibration:   return "inviteCalibration"
        case .messageDetail(let m):return "message-\(m.id.uuidString)"
        case .pastAnswer(let vp):  return "past-\(vp.id.uuidString)"
        }
    }
}

