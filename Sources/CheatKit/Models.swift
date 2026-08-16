import Foundation

public enum System: String, Codable, CaseIterable, Sendable {
    case gb, gbc, gba, nds

    public var displayName: String {
        switch self {
        case .gb: return "Game Boy"
        case .gbc: return "Game Boy Color"
        case .gba: return "Game Boy Advance"
        case .nds: return "Nintendo DS"
        }
    }
}

public enum Device: String, Codable, CaseIterable, Sendable {
    case gamesharkGB = "gameshark_gb"
    case gameGenieGB = "game_genie_gb"
    case gamesharkV3 = "gameshark_v3"
    case actionReplay = "action_replay"
    case codebreaker
    case actionReplayDS = "action_replay_ds"

    public var displayName: String {
        switch self {
        case .gamesharkGB: return "GameShark"
        case .gameGenieGB: return "Game Genie"
        case .gamesharkV3: return "GameShark v3"
        case .actionReplay: return "Action Replay"
        case .codebreaker: return "CodeBreaker"
        case .actionReplayDS: return "Action Replay DS"
        }
    }

    /// Systems this cheat device exists for. A record whose device doesn't
    /// match its game's system is a data error.
    public var systems: Set<System> {
        switch self {
        case .gamesharkGB, .gameGenieGB: return [.gb, .gbc]
        case .gamesharkV3, .actionReplay, .codebreaker: return [.gba]
        case .actionReplayDS: return [.nds]
        }
    }
}

public enum Reliability: String, Codable, Sendable {
    case sourceVerified = "source_verified"
    case communityReported = "community_reported"
    case unverified
}

public struct GameInfo: Codable, Hashable, Sendable {
    public let slug: String
    public let title: String
    public let system: System
    public let region: String
    public let revisions: [String]
    public let revisionNote: String?
    /// True for fan-made ROM hacks (Radical Red, Unbound, …).
    public let isROMHack: Bool
    /// For hacks: the official game they're built on, e.g. "Pokémon FireRed (US v1.0)".
    public let basedOn: String?
    /// Game-level warnings shown prominently — e.g. cheats known to break this hack.
    public let warnings: [String]

    enum CodingKeys: String, CodingKey {
        case slug, title, system, region, revisions, warnings
        case revisionNote = "revision_note"
        case isROMHack = "is_rom_hack"
        case basedOn = "based_on"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        slug = try c.decode(String.self, forKey: .slug)
        title = try c.decode(String.self, forKey: .title)
        system = try c.decode(System.self, forKey: .system)
        region = try c.decode(String.self, forKey: .region)
        revisions = try c.decode([String].self, forKey: .revisions)
        revisionNote = try c.decodeIfPresent(String.self, forKey: .revisionNote)
        isROMHack = try c.decodeIfPresent(Bool.self, forKey: .isROMHack) ?? false
        basedOn = try c.decodeIfPresent(String.self, forKey: .basedOn)
        warnings = try c.decodeIfPresent([String].self, forKey: .warnings) ?? []
    }
}

public struct CheatCode: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let device: Device
    public let code: String
    public let region: String
    public let romRevision: String
    public let requiresMasterCode: Bool
    public let masterCodeID: String?
    public let isMasterCode: Bool
    public let activation: String?
    public let reliability: Reliability
    public let sideEffects: [String]
    public let sourceURL: String
    public let lastVerified: String

    enum CodingKeys: String, CodingKey {
        case id, name, description, device, code, region, activation, reliability
        case romRevision = "rom_revision"
        case requiresMasterCode = "requires_master_code"
        case masterCodeID = "master_code_id"
        case isMasterCode = "is_master_code"
        case sideEffects = "side_effects"
        case sourceURL = "source_url"
        case lastVerified = "last_verified"
    }
}

public struct GameFile: Codable, Sendable {
    public let schemaVersion: Int
    public let game: GameInfo
    public let codes: [CheatCode]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case game, codes
    }
}
