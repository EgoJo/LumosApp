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
    var dateLabel: String?    // 昨天 / 周一 … Onboarding 完成后更新为「今天」
    let isToday: Bool
}

struct Viewpoint: Identifiable, Hashable {
    let id: UUID
    let ownerName: String
    let ownerTitle: String?
    let ownerBio: String?          // 用户一句话简介（发现页用户主页展示）
    let isMine: Bool
    let question: String
    let answer: String
    let tags: [String]
    let probeCount: Int
    let timeLabel: String
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
    case avatarAnswerDetail(question: String, answer: String)
    case probe(Viewpoint)
    case settings
    case inviteCalibration
    case messageDetail(MessageItem)
    case userProfile(Viewpoint)      // 发现页 → 用户观点主页
    case pastAnswer(Viewpoint)
    
    var id: String {
        switch self {
        case .onboardingRecording: return "onboardingRecording"
        case .onboardingPreview:   return "onboardingPreview"
        case .onboardingDone:      return "onboardingDone"
        case .avatarAnswerDetail:  return "avatarAnswerDetail"   // 参数不影响 id，弹层唯一
        case .probe(let vp):       return "probe-\(vp.id.uuidString)"
        case .settings:            return "settings"
        case .inviteCalibration:   return "inviteCalibration"
        case .messageDetail(let m):return "message-\(m.id.uuidString)"
        case .userProfile(let vp):     return "userProfile-\(vp.ownerName)"
        case .pastAnswer(let vp):  return "past-\(vp.id.uuidString)"
        }
    }
}

