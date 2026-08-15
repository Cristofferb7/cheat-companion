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
                    VStack(alignment: .leading, spacing: 2) {
                        Text(file.game.title)
                            .font(.headline)
                        Text("\(file.game.system.displayName) · \(file.game.region) · \(file.codes.count) codes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
