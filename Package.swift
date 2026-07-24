// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Quicksilver",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "QuicksilverCore",
            targets: ["Core", "Memory", "Personas", "ServicesAI", "Nexus"]
        ),
        .library(
            name: "QuicksilverIntents",
            targets: ["QuicksilverIntents"]
        ),
    ],
    targets: [
        .target(
            name: "Core",
            path: "Core",
            exclude: []
        ),
        .target(
            name: "Memory",
            dependencies: ["Core"],
            path: "Memory"
        ),
        .target(
            name: "Personas",
            dependencies: ["Core"],
            path: "Personas"
        ),
        .target(
            name: "ServicesAI",
            dependencies: ["Core"],
            path: "Services/AI"
        ),
        .target(
            name: "Nexus",
            dependencies: ["Core"],
            path: "Nexus"
        ),
        .target(
            name: "QuicksilverIntents",
            dependencies: ["Core", "Personas", "Nexus", "Memory", "ServicesAI"],
            path: "Intents"
        ),
        .testTarget(
            name: "QuicksilverCoreTests",
            dependencies: [
                "Core",
                "Memory",
                "Personas",
                "ServicesAI",
                "Nexus",
                "QuicksilverIntents"
            ],
            path: "Tests",
            exclude: []
        ),
    ]
)
