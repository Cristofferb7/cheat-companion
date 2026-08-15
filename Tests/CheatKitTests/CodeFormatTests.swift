import XCTest
@testable import CheatKit

final class CodeFormatTests: XCTestCase {

    // MARK: Normalization

    func testGameSharkGBEightHex() throws {
        XCTAssertEqual(try CodeFormat.normalize("910238d5", device: .gamesharkGB), "910238D5")
        XCTAssertEqual(try CodeFormat.normalize(" 9102 38D5 ", device: .gamesharkGB), "910238D5")
    }

    func testGameGenieGBGrouping() throws {
        XCTAssertEqual(try CodeFormat.normalize("faa-e9a-c49", device: .gameGenieGB), "FAA-E9A-C49")
        XCTAssertEqual(try CodeFormat.normalize("FAA E9A C49", device: .gameGenieGB), "FAA-E9A-C49")
        XCTAssertEqual(try CodeFormat.normalize("faae9a", device: .gameGenieGB), "FAA-E9A")
    }

    func testGBAGameSharkPair() throws {
        XCTAssertEqual(
            try CodeFormat.normalize("509197D3542975F4", device: .gamesharkV3),
            "509197D3 542975F4"
        )
        XCTAssertEqual(
            try CodeFormat.normalize("509197d3 542975f4", device: .actionReplay),
            "509197D3 542975F4"
        )
    }

    func testCodeBreakerShape() throws {
        XCTAssertEqual(
            try CodeFormat.normalize("82025840 0044", device: .codebreaker),
            "82025840 0044"
        )
    }

    func testActionReplayDSMultiline() throws {
        let raw = "94000130 fcff0000\nb2101d40 00000000\nd2000000 00000000"
        XCTAssertEqual(
            try CodeFormat.normalize(raw, device: .actionReplayDS),
            "94000130 FCFF0000\nB2101D40 00000000\nD2000000 00000000"
        )
    }

    func testBlankLinesIgnored() throws {
        XCTAssertEqual(
            try CodeFormat.normalize("910238D5\n\n  \n", device: .gamesharkGB),
            "910238D5"
        )
    }

    // MARK: Rejection

    func testRejectsEmpty() {
        XCTAssertThrowsError(try CodeFormat.normalize("  \n ", device: .gamesharkGB)) {
            XCTAssertEqual($0 as? CodeFormat.ValidationError, .empty)
        }
    }

    func testRejectsNonHex() {
        XCTAssertThrowsError(try CodeFormat.normalize("910238G5", device: .gamesharkGB)) {
            XCTAssertEqual($0 as? CodeFormat.ValidationError, .invalidCharacters(line: 1))
        }
    }

    func testRejectsWrongLength() {
        XCTAssertThrowsError(try CodeFormat.normalize("910238D", device: .gamesharkGB)) {
            XCTAssertEqual(
                $0 as? CodeFormat.ValidationError,
                .wrongShape(line: 1, expected: "XXXXXXXX")
            )
        }
        // A GBA pair fed to CodeBreaker (needs 8+4) must fail.
        XCTAssertThrowsError(try CodeFormat.normalize("509197D3 542975F4", device: .codebreaker))
    }

    func testRejectsBadLineInMultiline() {
        let raw = "94000130 FCFF0000\nB2101D40 0000"
        XCTAssertThrowsError(try CodeFormat.normalize(raw, device: .actionReplayDS)) {
            XCTAssertEqual(
                $0 as? CodeFormat.ValidationError,
                .wrongShape(line: 2, expected: "XXXXXXXX YYYYYYYY")
            )
        }
    }

    func testIsValidRoundTrip() {
        XCTAssertTrue(CodeFormat.isValid("82025840 0044", device: .codebreaker))
        XCTAssertFalse(CodeFormat.isValid("82025840 0044 ", device: .codebreaker))
        XCTAssertFalse(CodeFormat.isValid("820258400044", device: .codebreaker))
    }
}
