import SwiftUI
import CheatKit

struct GameListView: View {
    let library: GameLibrary
    @State private var searchText = ""

    private var filtered: [GameFile] {
        guard !searchText.isEmpty else { return library.games }
        return library.games.filter {
            $0.game.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.game.slug) { file in
                NavigationLink(value: file.game.slug) {
                    HStack(spacing: 12) {
                        CoverArt(game: file.game, height: 64)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(file.game.title)
                                .font(.headline)
                            Text("\(file.game.system.displayName) · \(file.game.region)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(file.codes.count)")
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 9).padding(.vertical, 3)
                            .background(.quaternary, in: Capsule())
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Games")
            // navigationBarDrawer keeps the field on this screen only —
            // the default bottom placement floats over pushed views.
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: "Search games")
            .navigationDestination(for: String.self) { slug in
                if let file = library.games.first(where: { $0.game.slug == slug }) {
                    GameDetailView(file: file)
                }
            }
        }
    }
}
