# BCPDesignSystem (iOS / SwiftUI)

BC 페이북 디자인 시스템의 iOS 구현. Figma 파일
`3ar2ONJR9DA46bKMhVQ6ZW` ("26 페이북 Design System Guide") 를 단일 진실
공급원으로 삼는다.

이 저장소는 [shjo-bc/design-component](https://github.com/shjo-bc/design-component)
에서 분리되었고, 그쪽에서는 `platforms/ios` 경로에 submodule 로 마운트된다.

## 사용

Xcode → Add Package Dependency, 또는 `Package.swift`:

```swift
.package(url: "https://github.com/shjo-bc/design-component-ios.git", branch: "main")
```

```swift
.product(name: "BCPDesignSystem", package: "design-component-ios")
```

private 저장소이므로 접근 권한이 필요하다. CI 에서는 SSH 배포 키나 PAT 를 쓴다.

```swift
import BCPDesignSystem

struct ContentView: View {
    var body: some View {
        BCPButton("확인", type: .primary, size: .large) { }
    }
}
```

테마는 앱 루트에서 한 번 주입한다. 인자 없는 `.bcpTheme()` 는 시스템
다크모드 설정을 따라가고, 고정하려면 테마를 직접 넘긴다.

```swift
ContentView().bcpTheme()        // 시스템 설정 추종
ContentView().bcpTheme(.light)  // 라이트 고정
```

배포 대상은 iOS 16 이상이다. `Package.swift` 에 선언된 macOS 13 은 `swift build`
로 호스트에서 컴파일을 검증하기 위한 것이다.

## 구조

```
Package.swift
Sources/BCPDesignSystem/
    Component/      Button, Control, Input, Badge
    Foundation/     토큰에서 생성된 색상·치수·타이포그래피·그림자
codeconnect/        Figma Code Connect 템플릿 (*.figma.ts)
figma.config.json   label: SwiftUI
```

## 직접 수정하지 말 것

`Sources/BCPDesignSystem/Foundation/` 과 `BCPVectorPaths.swift`, 그리고
`codeconnect/` 의 템플릿은 **생성물**이다. 부모 저장소의 `tools/scripts/gen-*.mjs`
가 디자인 토큰과 Figma 스펙으로부터 만들어낸다. 여기서 직접 고치면 다음 생성 때
덮어쓰인다. 부모 저장소에서 생성기를 고치고 `npm run sync:ios` 로 반영한다.

컴포넌트 구현(`Component/`)은 직접 작성하는 코드다.
