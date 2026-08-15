import Foundation

/// Per-device code line formats, matching what Delta/DeltaCore accepts.
/// Source: https://github.com/rileytestut/DeltaCore/wiki/Cheats
public enum CodeFormat {

    public enum ValidationError: Error, Equatable, CustomStringConvertible {
        case empty
        case invalidCharacters(line: Int)
        case wrongShape(line: Int, expected: String)

        public var description: String {
            switch self {
            case .empty:
                return "Code is empty."
            case .invalidCharacters(let line):
                return "Line \(line) contains non-hex characters."
            case .wrongShape(let line, let expected):
                return "Line \(line) doesn't match the required format \(expected)."
            }
        }
    }

    /// Expected shape per line as (groups of hex digit counts, joined by single spaces).
    static func lineGroups(for device: Device) -> [[Int]] {
        switch device {
        case .gamesharkGB: return [[8]]
        case .gameGenieGB: return [[3, 3, 3], [3, 3]] // XXX-YYY-ZZZ, rare XXX-YYY
        case .gamesharkV3, .actionReplay, .actionReplayDS: return [[8, 8]]
        case .codebreaker: return [[8, 4]]
        }
    }

    public static func expectedShapeDescription(for device: Device) -> String {
        switch device {
        case .gamesharkGB: return "XXXXXXXX"
        case .gameGenieGB: return "XXX-YYY-ZZZ"
        case .gamesharkV3, .actionReplay, .actionReplayDS: return "XXXXXXXX YYYYYYYY"
        case .codebreaker: return "XXXXXXXX YYYY"
        }
    }

    /// Normalizes raw input (pasted or stored) into the canonical format for a
    /// device: uppercase hex, correct grouping, one code segment per line.
    /// Throws if any character isn't hex or the digits don't fit the shape.
    public static func normalize(_ raw: String, device: Device) throws -> String {
        let lines = raw
            .uppercased()
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else { throw ValidationError.empty }

        let shapes = lineGroups(for: device)
        var result: [String] = []

        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            // Collapse all separators (spaces, dashes) and validate hex.
            let digits = line.replacingOccurrences(of: "-", with: "")
                .components(separatedBy: .whitespaces).joined()
            guard digits.allSatisfy({ $0.isHexDigit && ($0.isNumber || $0.isUppercase) }) else {
                throw ValidationError.invalidCharacters(line: lineNumber)
            }

            guard let shape = shapes.first(where: { $0.reduce(0, +) == digits.count }) else {
                throw ValidationError.wrongShape(
                    line: lineNumber,
                    expected: expectedShapeDescription(for: device)
                )
            }

            var groups: [Substring] = []
            var cursor = digits.startIndex
            for size in shape {
                let end = digits.index(cursor, offsetBy: size)
                groups.append(digits[cursor..<end])
                cursor = end
            }
            let separator = device == .gameGenieGB ? "-" : " "
            result.append(groups.joined(separator: separator))
        }

        return result.joined(separator: "\n")
    }

    /// True when the string is already in canonical form for the device.
    public static func isValid(_ code: String, device: Device) -> Bool {
        (try? normalize(code, device: device)) == code
    }
}
