// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "libtoken",
    platforms: [
        .iOS(.v12), .watchOS(.v4)
    ],
    products: [
        .library(name: "libtoken", targets: ["libtoken"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "3.2.0")
    ],
    targets: [
        .target(name: "FontAwesome.swift", path: "Sources/FontAwesomeSwift/FontAwesome"),
        .target(name: "libtoken", dependencies: [.target(name: "FontAwesome.swift"), "KeychainAccess"]),
        .testTarget(name: "libtokenTests", dependencies: ["libtoken"]),
    ]
)
