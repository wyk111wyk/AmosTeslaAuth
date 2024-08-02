// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmosTeslaAuth",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "AmosTeslaAuth",
            targets: ["AmosTeslaAuth"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.1"))
    ],
    targets: [
        .target(
            name: "AmosTeslaAuth",
            dependencies: ["Alamofire"],
            path: "Sources")
    ]
)
