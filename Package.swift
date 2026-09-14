// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BCPDesignSystem",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "BCPDesignSystem", targets: ["BCPDesignSystem"])
    ],
    targets: [
        .target(
            name: "BCPDesignSystem",
            path: "Sources/BCPDesignSystem"
        )
    ]
)
