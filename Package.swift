// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MCBRiOSSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MCBRiOSSDK",
            targets: ["MCBRiOSSDK"]
        ),
    ],
    targets: [
        .target(
            name: "MCBRiOSSDK",
            resources: [
                .copy("Resources/mcbr-sdk.min.js")
            ]
        ),
        .testTarget(
            name: "MCBRiOSSDKTests",
            dependencies: ["MCBRiOSSDK"]
        ),
    ]
)
