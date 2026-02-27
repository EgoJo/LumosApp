import SwiftUI

struct AvatarView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTopic: String = "全部"
    
    private let topics = ["全部", "职场", "人生", "创业", "随想"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                inviteCalibration
                topicChips
                Divider()
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                viewpointsList
                Spacer(minLength: 16)
            }
        }
        .background(LumosColor.paper)
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            Circle()
                .fill(LumosColor.paper2)
                .frame(width: 62, height: 62)
                .overlay(
                    Text("阿")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .italic()
                        .foregroundColor(LumosColor.ink2)
                )
                .overlay(
                    Circle()
                        .stroke(LumosColor.amber.opacity(0.4), lineWidth: 1.5)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text("阿基米德")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .italic()
                    .foregroundColor(LumosColor.ink)
                Text("产品经理，在数字世界里搞点真正美的东西。")
                    .font(.system(size: 13))
                    .foregroundColor(LumosColor.ink3)
                    .lineSpacing(3)
                HStack {
                    Text("分身对齐率")
                        .font(.system(size: 11))
                        .foregroundColor(LumosColor.ink3)
                    Spacer()
                    Text("68%")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(LumosColor.amber)
                }
                .padding(.top, 4)
                ProgressView(value: 0.68)
                    .tint(LumosColor.amber)
                    .accentColor(LumosColor.amber)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    private var inviteCalibration: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(LumosColor.amber)
                Image(systemName: "person.2.wave.2")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(LumosColor.paper)
            }
            .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text("邀请朋友校准分身")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(LumosColor.amber)
                Text("让认识你的人帮你调教")
                    .font(.system(size: 12))
                    .foregroundColor(LumosColor.amber.opacity(0.8))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(LumosColor.amber)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(LumosColor.amberBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(LumosColor.amber.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .onTapGesture {
            appState.openInviteCalibration()
        }
    }
    
    private var topicChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(topics, id: \.self) { topic in
                    Button {
                        selectedTopic = topic
                    } label: {
                        Text(topic)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 13)
                            .frame(height: 28)
                            .background(
                                Capsule()
                                    .fill(selectedTopic == topic ? LumosColor.ink : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(LumosColor.ink4.opacity(0.6), lineWidth: 1.5)
                            )
                            .foregroundColor(selectedTopic == topic ? LumosColor.paper : LumosColor.ink3)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
        }
    }
    
    private var viewpointsList: some View {
        VStack(spacing: 10) {
            ForEach(filteredViewpoints) { vp in
                VStack(alignment: .leading, spacing: 0) {
                    Text(vp.question)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                        .padding(.horizontal, 18)
                        .padding(.top, 12)
                    Text(vp.answer)
                        .font(.system(size: 14))
                        .foregroundColor(LumosColor.ink2)
                        .lineLimit(3)
                        .lineSpacing(4)
                        .padding(.horizontal, 18)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    HStack {
                        Text(vp.timeLabel)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                        Spacer()
                        if vp.probeCount > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 11, weight: .medium))
                                Text("\(vp.probeCount) 个追问")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(LumosColor.amber)
                        } else {
                            Text("无追问")
                                .font(.system(size: 11))
                                .foregroundColor(LumosColor.ink4)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .overlay(
                        Rectangle()
                            .fill(LumosColor.ink.opacity(0.05))
                            .frame(height: 1),
                        alignment: .top
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(LumosColor.ink4.opacity(0.25), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 24)
    }
    
    private var filteredViewpoints: [Viewpoint] {
        guard selectedTopic != "全部" else { return appState.myViewpoints }
        return appState.myViewpoints.filter { vp in
            vp.tags.contains(selectedTopic)
        }
    }
}

