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
            .background(LumosColor.paper.ignoresSafeArea())
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
                    Button {
                        dismiss()
                        appState.startOnboardingRecording()
                    } label: {
                        Text("重新录音")
                    }
                    .buttonStyle(GhostButtonStyle())
                }
                .padding(.bottom, 24)
            }
            .background(LumosColor.paper.ignoresSafeArea())
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
                        appState.hasFinishedOnboarding = true
                        dismiss()
                        appState.closeSheet()
                    } label: {
                        Text("看看分身今天说了什么")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button {
                        appState.hasFinishedOnboarding = true
                        dismiss()
                        appState.currentTab = .discover
                        appState.closeSheet()
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

// MARK: - Avatar 今日回答详情（简化）

struct AvatarAnswerDetailSheet: View {
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
                    Text("35岁拿了大礼包想退休，你最可能去做什么？")
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
                        Text("可能会去做乐队吧。不是那种想靠音乐赚钱的，就是纯粹想跟几个真正喜欢音乐的人，做出一点点让自己觉得有意思的东西。互联网做久了，太多时候都在优化，在迭代，在找更大规模。但好的东西不一定需要规模。")
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
                        Text("亲自接管一下？")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
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
                                    if humanReply.isEmpty && !hasSentHumanReply {
                                        Text("写下你想亲自说的话（Mock，不会真的发送）…")
                                            .font(.system(size: 13))
                                            .foregroundColor(LumosColor.ink5)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .allowsHitTesting(false)
                                    }
                                }
                            )
                        Button {
                            hasSentHumanReply = true
                        } label: {
                            Text(hasSentHumanReply ? "已接管并回复（Mock）" : "发送真人回复（Mock）")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(humanReply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hasSentHumanReply)
                        
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
                    }
                    .padding(.top, 20)
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

// MARK: - 消息详情（Mock 对话预览）

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

