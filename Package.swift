// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "BSGTranslator",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "BSGTranslator", targets: ["BSGTranslator"])
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "BSGTranslator", dependencies: [], path: "Sources", exclude: ["Info.plist"]),
        .testTarget(name: "BSGTranslatorTests", dependencies: ["BSGTranslator"], path: "Tests", exclude: ["Info.plist"])
    ]
)
