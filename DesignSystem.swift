import SwiftUI

// 颜色与排版 token，尽量贴近你 HTML 里的设计
enum LumosColor {
    static let paper      = Color(red: 0.96, green: 0.95, blue: 0.93)  // #f5f2ec
    static let paper2     = Color(red: 0.93, green: 0.91, blue: 0.88)
    static let paper3     = Color(red: 0.89, green: 0.87, blue: 0.84)
    static let ink        = Color(red: 0.11, green: 0.10, blue: 0.09)  // #1c1a17
    static let ink2       = Color(red: 0.24, green: 0.23, blue: 0.20)
    static let ink3       = Color(red: 0.48, green: 0.46, blue: 0.44)
    static let ink4       = Color(red: 0.69, green: 0.66, blue: 0.63)
    static let ink5       = Color(red: 0.82, green: 0.80, blue: 0.77)
    static let amber      = Color(red: 0.71, green: 0.38, blue: 0.04)  // #b5600a
    static let amberBg    = Color(red: 0.99, green: 0.95, blue: 0.91)  // #fdf3e7
    static let green      = Color(red: 0.18, green: 0.48, blue: 0.31)
    static let greenBg    = Color(red: 0.93, green: 0.97, blue: 0.95)
    static let red        = Color(red: 0.69, green: 0.23, blue: 0.18)
}

extension View {
    func lumosCardPadding() -> some View {
        padding(.horizontal, 20)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(LumosColor.paper)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(LumosColor.ink)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .foregroundColor(LumosColor.ink3)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(LumosColor.ink4.opacity(0.4), lineWidth: 1.5)
            )
            .background(Color.clear)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct ChipView: View {
    let text: String
    let isFilled: Bool
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 9)
            .frame(height: 22)
            .background(
                Capsule()
                    .fill(isFilled ? LumosColor.ink : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(LumosColor.ink4.opacity(0.6), lineWidth: 1)
            )
            .foregroundColor(isFilled ? LumosColor.paper : LumosColor.ink3)
    }
}

// 顶层「设备壳」
struct DeviceShell<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Lumos")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .italic()
                        .foregroundColor(LumosColor.paper)
                    Text("UI / UX Prototype · iOS App · Native Mock")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(LumosColor.ink5.opacity(0.6))
                        .tracking(0.18)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 52, style: .continuous)
                        .fill(LumosColor.paper)
                        .frame(width: 390, height: 844)
                        .shadow(color: .black.opacity(0.7), radius: 40, x: 0, y: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 52, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1.5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 52, style: .continuous)
                                .strokeBorder(Color.black.opacity(0.6), lineWidth: 3)
                        )
                    
                    content
                        .frame(width: 390, height: 844)
                        .clipShape(RoundedRectangle(cornerRadius: 52, style: .continuous))
                }
                Text("本轮为纯本地 Mock · 不接后端 / 不请求权限")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(LumosColor.ink5.opacity(0.7))
            }
            .padding(.vertical, 32)
        }
    }
}

