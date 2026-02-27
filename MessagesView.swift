import SwiftUI

struct MessagesView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if appState.messages.isEmpty {
                    emptyState
                } else {
                // 对我分身的追问（单独区域）
                let myPersonaMessages = appState.messages.filter { $0.kind == .myPersona }
                let otherMessages = appState.messages.filter { $0.kind != .myPersona }
                
                if !myPersonaMessages.isEmpty {
                    sectionHeader(title: "对你分身的追问")
                    ForEach(myPersonaMessages) { msg in
                        messageRow(msg, highlightKind: .myPersona)
                            .background(Color.clear)
                            .onTapGesture {
                                appState.openMessageDetail(msg)
                            }
                    }
                    Spacer()
                        .frame(height: 12)
                }
                
                if !otherMessages.isEmpty {
                    sectionHeader(title: "分身世界的其他动静")
                    ForEach(otherMessages) { msg in
                        messageRow(msg, highlightKind: .otherPersona)
                            .background(Color.clear)
                            .onTapGesture {
                                appState.openMessageDetail(msg)
                            }
                    }
                }
                }
                Spacer(minLength: 24)
            }
        }
        .background(LumosColor.paper)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("消息")
                .font(.system(size: 30, weight: .light, design: .serif))
                .italic()
                .foregroundColor(LumosColor.ink)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Text("还没有任何消息")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(LumosColor.ink2)
            Text("当你对别人的分身发起追问，或者有人对你的分身提出好问题时，都会出现在这里。")
                .font(.system(size: 13))
                .foregroundColor(LumosColor.ink4)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
            Button {
                appState.currentTab = .discover
            } label: {
                Text("去发现页，发起第一条追问")
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 18)
                    .frame(height: 36)
                    .background(LumosColor.ink)
                    .foregroundColor(LumosColor.paper)
                    .cornerRadius(18)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(LumosColor.ink4)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    private func messageRow(_ msg: MessageItem, highlightKind: MessageItem.Kind) -> some View {
        HStack(alignment: .top, spacing: 13) {
            avatar(for: msg)
                .padding(.leading, 24)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(msg.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(LumosColor.ink)
                    Spacer()
                    Text(msg.timeLabel)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                }
                Text(msg.preview)
                    .font(.system(size: 13))
                    .foregroundColor(LumosColor.ink3)
                    .lineLimit(2)
                if msg.isUnread {
                    let isMine = msg.kind == .myPersona
                    let label = isMine ? "有人在追问你" : "分身回复中"
                    HStack(spacing: 6) {
                        Text(label)
                            .font(.system(size: 9, weight: .medium))
                            .padding(.horizontal, 8)
                            .frame(height: 18)
                            .background(
                                Capsule()
                                    .fill(isMine ? LumosColor.amberBg : LumosColor.ink.opacity(0.06))
                            )
                            .foregroundColor(isMine ? LumosColor.amber : LumosColor.ink3)
                    }
                }
            }
            .padding(.trailing, 24)
        }
        .padding(.vertical, 14)
        .background(
            msg.isUnread ?
                Color.white.opacity(0.65) :
                Color.clear
        )
        .overlay(
            Rectangle()
                .fill(LumosColor.ink.opacity(0.05))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func avatar(for msg: MessageItem) -> some View {
        Circle()
            .fill(msg.kind == .system ? LumosColor.paper3 : LumosColor.paper2)
            .frame(width: 46, height: 46)
            .overlay(
                Group {
                    if msg.kind == .system {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 18))
                            .foregroundColor(LumosColor.ink4)
                    } else {
                        Text(String(msg.title.first ?? "·"))
                            .font(.system(size: 19, weight: .light, design: .serif))
                            .italic()
                            .foregroundColor(LumosColor.ink3)
                    }
                }
            )
    }
}

