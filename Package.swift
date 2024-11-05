// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmosTeslaAuth",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "AmosTeslaAuth",
            targets: ["AmosTeslaAuth"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.0")),
        .package(url: "https://github.com/wyk111wyk/AmosBase.git", .upToNextMajor(from: "1.6.0"))
    ],
    targets: [
        .target(
            name: "AmosTeslaAuth",
            dependencies: ["Alamofire", "AmosBase"],
            path: "Sources",
            resources: [
                .process("Resources"),
                .process("Localization")])
    ]
)
