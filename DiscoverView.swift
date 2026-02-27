import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isShowingSearch = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                ForEach(appState.discoverFeed) { vp in
                    feedCard(for: vp)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }
                Spacer(minLength: 24)
            }
        }
        .background(LumosColor.paper)
        .sheet(isPresented: $isShowingSearch) {
            DiscoverSearchSheet()
                .environmentObject(appState)
        }
    }
    
    private var header: some View {
        HStack {
            Text("发现")
                .font(.system(size: 30, weight: .light, design: .serif))
                .italic()
                .foregroundColor(LumosColor.ink)
            Spacer()
            Button {
                isShowingSearch = true
            } label: {
                Circle()
                    .stroke(LumosColor.ink4.opacity(0.6), lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }
    
    private func feedCard(for vp: Viewpoint) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(LumosColor.paper2)
                    .frame(width: 42, height: 42)
                    .overlay(
                        Text(String(vp.ownerName.first ?? "·"))
                            .font(.system(size: 18, weight: .light, design: .serif))
                            .italic()
                            .foregroundColor(vp.isMine ? LumosColor.ink3 : LumosColor.ink2)
                    )
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(vp.ownerName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink)
                        if let title = vp.ownerTitle {
                            Text(title)
                                .font(.system(size: 9, weight: .medium))
                                .padding(.horizontal, 7)
                                .frame(height: 18)
                                .background(
                                    Capsule()
                                        .fill(LumosColor.ink.opacity(0.05))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(LumosColor.ink4.opacity(0.6), lineWidth: 1)
                                )
                                .foregroundColor(LumosColor.ink3)
                        }
                    }
                    Text("分身回答 · \(vp.timeLabel)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                }
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 16)
            Text(vp.question)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(LumosColor.ink4)
                .padding(.horizontal, 18)
                .padding(.top, 6)
            Text(vp.answer)
                .font(.system(size: 14))
                .foregroundColor(LumosColor.ink2)
                .lineLimit(4)
                .lineSpacing(4)
                .padding(.horizontal, 18)
                .padding(.top, 4)
                .padding(.bottom, 10)
            HStack {
                HStack(spacing: 6) {
                    ForEach(vp.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 9)
                            .frame(height: 22)
                            .background(
                                Capsule()
                                    .fill(LumosColor.ink.opacity(0.04))
                            )
                            .foregroundColor(LumosColor.ink3)
                    }
                }
                Spacer()
                let hasProbed = appState.probedViewpointIDs.contains(vp.id)
                Button {
                    if !hasProbed {
                        appState.openProbe(for: vp)
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: hasProbed ? "checkmark.circle.fill" : "text.bubble.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(hasProbed ? "已追问" : "追问")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(hasProbed ? LumosColor.ink3 : LumosColor.paper)
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(hasProbed ? LumosColor.ink.opacity(0.05) : LumosColor.ink)
                    .cornerRadius(10)
                }
                .disabled(hasProbed)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Rectangle()
                    .fill(LumosColor.paper)
                    .overlay(
                        Rectangle()
                            .fill(LumosColor.ink.opacity(0.05))
                            .frame(height: 1),
                        alignment: .top
                    )
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
    }
}

private struct DiscoverSearchSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var query: String = ""
    
    private var filtered: [Viewpoint] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return appState.discoverFeed }
        return appState.discoverFeed.filter { vp in
            vp.ownerName.localizedCaseInsensitiveContains(q)
            || (vp.ownerTitle ?? "").localizedCaseInsensitiveContains(q)
            || vp.question.localizedCaseInsensitiveContains(q)
            || vp.answer.localizedCaseInsensitiveContains(q)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack {
                    TextField("搜索问题、回答或人名…", text: $query)
                        .textFieldStyle(.roundedBorder)
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(LumosColor.ink3)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                if filtered.isEmpty {
                    Spacer()
                    Text("暂时没有匹配的观点\n可以换个说法再试试。")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .foregroundColor(LumosColor.ink4)
                        .padding(.horizontal, 24)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filtered) { vp in
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(vp.ownerName)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(LumosColor.ink)
                                    Text(vp.question)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(LumosColor.ink4)
                                    Text(vp.answer)
                                        .font(.system(size: 13))
                                        .foregroundColor(LumosColor.ink2)
                                        .lineLimit(3)
                                        .lineSpacing(4)
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                Spacer(minLength: 0)
            }
            .background(LumosColor.paper.ignoresSafeArea())
            .navigationTitle("搜索（本地 Mock）")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


