// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "bech32",
    platforms: [ .iOS(.v13), .macOS(.v10_15) ],
    products: [
        .library(
            name: "bech32",
            targets: ["bech32"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "bech32",
            dependencies: ["Cbech32"]),
        .target(
            name: "Cbech32",
            dependencies: [],
            path: "Sources/Cbech32/ref/c",
            exclude: [ "tests.c" ],
            sources: [ "segwit_addr.c" ],
            publicHeadersPath: ".",
            cSettings: [ .headerSearchPath("."), ]),
        .testTarget(
            name: "bech32Tests",
            dependencies: ["bech32"]),
    ]
)
