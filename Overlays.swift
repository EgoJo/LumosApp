import SwiftUI

// MARK: - Onboarding 录音（本地 Mock）

struct RecordingSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRecording = false
    @State private var seconds = 0
    @State private var timer: Timer?
    @State private var hasRecordedOnce = false
    @State private var isPlayingPreview = false
    
    private var currentQuestion: Question {
        switch appState.onboardingStep {
        case .q1: return appState.todayQuestion
        case .q2: return appState.pastQuestions[2]
        case .q3: return appState.pastQuestions[1]
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LumosColor.paper.ignoresSafeArea()
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("建立分身 · 第 \(appState.onboardingStep.displayIndex) 题")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.amber)
                        Text(currentQuestion.text)
                            .font(.system(size: 21, weight: .light, design: .serif))
                            .italic()
                            .foregroundColor(LumosColor.ink)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    Spacer()
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(LumosColor.amber.opacity(isRecording ? 0.4 : 0.15), lineWidth: 18)
                                .frame(width: 180, height: 180)
                                .scaleEffect(isRecording ? 1.05 : 1)
                                .animation(.easeOut(duration: 0.5).repeatForever(autoreverses: true), value: isRecording)
                            Button {
                                toggleRecording()
                            } label: {
                                Circle()
                                    .fill(isRecording ? LumosColor.red : LumosColor.ink)
                                    .frame(width: 96, height: 96)
                                    .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 10)
                                    .overlay(
                                        Image(systemName: "waveform")
                                            .font(.system(size: 28, weight: .semibold))
                                            .foregroundColor(LumosColor.paper)
                                    )
                            }
                        }
                        Text(timeString)
                            .font(.system(size: 20, weight: .semibold, design: .monospaced))
                            .foregroundColor(LumosColor.ink)
                        Text(hintText)
                            .font(.system(size: 13))
                            .foregroundColor(LumosColor.ink4)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        // 录音完成后的「听一遍 / 重录」操作区（Mock）
                        if hasRecordedOnce && !isRecording {
                            HStack(spacing: 12) {
                                Button {
                                    // Mock 回放，不做真实音频处理
                                    isPlayingPreview.toggle()
                                } label: {
                                    Text(isPlayingPreview ? "正在回放（Mock）" : "听一遍（Mock）")
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 14)
                                        .frame(height: 32)
                                        .background(
                                            Capsule()
                                                .fill(LumosColor.ink.opacity(0.06))
                                        )
                                        .foregroundColor(LumosColor.ink3)
                                }
                                Button {
                                    // 重录：清空计时与状态
                                    seconds = 0
                                    hasRecordedOnce = false
                                    isPlayingPreview = false
                                } label: {
                                    Text("重录")
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 18)
                                        .frame(height: 32)
                                        .background(
                                            Capsule()
                                                .stroke(LumosColor.ink4.opacity(0.4), lineWidth: 1.5)
                                        )
                                        .foregroundColor(LumosColor.ink3)
                                }
                            }
                        }
                    }
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: submit) {
                            Text("提交，看分身怎么说")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!hasRecordedOnce || seconds < 3)
                        .opacity((!hasRecordedOnce || seconds < 3) ? 0.5 : 1.0)
                        .frame(maxWidth: 280)
                        Button {
                            dismiss()
                            appState.closeSheet()
                        } label: {
                            Text("再想想")
                        }
                        .buttonStyle(GhostButtonStyle())
                        .disabled(!hasRecordedOnce)
                        .opacity(!hasRecordedOnce ? 0.5 : 1.0)
                        .frame(maxWidth: 280)
                    }
                    .padding(.bottom, 24)
                }
                .padding(.top, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                        appState.closeSheet()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
            }
        }
    }
    
    private var timeString: String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
    
    private var hintText: String {
        if isRecording {
            return "正在录音… 再次点击停止"
        } else if hasRecordedOnce {
            return "录好了 ✓ 可以听一遍，或者直接提交"
        } else {
            return "点击麦克风开始录音\n随口说就好，就像跟朋友聊天"
        }
    }
    
    private func toggleRecording() {
        if isRecording {
            isRecording = false
            timer?.invalidate()
            timer = nil
            hasRecordedOnce = seconds > 0
        } else {
            isRecording = true
            // 开始新的录音前重置回放状态
            isPlayingPreview = false
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                seconds += 1
            }
        }
    }
    
    private func submit() {
        timer?.invalidate()
        timer = nil
        isRecording = false
        appState.showOnboardingPreview()
    }
}

