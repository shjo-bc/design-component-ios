// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BCPDesignSystem",
    // 배포 대상인 페이북 앱의 최소 지원 버전과 같다. 더 낮추면 검증이 실제 배포 기준보다 엄격해진다.
    platforms: [.iOS("15.8")],
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

