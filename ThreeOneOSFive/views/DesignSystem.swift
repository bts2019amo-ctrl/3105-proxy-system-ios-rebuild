import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        let value = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var number: UInt64 = 0
        Scanner(string: value).scanHexInt64(&number)
        let red = Double((number >> 16) & 0xff) / 255
        let green = Double((number >> 8) & 0xff) / 255
        let blue = Double(number & 0xff) / 255
        self.init(red: red, green: green, blue: blue)
    }

    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(
            format: "%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
}

enum AppTheme {
    private static var remoteAccent: Color?
    static var accent: Color {
        get {
            if let remoteAccent { return remoteAccent }
            switch UserDefaults.standard.string(forKey: "externalTheme") ?? "purple" {
            case "blue": return Color(uiColor: .systemBlue)
            case "cyan": return Color(uiColor: .systemTeal)
            case "green": return Color(uiColor: .systemGreen)
            case "orange": return Color(uiColor: .systemOrange)
            case "red": return Color(uiColor: .systemRed)
            case "pink": return Color(uiColor: .systemPink)
            case "custom": return Color(hex: UserDefaults.standard.string(forKey: "customAccentHex") ?? "A34FFA")
            case "white": return .white
            default: return Color(uiColor: UIColor(red: 0.64, green: 0.31, blue: 0.98, alpha: 1.00))
            }
        }
        set { remoteAccent = newValue }
    }
    static var secondaryAccent = Color.white
    static var pageBackground = Color(uiColor: UIColor(red: 0.055, green: 0.04, blue: 0.09, alpha: 1.00))
    static let consoleBackground = Color(uiColor: UIColor(red: 0.09, green: 0.07, blue: 0.14, alpha: 1.00))
    static let glassBase = Color(uiColor: UIColor(red: 0.11, green: 0.08, blue: 0.16, alpha: 1.00))
    static let glassHighlight = Color.white.opacity(0.42)
    static let glassShadow = Color.black.opacity(0.12)
    static let pageInset: CGFloat = 20
    static let rowIconSize: CGFloat = 17
    static let rowIconFrame: CGFloat = 28
    static let fileRowIconSize: CGFloat = 17
    static let fileRowIconFrame: CGFloat = 30
    static let fileRowHeight: CGFloat = 60
    static let appIconSize: CGFloat = 32
    static let emptyIconSize: CGFloat = 30
    static let selectionIconSize: CGFloat = 18
    static let contentCardCornerRadius: CGFloat = 24
    static let contentCardInset: CGFloat = 16
    static let contentCardPadding: CGFloat = 16

    static var pageGradient: LinearGradient {
        LinearGradient(
            colors: [
                pageBackground,
                accent.opacity(0.055),
                Color(uiColor: .systemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct LiquidGlassRootModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var backdropPhase = false

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.1, *) {
            content
                .fontDesign(.rounded)
                .tint(AppTheme.accent)
                .background {
                    AnimatedGlassBackdrop(phase: backdropPhase)
                        .ignoresSafeArea()
                }
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) {
                        backdropPhase = true
                    }
                }
        } else {
            content
                .tint(AppTheme.accent)
                .background(AppTheme.pageGradient.ignoresSafeArea())
        }
    }
}

extension View {
    func liquidGlassRoot() -> some View {
        modifier(LiquidGlassRootModifier())
    }
}

struct LiquidGlassToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                configuration.isOn.toggle()
            }
        } label: {
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule(style: .continuous)
                    .fill(configuration.isOn ? AppTheme.accent : Color(uiColor: .systemGray4))
                    .frame(width: 52, height: 31)
                    .shadow(
                        color: .black.opacity(0.14),
                        radius: 4,
                        y: 2
                    )
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    .frame(width: 27, height: 27)
                    .padding(2)
                    .scaleEffect(configuration.isOn ? 1.0 : 0.94)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }
}

struct LiquidGlassButtonStyle: ButtonStyle {
    var tint: Color = AppTheme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.primary)
            .background {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.68), tint.opacity(0.34), Color.white.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .brightness(configuration.isPressed ? 0.06 : 0)
            .animation(.spring(response: 0.26, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

private struct AnimatedGlassBackdrop: View {
    let phase: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppTheme.pageGradient
                Circle()
                    .fill(AppTheme.accent.opacity(0.12))
                    .frame(width: 260, height: 260)
                    .blur(radius: 22)
                    .offset(
                        x: phase ? proxy.size.width * 0.28 : -proxy.size.width * 0.22,
                        y: phase ? -proxy.size.height * 0.18 : proxy.size.height * 0.16
                    )
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 210, height: 210)
                    .blur(radius: 24)
                    .offset(
                        x: phase ? -proxy.size.width * 0.24 : proxy.size.width * 0.2,
                        y: phase ? proxy.size.height * 0.3 : -proxy.size.height * 0.22
                    )
            }
        }
    }
}

struct AppCardBorder: View {
    var body: some View {
        RoundedRectangle(
            cornerRadius: AppTheme.contentCardCornerRadius,
            style: .continuous
        )
        .strokeBorder(
            LinearGradient(
                colors: [Color.white.opacity(0.72), AppTheme.accent.opacity(0.24), Color.white.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 0.8
        )
        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 8)
        .accessibilityHidden(true)
    }
}

struct AppGlassRowBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                LinearGradient(
                    colors: [AppTheme.glassHighlight, .clear, AppTheme.accent.opacity(0.06)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.68), AppTheme.accent.opacity(0.18), Color.white.opacity(0.16)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            }
            .shadow(color: AppTheme.glassShadow, radius: 14, y: 7)
            .padding(.vertical, 4)
    }
}

struct AppRowIcon: View {
    let systemName: String
    var tint: Color = AppTheme.accent
    var symbolSize: CGFloat = AppTheme.rowIconSize
    var frameSize: CGFloat = AppTheme.rowIconFrame
    @State private var appeared = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 7, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.65), tint.opacity(0.32)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.7
                                )
                        }
                }
            Image(systemName: systemName)
                .font(.system(size: symbolSize, weight: .medium))
                .foregroundStyle(tint)
                .scaleEffect(appeared ? 1 : 0.72)
                .opacity(appeared ? 1 : 0)
        }
        .frame(width: frameSize, height: frameSize)
        .shadow(color: tint.opacity(appeared ? 0.2 : 0), radius: 8, y: 3)
        .rotationEffect(.degrees(appeared ? 0 : -7))
        .animation(.spring(response: 0.46, dampingFraction: 0.72), value: appeared)
        .onAppear { appeared = true }
        .accessibilityHidden(true)
    }
}

struct AppSearchField: View {
    @Binding var text: String
    let prompt: String
    let clearLabel: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField(prompt, text: $text)
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(clearLabel)
            }
        }
        .padding(.horizontal, 11)
        .frame(minHeight: 36)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.34), lineWidth: 0.7)
        )
        .padding(.horizontal, AppTheme.pageInset)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}

struct AppLogo: View {
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let icon = UIImage(named: "AppIcon60x60")
                ?? Bundle.main.path(forResource: "AppIcon60x60@2x", ofType: "png").flatMap(UIImage.init(contentsOfFile:))
                ?? UIImage(named: "AppIcon") {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.accent)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
        .accessibilityHidden(true)
    }
}