// MARK: - 分身预览（Onboarding）

struct PreviewSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    private var previewText: String {
        switch appState.onboardingStep {
        case .q1:
            return "可能会去做乐队吧。不是那种想靠音乐赚钱的，就是纯粹想跟几个真正喜欢音乐的人，做出一点点让自己觉得有意思的东西。互联网做久了，太多时候都在优化，在迭代，在找更大规模。但好的东西不一定需要规模。"
        case .q2:
            return "在学吉他。不是因为觉得会很酷，是因为想知道一件事从零开始学会是什么感觉，上一次有这种体验可能是大学。"
        case .q3:
            return "以前觉得产品要极简，功能越少越好。最近开始觉得这是一个懒人逻辑——真正的极简是把复杂藏起来，而不是把功能砍掉。"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LumosColor.paper.ignoresSafeArea()
                VStack(spacing: 16) {
                    Text("你的分身会这样说")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(LumosColor.ink)
                        .padding(.top, 16)
                    Text("建立分身 · 第 \(appState.onboardingStep.displayIndex) 题预览")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(LumosColor.amberBg)
                        )
                        .foregroundColor(LumosColor.amber)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(LumosColor.paper2)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text("阿")
                                            .font(.system(size: 12, weight: .light, design: .serif))
                                            .italic()
                                            .foregroundColor(LumosColor.ink2)
                                    )
                                Text("阿基米德的分身")
                                    .font(.system(size: 12))
                                    .foregroundColor(LumosColor.ink3)
                            }
                            Text(previewText)
                                .font(.system(size: 15))
                                .foregroundColor(LumosColor.ink)
                                .lineSpacing(5)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .stroke(LumosColor.ink4.opacity(0.25), lineWidth: 1.5)
                                )
                        )
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    }
                    Text("像你说话的方式吗？不像可以调。")
                        .font(.system(size: 13))
                        .foregroundColor(LumosColor.ink4)
                    VStack(spacing: 10) {
                        Button {
                            dismiss()
                            appState.confirmCurrentOnboardingAnswer()
                        } label: {
                            Text(appState.onboardingStep == .q3 ? "就是这个感觉，完成" : "就是这个感觉，下一题")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .frame(maxWidth: 280)
                        Button {
                            dismiss()
                            appState.startOnboardingRecording()
                        } label: {
                            Text("重新录音")
                        }
                        .buttonStyle(GhostButtonStyle())
                        .frame(maxWidth: 280)
                    }
                    .padding(.bottom, 24)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                        appState.startOnboardingRecording()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
            }
        }
    }
}

// MARK: - Onboarding 完成

