// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VSSensorFusion",
    platforms: [
            .iOS(.v13)
    ],
    products: [
        .library(
            name: "VSSensorFusion",
            targets: ["VSSensorFusion"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/virtualstores/ios-foundation.git", from: "0.0.2-1-SNAPSHOT"),
    ],
    targets: [
        .target(
            name: "VSSensorFusion",
            dependencies: [
                .product(name: "VSFoundation", package: "ios-foundation")
            ]),
        .testTarget(
            name: "VSSensorFusionTests",
            dependencies: ["VSSensorFusion"]),
    ]
)
