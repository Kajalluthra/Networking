// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Networking",
            targets: ["Networking"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kajalluthra/TestUtils.git", from: "2.0.0"),
        .package(url: "https://github.com/Kajalluthra/LoggerExtension.git",  from: "3.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "3.2.1"),
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm.git", .upToNextMinor(from: "2.33.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Networking",
            dependencies: ["LoggerExtension", "KeychainAccess", .product(name: "AWSCore", package: "aws-sdk-ios-spm")],
            swiftSettings: []),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking", "TestUtils"],
            resources: [
                .process("json")
            ]),
    ]
)