struct OnboardingDoneSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                ZStack {
                    Circle()
                        .fill(LumosColor.amber)
                        .frame(width: 96, height: 96)
                        .shadow(color: LumosColor.amber.opacity(0.35), radius: 18, x: 0, y: 10)
                    Image(systemName: "checkmark")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(LumosColor.paper)
                }
                Text("你的分身上线了")
                    .font(.system(size: 26, weight: .light, design: .serif))
                    .italic()
                    .foregroundColor(LumosColor.ink)
                Text("从今天起，分身会自动回答每日问题\n同频的人就能找到你了。")
                    .font(.system(size: 14))
                    .foregroundColor(LumosColor.ink3)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                VStack(alignment: .leading, spacing: 8) {
                    Text("初始对齐率")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.amber.opacity(0.8))
                    HStack {
                        Text("分身刚刚建立 → ")
                            .font(.system(size: 14))
                            .foregroundColor(LumosColor.ink2)
                        Text("42%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.amber)
                        Spacer()
                        Text("42%")
                            .font(.system(size: 32, weight: .light, design: .serif))
                            .italic()
                            .foregroundColor(LumosColor.amber)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(LumosColor.amberBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(LumosColor.amber.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)
                Text("继续回答更多问题或邀请朋友校准，分身对齐率会越来越高。")
                    .font(.system(size: 13))
                    .foregroundColor(LumosColor.ink4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                VStack(spacing: 10) {
                    Button {
                        dismiss()
                        appState.finishOnboarding()   // 同时 seed 预置消息
                    } label: {
                        Text("看看分身今天说了什么")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button {
                        appState.currentTab = .discover
                        dismiss()
                        appState.finishOnboarding()   // 同时 seed 预置消息
                    } label: {
                        Text("去发现页看看")
                    }
                    .buttonStyle(GhostButtonStyle())
                }
                .padding(.bottom, 24)
            }
            .background(LumosColor.paper.ignoresSafeArea())
        }
    }
}

// MARK: - Avatar 今日回答详情

struct AvatarAnswerDetailSheet: View {
    let question: String
    let answer: String
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var humanReply: String = ""
    @State private var hasSentHumanReply: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("今日问题")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                    Text(question)
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .italic()
                        .foregroundColor(LumosColor.ink)
                        .lineSpacing(4)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(LumosColor.paper2)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("阿")
                                        .font(.system(size: 13, weight: .light, design: .serif))
                                        .italic()
                                        .foregroundColor(LumosColor.ink2)
                                )
                            Text("阿基米德的分身 · 今天 09:14")
                                .font(.system(size: 12))
                                .foregroundColor(LumosColor.ink3)
                        }
                        Text(answer)
                            .font(.system(size: 14.5))
                            .foregroundColor(LumosColor.ink)
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(LumosColor.ink4.opacity(0.25), lineWidth: 1.5)
                            )
                    )
                    .padding(.top, 4)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(hasSentHumanReply ? "你的真人回复" : "亲自接管一下？")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(hasSentHumanReply ? LumosColor.amber : LumosColor.ink4)
                        
                        // 已接管时展示已发回复气泡，可继续编辑
                        if hasSentHumanReply {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("阿基米德 · 真人")
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(LumosColor.amber)
                                Text(humanReply)
                                    .font(.system(size: 14))
                                    .foregroundColor(LumosColor.ink2)
                                    .lineSpacing(4)
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(LumosColor.amberBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(LumosColor.amber.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        TextEditor(text: $humanReply)
                            .frame(minHeight: 80, maxHeight: 140)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                            )
                            .overlay(
                                Group {
                                    if humanReply.isEmpty {
                                        Text(hasSentHumanReply
                                             ? "修改你的回复…"
                                             : "写下你想亲自说的话（Mock，不会真的发送）…")
                                            .font(.system(size: 13))
                                            .foregroundColor(LumosColor.ink5)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                        
                        Button {
                            // 写入接管状态，之后 Today 卡片同步
                            appState.takeOverToday()
                            hasSentHumanReply = true
                        } label: {
                            Text(hasSentHumanReply ? "更新真人回复（Mock）" : "发送真人回复（Mock）")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(humanReply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(LumosColor.paper.ignoresSafeArea())
            .navigationTitle(hasSentHumanReply ? "我的回复" : "分身今日回答")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
            }
        }
    }
}

// MARK: - 往期分身回答详情（Today → 分身往期回答）

struct PastAnswerDetailSheet: View {
    let viewpoint: Viewpoint
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("当时的问题")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                    Text(viewpoint.question)
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .italic()
                        .foregroundColor(LumosColor.ink)
                        .lineSpacing(4)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Circle()
                                .fill(LumosColor.paper2)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("阿")
                                        .font(.system(size: 13, weight: .light, design: .serif))
                                        .italic()
                                        .foregroundColor(LumosColor.ink2)
                                )
                            Text("阿基米德的分身 · \(viewpoint.timeLabel)")
                                .font(.system(size: 12))
                                .foregroundColor(LumosColor.ink3)
                        }
                        Text(viewpoint.answer)
                            .font(.system(size: 14.5))
                            .foregroundColor(LumosColor.ink)
                            .lineSpacing(5)
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(LumosColor.ink4.opacity(0.25), lineWidth: 1.5)
                            )
                    )
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(LumosColor.paper.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
            }
        }
    }
}

