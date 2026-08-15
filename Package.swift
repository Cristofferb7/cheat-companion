// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CheatKit",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "CheatKit", targets: ["CheatKit"])
    ],
    targets: [
        .target(name: "CheatKit", path: "Sources/CheatKit"),
        // Plain-Swift check runner: works with Command Line Tools alone
        // (XCTest requires full Xcode). Run with `swift run checks`.
        .executableTarget(name: "checks", dependencies: ["CheatKit"], path: "Sources/checks"),
        .testTarget(name: "CheatKitTests", dependencies: ["CheatKit"], path: "Tests/CheatKitTests")
    ]
)
