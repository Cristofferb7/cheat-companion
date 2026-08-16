import SwiftUI
import CheatKit

@main
struct CheatCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    enum LoadState {
        case loaded(GameLibrary)
        case failed(String)
    }

    private let state: LoadState

    init() {
        // Fail loudly: shipping with a broken library is worse than not launching.
        do {
            guard let url = Bundle.main.url(forResource: "games", withExtension: nil) else {
                state = .failed("Bundled game data is missing.")
                return
            }
            state = .loaded(try GameLibrary(directory: url))
        } catch {
            state = .failed("\(error)")
        }
    }

    @StateObject private var favorites = Favorites()

    var body: some View {
        switch state {
        case .loaded(let library):
            GameListView(library: library)
                .environmentObject(favorites)
        case .failed(let message):
            ContentUnavailableView(
                "Data failed integrity checks",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }
}