// MARK: - 智能追问（针对某条观点）

struct ProbeSheet: View {
    let viewpoint: Viewpoint
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedIndex: Int? = nil
    @State private var text: String = ""
    
    private var presets: [String] {
        let answer = viewpoint.answer
        // 轻度根据回答内容关键词切换不同风格的预设追问
        if answer.contains("咖啡馆") || answer.contains("面对面聊天") {
            return [
                "你说想跟「真实的人」连接，是什么时候开始觉得现在的连接不真实了？",
                "如果真的开了这家小咖啡馆，你最想每天重复做的一件事是什么？",
                "在现实约束（房租、时间、家人）里，你觉得离这家咖啡馆还有多远？"
            ]
        } else if answer.contains("技术") || answer.contains("从零开始") || answer.contains("五年后") {
            return [
                "你现在最想从零研究的那个技术方向，具体是什么？",
                "如果五年后这个方向没跑出来，你会觉得最可惜的是什么——时间、钱，还是别的？",
                "在现有工作里，有什么小实验可以预演一下这个方向，而不用直接 all in？"
            ]
        } else {
            return [
                "这件事对你来说，最核心的吸引力是什么？",
                "如果把现在的选择拆成几个小试验，你会先从哪一步开始？",
                "有没有一个瞬间，让你突然意识到自己已经不再满足于现在的状态？"
            ]
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewpoint.ownerName) 的分身说")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                    Text(viewpoint.answer)
                        .font(.system(size: 13.5))
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
                .padding(.horizontal, 24)
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("选一个追问方向")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                        ForEach(presets.indices, id: \.self) { idx in
                            probeOption(index: idx, text: presets[idx])
                        }
                        probeOption(index: presets.count, text: "自己写一个问题", isCustom: true)
                    }
                    .padding(.horizontal, 24)
                }
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $text)
                        .frame(minHeight: 80, maxHeight: 120)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(LumosColor.ink4.opacity(0.3), lineWidth: 1.5)
                                )
                        )
                        .overlay(
                            Group {
                                if text.isEmpty {
                                    Text("在这里写下你的追问（20—100字）…")
                                        .font(.system(size: 14))
                                        .foregroundColor(LumosColor.ink5)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 14)
                                        .allowsHitTesting(false)
                                }
                            }
                        )
                    Button {
                        appState.sendProbe(to: viewpoint, text: text.trimmingCharacters(in: .whitespacesAndNewlines))
                        dismiss()
                        appState.closeSheet()
                    } label: {
                        Text("发送追问")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).count < 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(LumosColor.paper.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                        appState.closeSheet()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("追问 \(viewpoint.ownerName)")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
    
    private func probeOption(index: Int, text presetText: String, isCustom: Bool = false) -> some View {
        Button {
            selectedIndex = index
            if isCustom {
                text = ""
            } else {
                text = presetText
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Text(isCustom ? "自" : String(format: "%02d", index + 1))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(isCustom ? LumosColor.ink4 : LumosColor.amber)
                    .padding(.top, 2)
                Text(presetText)
                    .font(.system(size: 13.5))
                    .foregroundColor(isCustom ? LumosColor.ink4 : LumosColor.ink2)
                    .multilineTextAlignment(.leading)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selectedIndex == index ? LumosColor.amberBg : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                selectedIndex == index ? LumosColor.amber : LumosColor.ink4.opacity(0.25),
                                lineWidth: 1.5
                            )
                    )
            )
        }
    }
}

// MARK: - 设置 / 个人信息（Mock）

