// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BCPDesignSystem",
    // macOS 는 `swift build` 로 호스트에서 컴파일 검증하기 위해 선언한다 (배포 대상은 iOS).
    // v13 은 iOS 16 API 와 가용성이 맞는 최소 버전이다. 더 낮추면 호스트 검증이 실제 배포 기준보다 엄격해진다.
    platforms: [.iOS(.v16), .macOS(.v13)],
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
