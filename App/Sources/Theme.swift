import SwiftUI
import UIKit
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

/// User-selectable appearance, persisted in AppStorage.
enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var iconName: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum Theme {
    static let violet = Color(hex: 0x6C3CE9)
    static let amber = Color(hex: 0xFFB020)

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

    /// Signature color per game, matched to its cover art. Screens for a game
    /// tint to this so each game has its own feel. Falls back to the system color.
    static func gameColor(for game: GameInfo) -> Color {
        switch game.slug {
        case "pokemon-firered-us": return Color(hex: 0xDC4B22)
        case "pokemon-emerald-us": return Color(hex: 0x0E9F6E)
        case "pokemon-crystal-us": return Color(hex: 0x2678D6)
        case "pokemon-platinum-us": return Color(hex: 0x5B6472)
        case "pokemon-yellow-us": return Color(hex: 0xD97706)
        case "pokemon-ruby-us": return Color(hex: 0xB91C1C)
        case "pokemon-heartgold-us": return Color(hex: 0xB7791F)
        case "pokemon-leafgreen-us": return Color(hex: 0x16A34A)
        case "pokemon-red-blue-us": return Color(hex: 0x2447C9)
        case "pokemon-soulsilver-us": return Color(hex: 0x64748B)
        case "pokemon-radical-red": return Color(hex: 0xE11D48)
        case "pokemon-unbound": return Color(hex: 0x6366F1)
        default: return color(for: game.system)
        }
    }

    /// Cover image for a game if one is bundled (asset "cover-<slug>").
    static func coverImage(for game: GameInfo) -> Image? {
        guard UIImage(named: "cover-\(game.slug)") != nil else { return nil }
        return Image("cover-\(game.slug)")
    }
}

/// Rough grouping for the game-detail list, derived from the code name so the
/// data schema stays unchanged. Misclassification is cosmetic only.
enum CodeCategory: String, CaseIterable, Identifiable {
    case items = "Items & Money"
    case encounters = "Encounters"
    case training = "Training & Battle"
    case movement = "Movement"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .items: return "bag.fill"
        case .encounters: return "sparkles"
        case .training: return "chart.line.uptrend.xyaxis"
        case .movement: return "figure.walk"
        case .other: return "square.grid.2x2"
        }
    }

    static func classify(_ code: CheatCode) -> CodeCategory {
        let n = code.name.lowercased()
        if ["money", "cash", "candy", "candies", "ball", "item", "medicine", "coin"]
            .contains(where: n.contains) { return .items }
        if ["walk", "teleport", "warp", "ghost"]
            .contains(where: n.contains) { return .movement }
        if ["shiny", "encounter", "battles", "wild", "catch", "rebattle", "mew"]
            .contains(where: n.contains) { return .encounters }
        if ["exp", "level", "pp", "health", "hp"]
            .contains(where: n.contains) { return .training }
        return .other
    }
}

/// Cover-art card: bundled cover if present, else a colored monogram card.
struct CoverArt: View {
    let game: GameInfo
    var height: CGFloat

    var body: some View {
        Group {
            if let image = Theme.coverImage(for: game) {
                image.resizable().aspectRatio(contentMode: .fit)
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Theme.gameColor(for: game).gradient)
                    .aspectRatio(600 / 840, contentMode: .fit)
                    .overlay {
                        Image(systemName: Theme.iconName(for: game.system))
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                    }
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: height > 100 ? 12 : 6, style: .continuous))
        .shadow(color: Theme.gameColor(for: game).opacity(0.35),
                radius: height > 100 ? 12 : 3, y: height > 100 ? 6 : 2)
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
