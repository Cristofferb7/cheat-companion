import SwiftUI
import CheatKit

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

enum Theme {
    /// GameShark-screen style block behind code text — fixed dark so codes
    /// read the same in light and dark mode.
    static let codeBackground = Color(hex: 0x1C1833)
    static let codeText = Color(hex: 0xFFD166)

    static func color(for system: System) -> Color {
        switch system {
        case .gb: return Color(hex: 0x6B7280)
        case .gbc: return Color(hex: 0x0EA5A4)
        case .gba: return Color(hex: 0x6C3CE9)
        case .nds: return Color(hex: 0x2563EB)
        }
    }

    static func iconName(for system: System) -> String {
        switch system {
        case .gb, .gbc: return "candybarphone"
        case .gba: return "gamecontroller.fill"
        case .nds: return "laptopcomputer"
        }
    }
}

/// Colored rounded-square console badge used in the game list.
struct SystemBadge: View {
    let system: System

    var body: some View {
        Image(systemName: Theme.iconName(for: system))
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(
                LinearGradient(
                    colors: [Theme.color(for: system).opacity(0.85),
                             Theme.color(for: system)],
                    startPoint: .top, endPoint: .bottom
                ),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
    }
}

/// Monospaced code block styled like a cheat-device screen.
struct CodeBlock: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.system(.body, design: .monospaced).weight(.medium))
            .foregroundStyle(Theme.codeText)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Theme.codeBackground,
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
