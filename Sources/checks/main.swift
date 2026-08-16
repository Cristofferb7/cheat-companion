import Foundation
import CheatKit

// Mirror of Tests/CheatKitTests, runnable without Xcode: `swift run checks`.
// Exits non-zero on the first failure. CI/pre-commit gate until XCTest exists.

var failures = 0

func check(_ label: String, _ condition: @autoclosure () throws -> Bool) {
    do {
        if try condition() {
            print("ok   \(label)")
        } else {
            print("FAIL \(label)")
            failures += 1
        }
    } catch {
        print("FAIL \(label) — threw \(error)")
        failures += 1
    }
}

func checkThrows(_ label: String, _ body: @autoclosure () throws -> some Any) {
    do {
        _ = try body()
        print("FAIL \(label) — expected an error, got none")
        failures += 1
    } catch {
        print("ok   \(label)")
    }
}

// MARK: - CodeFormat

check("GameShark GB normalizes to 8 hex",
      try CodeFormat.normalize("910238d5", device: .gamesharkGB) == "910238D5")
check("GameShark GB collapses inner spaces",
      try CodeFormat.normalize(" 9102 38D5 ", device: .gamesharkGB) == "910238D5")
check("Game Genie GB regroups with dashes",
      try CodeFormat.normalize("faa e9a c49", device: .gameGenieGB) == "FAA-E9A-C49")
check("Game Genie GB accepts 6-digit form",
      try CodeFormat.normalize("faae9a", device: .gameGenieGB) == "FAA-E9A")
check("GBA GameShark regroups 16 digits into 8+8",
      try CodeFormat.normalize("509197D3542975F4", device: .gamesharkV3) == "509197D3 542975F4")
check("CodeBreaker keeps 8+4",
      try CodeFormat.normalize("82025840 0044", device: .codebreaker) == "82025840 0044")
check("AR DS multi-line normalizes per line",
      try CodeFormat.normalize("94000130 fcff0000\nb2101d40 00000000", device: .actionReplayDS)
        == "94000130 FCFF0000\nB2101D40 00000000")
check("Blank lines ignored",
      try CodeFormat.normalize("910238D5\n\n  \n", device: .gamesharkGB) == "910238D5")

checkThrows("Empty input rejected",
            try CodeFormat.normalize("  \n ", device: .gamesharkGB))
checkThrows("Non-hex rejected",
            try CodeFormat.normalize("910238G5", device: .gamesharkGB))
checkThrows("Wrong length rejected",
            try CodeFormat.normalize("910238D", device: .gamesharkGB))
checkThrows("GBA pair fed to CodeBreaker rejected",
            try CodeFormat.normalize("509197D3 542975F4", device: .codebreaker))
checkThrows("Bad line inside multi-line rejected",
            try CodeFormat.normalize("94000130 FCFF0000\nB2101D40 0000", device: .actionReplayDS))

check("isValid accepts canonical", CodeFormat.isValid("82025840 0044", device: .codebreaker))
check("isValid rejects trailing space", !CodeFormat.isValid("82025840 0044 ", device: .codebreaker))
check("isValid rejects ungrouped", !CodeFormat.isValid("820258400044", device: .codebreaker))

// MARK: - Seed data integrity

let dataDirectory = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent() // checks
    .deletingLastPathComponent() // Sources
    .deletingLastPathComponent() // repo root
    .appendingPathComponent("data/games")

do {
    let library = try GameLibrary(directory: dataDirectory)
    if library.games.isEmpty {
        print("warn seed data: no game files yet (data/games is empty)")
    } else {
        check("seed data: 3+ games for v1 scope", library.games.count >= 3)
        for game in library.games {
            check("seed data: \(game.game.slug) has codes", !game.codes.isEmpty)
            for code in game.codes {
                check("seed data: \(game.game.slug)/\(code.id) source_url parses",
                      URL(string: code.sourceURL) != nil)
            }
            // ROM hacks are exempt: they often work without master codes.
            if game.game.system == .gba, !game.game.isROMHack {
                let hasGameShark = game.codes.contains {
                    ($0.device == .gamesharkV3 || $0.device == .actionReplay) && !$0.isMasterCode
                }
                if hasGameShark {
                    check("seed data: \(game.game.slug) ships a master code",
                          game.codes.contains(where: \.isMasterCode))
                }
            }
        }
    }
} catch {
    print("FAIL seed data integrity — \(error)")
    failures += 1
}

print(failures == 0 ? "\nAll checks passed." : "\n\(failures) check(s) FAILED.")
exit(failures == 0 ? 0 : 1)
