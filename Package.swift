// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TealiumSKAdNetwork",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "TealiumSKAdNetwork", targets: ["TealiumSKAdNetwork"])
    ],
    dependencies: [
        .package(name: "TealiumSwift", url: "https://github.com/tealium/tealium-swift", .upToNextMajor(from: "2.9.0"))
    ],
    targets: [
        .target(
            name: "TealiumSKAdNetwork",
            dependencies: [
                .product(name: "TealiumCore", package: "TealiumSwift"),
                .product(name: "TealiumRemoteCommands", package: "TealiumSwift")
            ],
            path: "./Sources"),
        .testTarget(
            name: "TealiumSKAdNetworkTests",
            dependencies: ["TealiumSKAdNetwork"],
            path: "./Tests")
    ]
)
