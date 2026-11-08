// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "conversation_shortcuts",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "conversation-shortcuts", targets: ["conversation_shortcuts"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "conversation_shortcuts",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