struct SettingsSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var isNotificationOn: Bool = true
    @State private var isPreviewAIHintsOn: Bool = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("账号").font(.system(size: 12, weight: .medium))) {
                    HStack {
                        Circle()
                            .fill(LumosColor.paper2)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("阿")
                                    .font(.system(size: 18, weight: .light, design: .serif))
                                    .italic()
                                    .foregroundColor(LumosColor.ink2)
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            Text("阿基米德")
                                .font(.system(size: 16, weight: .semibold))
                            Text("产品经理，在数字世界里搞点真正美的东西。")
                                .font(.system(size: 12))
                                .foregroundColor(LumosColor.ink4)
                        }
                    }
                }
                
                Section(header: Text("通知 & 分身").font(.system(size: 12, weight: .medium))) {
                    Toggle(isOn: $isNotificationOn) {
                        Text("有新追问时提醒我（Mock）")
                    }
                    Toggle(isOn: $isPreviewAIHintsOn) {
                        Text("优先用分身先回复，再提醒真人接管")
                    }
                }
                
                Section(footer: Text("本页为 Demo 设置，仅用于体验流程，不会真的修改系统权限或网络配置。").font(.system(size: 11)).foregroundColor(LumosColor.ink4)) {
                    Button(role: .destructive) {
                        appState.currentTab = .today
                        dismiss()
                    } label: {
                        Text("重置体验（回到今日页）")
                    }
                }
            }
            .navigationTitle("设置 / 个人信息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                        appState.closeSheet()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
            }
        }
    }
}

// MARK: - 邀请朋友校准分身（Mock）

struct InviteCalibrationSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var hasCopiedLink = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                Text("邀请朋友校准分身")
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .italic()
                    .foregroundColor(LumosColor.ink)
                Text("他们比任何模型都更了解你。这里用 Mock 链接模拟整个流程，方便你走完整体验。")
                    .font(.system(size: 14))
                    .foregroundColor(LumosColor.ink3)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Mock 邀请链接")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                    HStack {
                        Text("https://lumos.app/invite/mock-abc123")
                            .font(.system(size: 13))
                            .foregroundColor(LumosColor.ink2)
                            .lineLimit(1)
                        Spacer()
                        Button {
                            hasCopiedLink = true
                        } label: {
                            Text(hasCopiedLink ? "已复制" : "复制")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .frame(height: 30)
                                .background(LumosColor.ink)
                                .foregroundColor(LumosColor.paper)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(LumosColor.paper2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(LumosColor.ink4.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)
                Text("真实环境下，这里会调起系统分享面板（微信、短信等）。本 Demo 仅做路径演示。")
                    .font(.system(size: 12))
                    .foregroundColor(LumosColor.ink4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
                Button {
                    dismiss()
                    appState.closeSheet()
                } label: {
                    Text("好的，知道了")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(LumosColor.paper.ignoresSafeArea())
        }
    }
}

// MARK: - 用户观点主页（发现页 → 点击头像/名字进入）

struct UserProfileSheet: View {
    let viewpoint: Viewpoint          // 用来识别是哪个用户，以及初始展示哪条观点
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // 该用户在 discoverFeed 里的所有观点
    private var allViewpoints: [Viewpoint] {
        appState.discoverFeed.filter { $0.ownerName == viewpoint.ownerName }
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── 顶部用户信息 ──────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center, spacing: 16) {
                            Circle()
                                .fill(LumosColor.paper2)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(String(viewpoint.ownerName.first ?? "·"))
                                        .font(.system(size: 24, weight: .light, design: .serif))
                                        .italic()
                                        .foregroundColor(LumosColor.ink2)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(LumosColor.ink4.opacity(0.35), lineWidth: 1)
                                )
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 8) {
                                    Text(viewpoint.ownerName)
                                        .font(.system(size: 22, weight: .light, design: .serif))
                                        .italic()
                                        .foregroundColor(LumosColor.ink)
                                    if let title = viewpoint.ownerTitle {
                                        Text(title)
                                            .font(.system(size: 10, weight: .medium))
                                            .padding(.horizontal, 8)
                                            .frame(height: 20)
                                            .background(
                                                Capsule().fill(LumosColor.ink.opacity(0.05))
                                            )
                                            .overlay(
                                                Capsule()
                                                    .stroke(LumosColor.ink4.opacity(0.5), lineWidth: 1)
                                            )
                                            .foregroundColor(LumosColor.ink3)
                                    }
                                }
                                if let bio = viewpoint.ownerBio {
                                    Text(bio)
                                        .font(.system(size: 13))
                                        .foregroundColor(LumosColor.ink3)
                                        .lineSpacing(3)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 16)

                        // 分身对齐率（展示用，不可操作）
                        HStack(spacing: 10) {
                            Text("分身对齐率")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(LumosColor.ink4)
                            ProgressView(value: 0.73)
                                .tint(LumosColor.amber)
                                .frame(maxWidth: .infinity)
                            Text("73%")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(LumosColor.amber)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)

                        Divider()
                            .padding(.horizontal, 24)
                    }
                    .background(LumosColor.paper)

                    // ── 观点列表 ──────────────────────────────────
                    VStack(alignment: .leading, spacing: 0) {
                        Text("TA 的分身观点")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                            .tracking(0.12)
                            .padding(.horizontal, 24)
                            .padding(.top, 18)
                            .padding(.bottom, 10)

                        ForEach(allViewpoints) { vp in
                            profileViewpointCard(for: vp)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                        }
                    }

                    Spacer(minLength: 32)
                }
            }
            .background(LumosColor.paper.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("\(viewpoint.ownerName) 的分身主页")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(LumosColor.ink)
                }
            }
        }
    }

    // 每条观点卡片（内嵌追问按钮）
    private func profileViewpointCard(for vp: Viewpoint) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 问题
            Text(vp.question)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(LumosColor.ink4)
                .padding(.horizontal, 16)
                .padding(.top, 14)

            // 回答
            Text(vp.answer)
                .font(.system(size: 14))
                .foregroundColor(LumosColor.ink2)
                .lineSpacing(4)
                .lineLimit(5)
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 12)

            // 底部：tag + 时间 + 追问
            HStack(spacing: 6) {
                ForEach(vp.tags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 8)
                        .frame(height: 20)
                        .background(Capsule().fill(LumosColor.ink.opacity(0.04)))
                        .foregroundColor(LumosColor.ink4)
                }
                Text(vp.timeLabel)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(LumosColor.ink5)
                Spacer()
                let hasProbed = appState.probedViewpointIDs.contains(vp.id)
                Button {
                    if !hasProbed {
                        dismiss()
                        // dismiss 后再打开 ProbeSheet，避免双层 sheet 冲突
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            appState.openProbe(for: vp)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: hasProbed ? "checkmark.circle.fill" : "text.bubble.fill")
                            .font(.system(size: 11, weight: .semibold))
                        Text(hasProbed ? "已追问" : "追问")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(hasProbed ? LumosColor.ink3 : LumosColor.paper)
                    .padding(.horizontal, 13)
                    .frame(height: 30)
                    .background(hasProbed ? LumosColor.ink.opacity(0.05) : LumosColor.ink)
                    .cornerRadius(9)
                }
                .disabled(hasProbed)
            }
            .padding(.horizontal, 16)
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
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.07), radius: 7, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(LumosColor.ink4.opacity(0.2), lineWidth: 1)
                )
        )
    }
}


