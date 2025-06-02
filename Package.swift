// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SlotPaper",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "SlotPaper",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
) 