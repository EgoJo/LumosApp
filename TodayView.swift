import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                header
                if !appState.hasFinishedOnboarding {
                    onboardingProgress
                    onboardingQuestionCard
                    onboardingWhyBlurb
                } else {
                    normalStateCard
                    pastSection
                }
                Spacer(minLength: 16)
            }
        }
        .background(LumosColor.paper)
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(LumosColor.ink4)
                    .tracking(0.08)
                Text("阿基米德")
                    .font(.system(size: 26, weight: .light, design: .serif))
                    .italic()
                    .foregroundColor(LumosColor.ink)
            }
            Spacer()
            Button {
                appState.openSettings()
            } label: {
                Circle()
                    .stroke(LumosColor.ink4.opacity(0.6), lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(LumosColor.ink3)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
    
    // MARK: - Onboarding
    
    private var onboardingProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 5) {
                ForEach(0..<OnboardingStep.total, id: \.self) { index in
                    let step = OnboardingStep(rawValue: index)!
                    RoundedRectangle(cornerRadius: 2)
                        .fill(step.index <= appState.onboardingStep.index ? LumosColor.ink : LumosColor.ink4.opacity(0.3))
                        .frame(height: 3)
                }
            }
            HStack {
                Text("帮分身打基础 · 第 \(appState.onboardingStep.displayIndex) 题 / 共 3 题")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(LumosColor.ink3)
                Spacer()
                Text("语音回答，越真越好")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(LumosColor.amber)
            }
        }
        .padding(.top, 18)
        .padding(.horizontal, 24)
    }
    
    private var onboardingQuestionCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Circle()
                    .fill(LumosColor.amber.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .shadow(color: LumosColor.amber.opacity(0.5), radius: 4)
                Text("建立分身 · 第 \(appState.onboardingStep.displayIndex) 题")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.7))
                    .tracking(0.14)
            }
            Text(currentOnboardingQuestion.text)
                .font(.system(size: 24, weight: .light, design: .serif))
                .foregroundColor(LumosColor.paper)
                .italic()
                .lineSpacing(4)
            HStack {
                Text("\(currentOnboardingQuestion.answeredCount) 人已回答")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.7))
                Spacer()
                Button {
                    appState.startOnboardingRecording()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("用语音回答")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(LumosColor.ink)
                    .padding(.horizontal, 16)
                    .frame(height: 40)
                    .background(LumosColor.paper)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 8)
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1),
                alignment: .top
            )
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LumosColor.ink)
                .shadow(color: Color.black.opacity(0.35), radius: 20, x: 0, y: 16)
        )
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .onTapGesture {
            appState.startOnboardingRecording()
        }
    }
    
    private var onboardingWhyBlurb: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💡")
                .font(.system(size: 16))
            Text("回答完 3 题后，你的分身就会上线，每天自动回答新问题——同频的人就能找到你了。")
                .font(.system(size: 13))
                .foregroundColor(LumosColor.amber)
                .lineSpacing(4)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(LumosColor.amberBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(LumosColor.amber.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    private var currentOnboardingQuestion: Question {
        switch appState.onboardingStep {
        case .q1: return appState.todayQuestion
        case .q2: return appState.pastQuestions[2] // “工作之外，你最近在认真对待什么？”
        case .q3: return appState.pastQuestions[1] // “最近改变了什么之前一直坚持的判断？”
        }
    }
    
    // MARK: - Normal State（Onboarding 完成后）
    
    private var normalStateCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // header
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(LumosColor.paper2)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("阿")
                                .font(.system(size: 17, weight: .light, design: .serif))
                                .italic()
                                .foregroundColor(LumosColor.ink2)
                        )
                    Circle()
                        .fill(LumosColor.ink)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Image(systemName: "waveform")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundColor(LumosColor.paper)
                        )
                        .offset(x: 2, y: 2)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("我的分身今天说了——")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(LumosColor.ink)
                    Text(appState.todayQuestion.text)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.ink4)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(LumosColor.ink4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Rectangle()
                    .fill(LumosColor.paper)
                    .overlay(
                        Rectangle()
                            .fill(LumosColor.ink.opacity(0.06))
                            .frame(height: 1),
                        alignment: .bottom
                    )
            )
            
            // body（分身回答摘要，来自 myViewpoints 第一条）
            Text(appState.myViewpoints.first(where: { $0.isMine })?.answer
                 ?? "分身今日回答加载中…")
                .font(.system(size: 14))
                .foregroundColor(LumosColor.ink2)
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .lineLimit(4)
            
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(appState.hasTakenOverToday ? LumosColor.green : LumosColor.amber)
                        .frame(width: 6, height: 6)
                    Text(appState.hasTakenOverToday
                         ? "真人已接管，今日已回复"
                         : "收到 3 个追问，分身正在回复")
                        .font(.system(size: 12))
                        .foregroundColor(LumosColor.ink3)
                }
                Spacer()
                Button {
                    appState.openAvatarAnswerDetail()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: appState.hasTakenOverToday
                              ? "pencil.circle"
                              : "person.crop.circle.badge.checkmark")
                            .font(.system(size: 11, weight: .semibold))
                        Text(appState.hasTakenOverToday ? "修改回复" : "我来接管")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(appState.hasTakenOverToday ? LumosColor.ink3 : LumosColor.paper)
                    .padding(.horizontal, 14)
                    .frame(height: 32)
                    .background(appState.hasTakenOverToday
                                ? LumosColor.ink.opacity(0.06)
                                : LumosColor.ink)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(appState.hasTakenOverToday
                                    ? LumosColor.ink4.opacity(0.4)
                                    : Color.clear, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Rectangle()
                    .fill(LumosColor.paper)
                    .overlay(
                        Rectangle()
                            .fill(LumosColor.ink.opacity(0.03))
                            .frame(height: 1),
                        alignment: .top
                    )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(LumosColor.ink4.opacity(0.3), lineWidth: 1.5)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.white)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    // MARK: - Past questions
    
    private var pastSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("分身往期回答")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(LumosColor.ink4)
                    .tracking(0.12)
                Spacer()
                Text("全部")
                    .font(.system(size: 12))
                    .foregroundColor(LumosColor.amber)
            }
            .padding(.horizontal, 24)
            .padding(.top, appState.hasFinishedOnboarding ? 20 : 24)
            
            ForEach(appState.pastQuestions) { q in
                HStack(spacing: 14) {
                    if let label = q.dateLabel {
                        Text(label.replacingOccurrences(of: "", with: "\n"))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(LumosColor.ink4)
                            .frame(width: 26)
                            .multilineTextAlignment(.center)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(q.text)
                            .font(.system(size: 13.5))
                            .foregroundColor(LumosColor.ink2)
                            .lineLimit(1)
                        Text("分身已回答 · Mock 追问")
                            .font(.system(size: 11))
                            .foregroundColor(LumosColor.green)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(LumosColor.ink5)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    appState.openPastAnswer(for: q)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Rectangle()
                        .fill(Color.clear)
                        .overlay(
                            Rectangle()
                                .fill(LumosColor.ink.opacity(0.04))
                                .frame(height: 1),
                            alignment: .bottom
                        )
                )
            }
        }
    }
}

