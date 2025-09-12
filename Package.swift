// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "BSGTranslator",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BSGTranslator",
            targets: ["BSGTranslator"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "BSGTranslator",
            dependencies: [],
            path: "BSGTranslator/BSGTranslator/Sources"
        ),
        .testTarget(
            name: "BSGTranslatorTests",
            dependencies: ["BSGTranslator"],
            path: "BSGTranslator/BSGTranslatorTests/Sources"
        )
    ]
)
