// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "RadixSwift",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RadixSwift",
            targets: ["RadixSwift"]
        ),
        .executable(
            name: "RadixCatalogDemo",
            targets: ["RadixCatalogDemo"]
        )
    ],
    targets: [
        .target(
            name: "RadixSwift",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "RadixCatalogDemo",
            dependencies: ["RadixSwift"],
            path: "Examples/RadixCatalogDemo"
        ),
        .testTarget(
            name: "RadixSwiftTests",
            dependencies: ["RadixSwift"]
        )
    ]
)
