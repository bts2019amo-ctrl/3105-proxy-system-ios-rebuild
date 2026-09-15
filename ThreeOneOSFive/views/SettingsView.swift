import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @AppStorage("externalTheme") private var theme = "purple"
    @AppStorage("customAccentHex") private var customAccentHex = "A34FFA"
    @AppStorage(FeatureVisibility.cleanerStorageKey) private var cleanerEnabled = true
    @AppStorage(FeatureVisibility.developerModeStorageKey) private var developerModeEnabled = false
    @State private var customColor: Color

    private let palette: [(String, String, Color)] = [
        ("purple", "Roxo", Color(hex: "A34FFA")),
        ("blue", "Azul", .blue),
        ("cyan", "Ciano", .cyan),
        ("green", "Verde", .green),
        ("orange", "Laranja", .orange),
        ("red", "Vermelho", .red),
        ("pink", "Rosa", .pink),
        ("white", "Branco", .white)
    ]

    init() {
        let storedHex = UserDefaults.standard.string(forKey: "customAccentHex") ?? "A34FFA"
        _customColor = State(initialValue: Color(hex: storedHex))
    }

    private var themeAccent: Color {
        theme == "custom" ? customColor : AppTheme.accent
    }

    private var themeDisplayName: String {
        if theme == "custom" { return "Personalizada" }
        return palette.first(where: { $0.0 == theme })?.1 ?? "Roxo"
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    appearanceSection
                    behaviorSection
                    deviceSection
                    aboutSection
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 34)
            }
            .background(AppTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .fontWeight(.bold)
                        .foregroundStyle(themeAccent)
                }
            }
            .tint(themeAccent)
            .liquidGlassRoot()
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(themeAccent.opacity(0.2))
                    AppLogo(size: 60)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Personalização")
                        .font(.title2.weight(.bold))
                    Text("Seu espaço, suas cores, seu ritmo")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                Circle().fill(themeAccent).frame(width: 10, height: 10)
                Text("Tema atual: \(themeDisplayName)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(themeAccent)
                Spacer()
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(themeAccent)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay { AppCardBorder() }
    }

    private var appearanceSection: some View {
        settingsSection(title: "APARÊNCIA", icon: "paintpalette.fill") {
            VStack(alignment: .leading, spacing: 16) {
                Text("Escolha uma cor pronta ou crie qualquer cor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 12) {
                    ForEach(palette, id: \.0) { item in
                        paletteButton(id: item.0, name: item.1, color: item.2)
                    }
                }

                HStack(spacing: 12) {
                    Image(systemName: "eyedropper.full")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(themeAccent)
                        .frame(width: 34, height: 34)
                        .background(themeAccent.opacity(0.16), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sua própria cor")
                            .font(.subheadline.weight(.semibold))
                        Text("Toque no círculo para escolher qualquer cor")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    ColorPicker("", selection: $customColor, supportsOpacity: false)
                        .labelsHidden()
                        .onChange(of: customColor) { color in
                            customAccentHex = color.hexString
                            theme = "custom"
                        }
                        .scaleEffect(1.2)
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
                .overlay { RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(themeAccent.opacity(0.26), lineWidth: 0.8) }
            }
        }
    }

    private func paletteButton(id: String, name: String, color: Color) -> some View {
        Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                theme = id
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 7) {
                Circle()
                    .fill(color)
                    .frame(width: 38, height: 38)
                    .overlay {
                        Circle().stroke(Color.white.opacity(0.82), lineWidth: theme == id ? 2.5 : 0.8)
                    }
                    .overlay {
                        if theme == id {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.black))
                                .foregroundStyle(id == "white" ? .black : .white)
                        }
                    }
                    .shadow(color: color.opacity(theme == id ? 0.62 : 0.2), radius: theme == id ? 9 : 3)
                    .scaleEffect(theme == id ? 1.08 : 1)
                Text(name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(theme == id ? themeAccent : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.34, dampingFraction: 0.76), value: theme)
    }

    private var behaviorSection: some View {
        settingsSection(title: "COMPORTAMENTO", icon: "sparkles") {
            VStack(spacing: 0) {
                ToggleRow(icon: "sparkles", title: "Cleaner", subtitle: "Mostrar limpeza de arquivos temporários", isOn: $cleanerEnabled, tint: themeAccent)
                Divider().opacity(0.25)
                ToggleRow(icon: "hammer.fill", title: "Modo desenvolvedor", subtitle: "Mostrar ferramentas avançadas", isOn: $developerModeEnabled, tint: themeAccent)
            }
        }
    }

    private var deviceSection: some View {
        settingsSection(title: "DISPOSITIVO", icon: "iphone") {
            VStack(spacing: 0) {
                infoRow(icon: "iphone", title: "Dispositivo", value: AppInfo.displayMachineName)
                Divider().opacity(0.25)
                infoRow(icon: "apple.logo", title: "Sistema", value: "iOS \(AppInfo.osVersion)")
                Divider().opacity(0.25)
                infoRow(icon: "checkmark.shield.fill", title: "Compatibilidade", value: appState.isSupported ? "Compatível" : "Não compatível", valueColor: appState.isSupported ? .green : .red)
            }
        }
    }

    private var aboutSection: some View {
        settingsSection(title: "SOBRE", icon: "info.circle.fill") {
            VStack(spacing: 0) {
                infoRow(icon: "number", title: "Versão", value: appVersion)
                Divider().opacity(0.25)
                HStack(spacing: 11) {
                    AppRowIcon(systemName: "lock.shield.fill", tint: themeAccent)
                    Text("Espaço local protegido").font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func settingsSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Label(title, systemImage: icon)
                .font(.caption2.weight(.bold))
                .tracking(1.1)
                .foregroundStyle(themeAccent)
                .padding(.horizontal, 5)
            VStack(alignment: .leading, spacing: 0, content: content)
                .padding(14)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay { AppCardBorder() }
        }
    }

    private func infoRow(icon: String, title: String, value: String, valueColor: Color = .secondary) -> some View {
        HStack(spacing: 11) {
            AppRowIcon(systemName: icon, tint: themeAccent)
            Text(title).font(.subheadline.weight(.semibold))
            Spacer()
            Text(value).font(.caption).foregroundStyle(valueColor).lineLimit(1)
        }
        .padding(.vertical, 8)
    }

    private var footer: some View {
        HStack {
            Spacer()
            Text("SECURE · SIMPLE · YOURS")
                .font(.caption2.weight(.bold))
                .tracking(1)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.top, 2)
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "AppReleaseDisplayVersion") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0"
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let tint: Color

    var body: some View {
        HStack(spacing: 11) {
            AppRowIcon(systemName: icon, tint: tint)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(tint)
                .toggleStyle(LiquidGlassToggleStyle())
        }
        .padding(.vertical, 8)
    }
}
