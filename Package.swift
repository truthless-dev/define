// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Define",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .executable(
      name: "define",
      targets: [
        "Cli"
      ]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "Cli",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .target(name: "Define"),
      ]
    ),
    .target(name: "Define"),
    .testTarget(
      name: "DefineTests",
      dependencies: ["Define"]
    ),
  ]
)