struct MessageDetailSheet: View {
    let message: MessageItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    if message.kind == .otherPersona {
                        Text("你对 \(message.title) 说")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                        Text(message.timeLabel)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                        Text(message.preview)
                            .font(.system(size: 14))
                            .foregroundColor(LumosColor.ink2)
                            .lineSpacing(4)
                    } else if message.kind == .myPersona {
                        Text("有人在追问你的分身")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.amber)
                        Text(message.timeLabel)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                        Text(message.preview)
                            .font(.system(size: 14))
                            .foregroundColor(LumosColor.ink2)
                            .lineSpacing(4)
                    } else {
                        Text(message.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(LumosColor.ink)
                        Text(message.timeLabel)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                        Text(message.preview)
                            .font(.system(size: 14))
                            .foregroundColor(LumosColor.ink2)
                            .lineSpacing(4)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(LumosColor.ink4.opacity(0.25), lineWidth: 1.5)
                        )
                )
                .padding(.horizontal, 24)
                Text("完整聊天页会在接入真实后端时实现。本 Demo 只展示分身/真人大致会聊什么，让你能从消息列表走完整路径。")
                    .font(.system(size: 13))
                    .foregroundColor(LumosColor.ink4)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                Spacer()
            }
            .background(LumosColor.paper.ignoresSafeArea())
            .navigationTitle("消息详情（Mock）")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(LumosColor.ink3)
                    }
                }
            }
        }
    }
}

