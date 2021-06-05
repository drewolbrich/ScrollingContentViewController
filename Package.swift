// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ScrollingContentViewController",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ScrollingContentViewController",
            targets: ["ScrollingContentViewController"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ScrollingContentViewController",
            dependencies: []
        ),
        .testTarget(
            name: "ScrollingContentViewControllerTests",
            dependencies: ["ScrollingContentViewController"]
        )
    ]
)
