import XCTest
@testable import CheatKit

/// Validates the real seed data in data/games/ against every schema rule.
/// These tests are the gate: a code that fails them never reaches the app.
final class SeedDataTests: XCTestCase {

    static var dataDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // CheatKitTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // repo root
            .appendingPathComponent("data/games")
    }

    func testSeedDataPassesAllIntegrityChecks() throws {
        let library = try GameLibrary(directory: Self.dataDirectory)
        XCTAssertGreaterThanOrEqual(
            library.games.count, 3,
            "v1 scope is a 3-4 game library"
        )
    }

    func testEveryCodeHasAResolvableSourceURL() throws {
        let library = try GameLibrary(directory: Self.dataDirectory)
        for game in library.games {
            for code in game.codes {
                XCTAssertNotNil(
                    URL(string: code.sourceURL),
                    "\(game.game.slug)/\(code.id): source_url isn't a parseable URL"
                )
            }
        }
    }

    func testMasterCodesExistWhereDeviceNeedsThem() throws {
        let library = try GameLibrary(directory: Self.dataDirectory)
        // ROM hacks are exempt: they often work without master codes.
        for game in library.games where game.game.system == .gba && !game.game.isROMHack {
            let hasGameShark = game.codes.contains {
                ($0.device == .gamesharkV3 || $0.device == .actionReplay) && !$0.isMasterCode
            }
            if hasGameShark {
                XCTAssertTrue(
                    game.codes.contains(\.isMasterCode),
                    "\(game.game.slug): has GameShark/AR codes but no master code record"
                )
            }
        }
    }
}
