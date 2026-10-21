// swift-tools-version: 6.2
import Foundation
import PackageDescription

// The Go engine ships as static libraries: an XCFramework for Apple platforms
// and a SwiftPM artifact bundle for Linux. Swift release tags (bare `x.y.z`,
// while Go uses `vx.y.z`) replace this block with the published, checksummed
// release assets. Elsewhere it uses the binaries `make swift` built locally,
// which exist only for the host's platform family.
// BEGIN BINARY TARGETS
let binaryTargets: [Target] = [
    .binaryTarget(name: "CWendyCoreApple", url: "https://github.com/wendylabsinc/wendy-core/releases/download/v0.0.1/CWendyCore-0.0.1.xcframework.zip", checksum: "8e51eeaca7e1d938d705853060199297b3df09537b21c3ade373f8357c3e109e"),
    .binaryTarget(name: "CWendyCoreLinux", url: "https://github.com/wendylabsinc/wendy-core/releases/download/v0.0.1/CWendyCore-0.0.1.artifactbundle.zip", checksum: "b79de67afaa06c1e10ddd8c7ec52d0f01f3cc49afcbf9c27e31be3ffc58355c0"),
]
// END BINARY TARGETS

let binaryPlatforms: [String: [Platform]] = [
    "CWendyCoreApple": [.macOS, .iOS],
    "CWendyCoreLinux": [.linux],
]

let package = Package(
    name: "wendy-core",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [.library(name: "WendyCore", targets: ["WendyCore"])],
    targets: binaryTargets + [
        .target(
            name: "WendyCore",
            dependencies: binaryTargets.map {
                .target(name: $0.name, condition: .when(platforms: binaryPlatforms[$0.name, default: []]))
            },
            path: "distributions/swift/Sources/WendyCore",
            swiftSettings: [.enableUpcomingFeature("InternalImportsByDefault")],
            // Go's iOS runtime uses CoreFoundation.
            linkerSettings: [.linkedFramework("CoreFoundation", .when(platforms: [.iOS]))]
        ),
        .testTarget(
            name: "WendyCoreTests",
            dependencies: ["WendyCore"],
            path: "distributions/swift/Tests/WendyCoreTests"
        ),
    ]
)
