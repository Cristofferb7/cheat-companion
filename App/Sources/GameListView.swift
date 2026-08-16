import SwiftUI
import CheatKit

struct GameListView: View {
    let library: GameLibrary

    @State private var searchText = ""
    @State private var showSettings = false
    @AppStorage("appearance") private var appearanceRaw = Appearance.system.rawValue
    @AppStorage("howItWorksDismissed") private var howItWorksDismissed = false
    @EnvironmentObject private var favorites: Favorites

    private var appearance: Appearance {
        Appearance(rawValue: appearanceRaw) ?? .system
    }

    private var query: String {
        searchText.trimmingCharacters(in: .whitespaces)
    }

    @State private var systemFilter: System?

    private var filteredGames: [GameFile] {
        var games = library.games
        if let systemFilter {
            games = games.filter { $0.game.system == systemFilter }
        }
        guard !query.isEmpty else { return games }
        return games.filter {
            $0.game.title.localizedCaseInsensitiveContains(query)
        }
    }

    private var systemsInLibrary: [System] {
        System.allCases.filter { system in
            library.games.contains { $0.game.system == system }
        }
    }

    /// Codes across every game whose name matches the search.
    private var matchingCodes: [(game: GameFile, code: CheatCode)] {
        guard !query.isEmpty else { return [] }
        return library.games.flatMap { file in
            file.codes
                .filter { !$0.isMasterCode && $0.name.localizedCaseInsensitiveContains(query) }
                .map { (file, $0) }
        }
    }

    private var totalCodes: Int {
        library.games.map(\.codes.count).reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    if query.isEmpty {
                        statsRow
                        systemChips
                        if !howItWorksDismissed { howItWorksCard }

                        let starred = favorites.resolved(in: library)
                        if !starred.isEmpty {
                            Label("Favorites", systemImage: "star.fill")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.primary)
                                .padding(.top, 4)
                            ForEach(starred, id: \.code.id) { match in
                                NavigationLink {
                                    codeDestination(match)
                                } label: {
                                    CodeSearchRow(match: match)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    let official = filteredGames.filter { !$0.game.isROMHack }
                    let hacks = filteredGames.filter { $0.game.isROMHack }

                    ForEach(official, id: \.game.slug) { file in
                        NavigationLink(value: file.game.slug) {
                            GameCard(file: file)
                        }
                        .buttonStyle(.plain)
                    }

                    if !hacks.isEmpty {
                        Label("ROM Hacks", systemImage: "wand.and.stars")
                            .font(.title3.weight(.bold))
                            .padding(.top, 4)
                        ForEach(hacks, id: \.game.slug) { file in
                            NavigationLink(value: file.game.slug) {
                                GameCard(file: file)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !matchingCodes.isEmpty {
                        Text("Codes")
                            .font(.title3.weight(.bold))
                            .padding(.top, 4)
                        ForEach(matchingCodes, id: \.code.id) { match in
                            NavigationLink {
                                codeDestination(match)
                            } label: {
                                CodeSearchRow(match: match)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if filteredGames.isEmpty && matchingCodes.isEmpty {
                        ContentUnavailableView.search(text: query)
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(backgroundWash)
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: "Search games and codes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(library: library)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { slug in
                if let file = library.games.first(where: { $0.game.slug == slug }) {
                    GameDetailView(file: file)
                }
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }

    private func codeDestination(_ match: (game: GameFile, code: CheatCode)) -> some View {
        CodeDetailView(
            file: match.game,
            code: match.code,
            selectedRevision: UserDefaults.standard.string(
                forKey: "revision.\(match.game.game.slug)")
                ?? match.game.game.revisions.first ?? "unspecified",
            deltaLink: UserDefaults.standard.string(
                forKey: "deltaLink.\(match.game.game.slug)") ?? ""
        )
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "bolt.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.amber)
                .frame(width: 46, height: 46)
                .background(
                    LinearGradient(colors: [Color(hex: 0x241E5C), Color(hex: 0x5B2EBE)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
            VStack(alignment: .leading, spacing: 0) {
                Text("Cheat Companion")
                    .font(.title.weight(.bold))
                Text("Verified codes for Delta")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }

    private var systemChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                systemChip(nil, label: "All")
                ForEach(systemsInLibrary, id: \.self) { system in
                    systemChip(system, label: system.displayName)
                }
            }
        }
    }

    private func systemChip(_ system: System?, label: String) -> some View {
        let isSelected = systemFilter == system
        let count = system.map { s in library.games.filter { $0.game.system == s }.count }
            ?? library.games.count
        return Button {
            withAnimation(.snappy) { systemFilter = system }
        } label: {
            Text("\(label) · \(count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : Theme.violet)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(isSelected ? Theme.violet : Theme.violet.opacity(0.1),
                            in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            statChip("\(library.games.count) games", "square.stack.fill")
            statChip("\(totalCodes) codes", "number")
            statChip("All sourced", "checkmark.seal.fill")
        }
    }

    private func statChip(_ text: String, _ icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Theme.violet)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(Theme.violet.opacity(0.1), in: Capsule())
    }

    private var howItWorksCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("How it works", systemImage: "sparkles")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Button {
                    withAnimation { howItWorksDismissed = true }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
            }
            step(1, "Pick a game and a cheat — read the warnings")
            step(2, "Tap Copy — the code is formatted for Delta")
            step(3, "In Delta: pause → Cheat Codes → + → paste")
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func step(_ n: Int, _ text: String) -> some View {
        HStack(spacing: 10) {
            Text("\(n)")
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Theme.violet, in: Circle())
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var backgroundWash: some View {
        LinearGradient(
            colors: [Theme.violet.opacity(0.14), Theme.violet.opacity(0.02)],
            startPoint: .top, endPoint: .center
        )
        .background(Color(uiColor: .systemGroupedBackground))
        .ignoresSafeArea()
    }

}

/// Card-style game row: cover, meta, code count.
struct GameCard: View {
    let file: GameFile

    var body: some View {
        HStack(spacing: 14) {
            CoverArt(game: file.game, height: 86)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(file.game.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if file.game.isROMHack {
                        Text("HACK")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5).padding(.vertical, 2)
                            .background(Theme.gameColor(for: file.game), in: Capsule())
                    }
                }
                Text("\(file.game.system.displayName) · \(file.game.region)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(file.codes.count) codes")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.gameColor(for: file.game))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.background, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}

/// Search result row for a code match.
struct CodeSearchRow: View {
    let match: (game: GameFile, code: CheatCode)

    var body: some View {
        HStack(spacing: 12) {
            CoverArt(game: match.game.game, height: 46)
            VStack(alignment: .leading, spacing: 2) {
                Text(match.code.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text("\(match.game.game.title) · \(match.code.device.displayName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !match.code.sideEffects.isEmpty {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}
