import SwiftUI
import CheatKit

/// Starred codes, persisted locally. Keys are "<game-slug>/<code-id>" so they
/// survive data updates as long as ids stay stable.
@MainActor
final class Favorites: ObservableObject {
    @Published private(set) var keys: Set<String>
    /// Codes the user has marked as already entered in Delta.
    @Published private(set) var addedKeys: Set<String>

    private static let defaultsKey = "favorites"
    private static let addedDefaultsKey = "addedInDelta"

    init() {
        keys = Set(UserDefaults.standard.stringArray(forKey: Self.defaultsKey) ?? [])
        addedKeys = Set(UserDefaults.standard.stringArray(forKey: Self.addedDefaultsKey) ?? [])
    }

    static func key(_ game: GameInfo, _ code: CheatCode) -> String {
        "\(game.slug)/\(code.id)"
    }

    func contains(_ game: GameInfo, _ code: CheatCode) -> Bool {
        keys.contains(Self.key(game, code))
    }

    func toggle(_ game: GameInfo, _ code: CheatCode) {
        let key = Self.key(game, code)
        if keys.contains(key) { keys.remove(key) } else { keys.insert(key) }
        UserDefaults.standard.set(Array(keys).sorted(), forKey: Self.defaultsKey)
    }

    func isAdded(_ game: GameInfo, _ code: CheatCode) -> Bool {
        addedKeys.contains(Self.key(game, code))
    }

    func toggleAdded(_ game: GameInfo, _ code: CheatCode) {
        let key = Self.key(game, code)
        if addedKeys.contains(key) { addedKeys.remove(key) } else { addedKeys.insert(key) }
        UserDefaults.standard.set(Array(addedKeys).sorted(), forKey: Self.addedDefaultsKey)
    }

    /// Resolve stored keys against the library, dropping any that no longer exist.
    func resolved(in library: GameLibrary) -> [(game: GameFile, code: CheatCode)] {
        keys.sorted().compactMap { key in
            let parts = key.split(separator: "/", maxSplits: 1)
            guard parts.count == 2,
                  let file = library.games.first(where: { $0.game.slug == parts[0] }),
                  let code = file.codes.first(where: { $0.id == parts[1] })
            else { return nil }
            return (file, code)
        }
    }
}
