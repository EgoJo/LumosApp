import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            LumosColor.paper.ignoresSafeArea()
            
            // 主内容根据当前 Tab 切换
            Group {
                switch appState.currentTab {
                case .today:
                    TodayView()
                case .discover:
                    DiscoverView()
                case .avatar:
                    AvatarView()
                case .messages:
                    MessagesView()
                }
            }
        }
        // 顶部自定义状态栏，使用 safeAreaInset 适配不同机型
        .safeAreaInset(edge: .top) {
            HStack {
                Text("9:41")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(LumosColor.ink)
                    .padding(.leading, 24)
                Spacer()
            }
            .padding(.top, 4)
            .padding(.bottom, 6)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [LumosColor.paper.opacity(0.98), LumosColor.paper.opacity(0.9)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        // 底部 TabBar，同样用 safeAreaInset 贴合各机型 Home Indicator
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(current: $appState.currentTab)
                .environmentObject(appState)
                .padding(.top, 4)
                .padding(.bottom, 6)
        }
        // 统一挂载所有弹层
        .sheet(item: $appState.activeSheet) { sheet in
            switch sheet {
            case .onboardingRecording:
                RecordingSheet()
                    .environmentObject(appState)
            case .onboardingPreview:
                PreviewSheet()
                    .environmentObject(appState)
            case .onboardingDone:
                OnboardingDoneSheet()
                    .environmentObject(appState)
            case .avatarAnswerDetail(let question, let answer):
                AvatarAnswerDetailSheet(question: question, answer: answer)
                    .environmentObject(appState)
            case .probe(let vp):
                ProbeSheet(viewpoint: vp)
                    .environmentObject(appState)
            case .settings:
                SettingsSheet()
                    .environmentObject(appState)
            case .inviteCalibration:
                InviteCalibrationSheet()
                    .environmentObject(appState)
            case .messageDetail(let message):
                MessageDetailSheet(message: message)
            case .userProfile(let vp):
                UserProfileSheet(viewpoint: vp)
                    .environmentObject(appState)
            case .pastAnswer(let vp):
                PastAnswerDetailSheet(viewpoint: vp)
            }
        }
    }
}

// 底部自定义 TabBar
private struct CustomTabBar: View {
    @Binding var current: LumosTab
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        HStack(spacing: 32) {
            TabItem(icon: "calendar", title: "今日", isActive: current == .today)
                .onTapGesture { current = .today }
            TabItem(icon: "safari", title: "发现", isActive: current == .discover)
                .onTapGesture { current = .discover }
            TabItem(icon: "person.crop.circle", title: "分身", isActive: current == .avatar)
                .onTapGesture { current = .avatar }
            TabItem(icon: "bubble.left.and.bubble.right", title: "消息", isActive: current == .messages,
                    showDot: appState.messages.contains(where: { $0.isUnread }))
                .onTapGesture { current = .messages }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.vertical, 8)
        .background(
            Color(LumosColor.paper)
        )
    }
}

private struct TabItem: View {
    let icon: String
    let title: String
    let isActive: Bool
    var showDot: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(isActive ? LumosColor.ink2 : LumosColor.ink4)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(isActive ? LumosColor.ink.opacity(0.06) : Color.clear)
                    )
                if showDot {
                    Circle()
                        .fill(LumosColor.amber)
                        .frame(width: 7, height: 7)
                        .offset(x: 4, y: -2)
                }
            }
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(isActive ? LumosColor.ink : LumosColor.ink3)
        }
        .frame(minWidth: 60)
    }
}

