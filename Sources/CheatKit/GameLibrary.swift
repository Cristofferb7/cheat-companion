import Foundation

/// Loads and integrity-checks the bundled game files. Every rule in
/// data/SCHEMA.md is enforced here, so a data mistake fails loudly in tests
/// and at app launch instead of shipping a save-corrupting code.
public struct GameLibrary: Sendable {
    public let games: [GameFile]

    public enum LibraryError: Error, CustomStringConvertible {
        case integrity(file: String, problems: [String])

        public var description: String {
            switch self {
            case .integrity(let file, let problems):
                return "\(file): \(problems.joined(separator: "; "))"
            }
        }
    }

    public init(gameFiles: [GameFile], fileNames: [String]? = nil) throws {
        for (index, file) in gameFiles.enumerated() {
            let name = fileNames?[index] ?? file.game.slug
            let problems = Self.integrityProblems(in: file)
            if !problems.isEmpty {
                throw LibraryError.integrity(file: name, problems: problems)
            }
        }
        self.games = gameFiles.sorted { $0.game.title < $1.game.title }
    }

    public init(directory: URL) throws {
        let urls = try FileManager.default
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        let decoder = JSONDecoder()
        var files: [GameFile] = []
        var names: [String] = []
        for url in urls {
            let data = try Data(contentsOf: url)
            files.append(try decoder.decode(GameFile.self, from: data))
            names.append(url.lastPathComponent)
        }
        try self.init(gameFiles: files, fileNames: names)
    }

    /// All schema rules from data/SCHEMA.md. Returns human-readable problems.
    public static func integrityProblems(in file: GameFile) -> [String] {
        var problems: [String] = []
        let ids = file.codes.map(\.id)
        let duplicates = Dictionary(grouping: ids, by: { $0 }).filter { $1.count > 1 }.keys
        for id in duplicates.sorted() {
            problems.append("duplicate code id '\(id)'")
        }

        let masterIDs = Set(file.codes.filter(\.isMasterCode).map(\.id))

        for code in file.codes {
            let label = "code '\(code.id)'"

            if !code.device.systems.contains(file.game.system) {
                problems.append("\(label): device \(code.device.rawValue) doesn't exist for \(file.game.system.rawValue)")
            }
            if !CodeFormat.isValid(code.code, device: code.device) {
                problems.append("\(label): code text isn't in canonical \(CodeFormat.expectedShapeDescription(for: code.device)) form")
            }
            if code.region.isEmpty {
                problems.append("\(label): region is required")
            }
            if code.region != file.game.region {
                problems.append("\(label): region \(code.region) doesn't match game region \(file.game.region)")
            }
            if code.romRevision.isEmpty {
                problems.append("\(label): rom_revision is required ('unspecified' if the source didn't say)")
            }
            if code.requiresMasterCode {
                guard let masterID = code.masterCodeID else {
                    problems.append("\(label): requires_master_code without master_code_id")
                    continue
                }
                if !masterIDs.contains(masterID) {
                    problems.append("\(label): master_code_id '\(masterID)' not found")
                }
            }
            if code.reliability == .unverified {
                problems.append("\(label): unverified codes must not ship")
            }
            if !(code.sourceURL.hasPrefix("https://") || code.sourceURL.hasPrefix("http://")) {
                problems.append("\(label): source_url must be a URL")
            }
            if code.lastVerified.range(of: #"^\d{4}-\d{2}-\d{2}$"#, options: .regularExpression) == nil {
                problems.append("\(label): last_verified must be YYYY-MM-DD")
            }
        }
        return problems
    }
}
