// swift-tools-version: 6.2
import Foundation
import PackageDescription

// The Go engine ships as static libraries: an XCFramework for Apple platforms
// and a SwiftPM artifact bundle for Linux. Swift release tags (bare `x.y.z`
// or `x.y.z-seed.N`,
// while Go uses the same version with a leading `v`) replace this block with the published, checksummed
// release assets. Elsewhere it uses the binaries `make swift` built locally,
// which exist only for the host's platform family.
// BEGIN BINARY TARGETS
let binaryTargets: [Target] = [
    .binaryTarget(name: "CWendyCoreApple", url: "https://github.com/wendylabsinc/wendy-core/releases/download/v0.1.0-seed.1/CWendyCore-0.1.0-seed.1.xcframework.zip", checksum: "a08c78d543c5b7880f4e0b6d81e0dbff19372c3c5794d08495469e645f25ec04"),
    .binaryTarget(name: "CWendyCoreLinux", url: "https://github.com/wendylabsinc/wendy-core/releases/download/v0.1.0-seed.1/CWendyCore-0.1.0-seed.1.artifactbundle.zip", checksum: "870015cc811216927bb6d47a8dd4028c85b02deb5e5844842e412a323424ff72"),
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
