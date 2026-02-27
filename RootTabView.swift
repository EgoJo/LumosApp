import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        DeviceShell {
            ZStack {
                LumosColor.paper.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 顶部预留状态栏空间（9:41 + 信号电量）
                    Spacer()
                        .frame(height: 59)
                    
                    ZStack {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    CustomTabBar(current: $appState.currentTab)
                        .frame(height: 88)
                        .padding(.bottom, 12)
                }
                
                // 顶部简化版状态栏（只画时间，不做图标）
                VStack {
                    HStack {
                        Text("9:41")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(LumosColor.ink)
                            .padding(.leading, 32)
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 10)
                    Spacer()
                }
            }
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
                case .avatarAnswerDetail:
                    AvatarAnswerDetailSheet()
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
                case .pastAnswer(let vp):
                    PastAnswerDetailSheet(viewpoint: vp)
                }
            }
        }
    }
}

// 底部自定义 TabBar
private struct CustomTabBar: View {
    @Binding var current: LumosTab
    
    var body: some View {
        HStack(spacing: 32) {
            TabItem(icon: "calendar", title: "今日", isActive: current == .today)
                .onTapGesture { current = .today }
            TabItem(icon: "safari", title: "发现", isActive: current == .discover)
                .onTapGesture { current = .discover }
            TabItem(icon: "person.crop.circle", title: "分身", isActive: current == .avatar)
                .onTapGesture { current = .avatar }
            TabItem(icon: "bubble.left.and.bubble.right", title: "消息", isActive: current == .messages, showDot: true)
                .onTapGesture { current = .messages }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [LumosColor.paper, LumosColor.paper.opacity(0.0)]),
                startPoint: .bottom,
                endPoint: .top
            )
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

