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
            name: "StoryboardTests",
            dependencies: ["ScrollingContentViewController"]
        ),
        .testTarget(
            name: "CodeTests",
            dependencies: ["ScrollingContentViewController"]
        ),
        .testTarget(
            name: "ManagerTests",
            dependencies: ["ScrollingContentViewController"]
        ),
        .testTarget(
            name: "IntrinsicSizeTests",
            dependencies: ["ScrollingContentViewController"]
        ),
        .testTarget(
            name: "KeyboardTests",
            dependencies: ["ScrollingContentViewController"]
        ),
        .testTarget(
            name: "InsetContentViewKeyboardTests",
            dependencies: ["ScrollingContentViewController"]
        )
    ]
)
