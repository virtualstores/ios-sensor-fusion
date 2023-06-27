// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "VSSensorFusion",
  platforms: [
    .macOS(.v11),
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "VSSensorFusion",
      targets: ["VSSensorFusion"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(url: "https://github.com/virtualstores/ios-foundation.git", .upToNextMajor(from: "1.0.0"))
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
