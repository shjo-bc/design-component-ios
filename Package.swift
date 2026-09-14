// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PayboocDesignSystem",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "PayboocDesignSystem", targets: ["PayboocDesignSystem"])
    ],
    targets: [
        .target(
            name: "PayboocDesignSystem",
            path: "Sources/PayboocDesignSystem"
        )
    ]
)
