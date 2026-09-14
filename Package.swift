// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BCPDesignSystem",
    // macOS 는 `swift build` 로 호스트에서 컴파일 검증하기 위해 선언한다 (배포 대상은 iOS).
    platforms: [.iOS(.v16), .macOS(.v12)],
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
