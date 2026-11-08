// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "share_intake",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "share-intake", targets: ["share_intake"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "share_intake",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
