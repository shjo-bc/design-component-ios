// swift-tools-version: 5.9

// Xcode 로 이 패키지를 열면 시뮬레이터에서 바로 실행된다.
// `.iOSApplication` 은 AppleProductTypes 가 있어야 해석되므로 **CLI `swift build` 로는
// 빌드되지 않는다** — 확인은 Xcode 나 `xcodebuild` 로 한다.
import PackageDescription
import AppleProductTypes

let package = Package(
    name: "BCPGallery",
    platforms: [.iOS("15.8")],
    products: [
        .iOSApplication(
            name: "BCPGallery",
            targets: ["BCPGallery"],
            bundleIdentifier: "com.bccard.paybooc.designsystem.gallery",
            teamIdentifier: nil,
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .presetColor(.blue),
            supportedDeviceFamilies: [.phone],
            supportedInterfaceOrientations: [.portrait]
        )
    ],
    dependencies: [
        // 개발 중에는 저장소 안의 소스를 그대로 본다 — 릴리스를 기다리지 않고
        // 고친 즉시 화면에서 확인하기 위해서다.
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "BCPGallery",
            // ⚠ path 의존성의 패키지 식별자는 **디렉터리 이름**이다. 이 저장소는 부모
            // (design-component)에 `platforms/ios` 로 마운트되므로 식별자가 `ios` 가 된다.
            // design-component-ios 를 독립 클론해서 열면 식별자가 디렉터리명을 따라가므로
            // 여기를 그 이름으로 바꿔야 한다.
            dependencies: [.product(name: "BCPDesignSystem", package: "ios")],
            path: "Sources/BCPGallery",
            // 실제 앱(pybc-fe-ios)이 번들에 넣는 것과 같은 파일이다.
            // 디자인과 대조하려면 서체가 같아야 한다 — 시스템 폰트로 폴백되면
            // 글자 폭이 달라져 줄바꿈·잘림·버튼 폭이 전부 달라진다.
            resources: [.process("Fonts")]
        )
    ]
)
