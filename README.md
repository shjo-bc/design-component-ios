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

배포 대상은 iOS 15.8 이상이다. 페이북 앱의 최소 지원 버전과 같다.

## 구조

```
Package.swift
Sources/BCPDesignSystem/
    Component/      Button, Control, Input, Badge
    Foundation/     토큰에서 생성된 색상·치수·타이포그래피·그림자
codeconnect/        Figma Code Connect 템플릿 (*.figma.ts)
figma.config.json   label: SwiftUI
```

## 화면으로 확인하기

### Xcode Preview (권장)

```bash
open Package.swift          # Xcode 가 열린다
```

컴포넌트 파일을 열고 캔버스(⌥⌘↩)를 켜면 바로 렌더된다. **라이트/다크가 나란히** 뜨고,
Live 모드에서는 눌러서 상태 전이까지 확인할 수 있다 — 포커스에 따라 테두리가 두꺼워지는지,
값이 생기면 지우기 버튼이 나오는지 같은 것은 눌러 봐야 안다.

preview 는 `#if DEBUG` 안에 있어 **릴리스 빌드에는 포함되지 않는다** (심볼 0개로 확인).

| 파일 | 보이는 것 |
|---|---|
| `BCPButton.swift` | 타입 7종 · 크기 6종 · 폭 · 비활성 |
| `BCPCheckbox.swift` | 상태 전이 + **44×44pt 터치 타깃 대비** |
| `BCPBoxTextField.swift` | validation · 금융 입력 · 선택형 |
| `BCPLineTextField.swift` | 밑줄 색 전이 · 지우기 버튼 |
| `BCPStatementBadge.swift` | 타입 17종 × 크기 2종의 색 팔레트 |

### 갤러리 앱

전체를 한 화면에서 보거나 VoiceOver 로 확인하려면 앱으로 띄운다.

```bash
open Examples/BCPGallery/Package.swift   # Xcode → ⌘R
```

자세한 내용은 [`Examples/BCPGallery/README.md`](Examples/BCPGallery/README.md) 를 본다.

## 접근성

컴포넌트는 **역할·상태·동작**(trait / value / action)을 스스로 제공한다. 아이콘 전용
요소에는 이름도 들어 있다(`BCPScrollToTopButton` → "맨 위로", 지우기 버튼 → "지우기").
장식용 아이콘은 `accessibilityHidden` 으로 빼 두어 VoiceOver 가 중복해서 읽지 않는다.

### 이름을 반드시 붙여야 하는 것

`BCPCheckbox` · `BCPRadioButton` · `BCPToggle` 은 **도형만으로 이루어져 있어** 무엇에 대한
컨트롤인지 컴포넌트가 알 수 없다. 호출부가 이름을 준다.

```swift
BCPCheckbox(checked: agreed) { agreed = $0 }
    .accessibilityLabel("이용약관 동의")      // 없으면 VoiceOver 가 "선택 안 함, 버튼" 만 읽는다

BCPToggle(isOn: pushOn) { pushOn = $0 }
    .accessibilityLabel("푸시 알림")
```

상태는 컴포넌트가 알린다 — 체크박스·라디오는 `선택됨`/`선택 안 함`, 토글은 `켜짐`/`꺼짐` 이
값으로 읽히고, 토글에는 "켜기"/"끄기" 사용자 동작도 붙어 있다.

### 입력 필드

`placeholder` 가 필드 이름이 된다. `BCPLineTextField` 는 `label` 을 주면 그쪽이 이름이다
(더 구체적이므로). helper text 와 오류 상태는 힌트로 이어 읽힌다 — `validation: .invalid`
이면 "오류" 를 먼저 말한다. 색만으로는 전달되지 않기 때문이다.

`dropdown` · `date` 는 값을 고르는 칸이라 텍스트 필드가 아니라 **버튼**으로 읽힌다.
VoiceOver 사용자가 키보드를 기대하지 않도록 한 것이다.

이름을 바꾸고 싶으면 바깥에서 `.accessibilityLabel(_:)` 을 붙이면 된다 — 그쪽이 이긴다.

### 아직 안 된 것

- **터치 타깃이 Apple 권장(44×44pt)보다 작다** — 체크박스 24pt(small 20pt), 라디오 24pt,
  토글 높이 28pt. 키우면 주변 간격이 달라져 Figma 레이아웃과 어긋나므로 디자인 확인이 필요하다.
- **Dynamic Type 미지원** — `BCPTextStyle` 이 고정 pt 를 쓴다. 글자 크기 설정을 따라가지 않는다.

## 직접 수정하지 말 것

`Sources/BCPDesignSystem/Foundation/` 과 `BCPVectorPaths.swift`, 그리고
`codeconnect/` 의 템플릿은 **생성물**이다. 부모 저장소의 `tools/scripts/gen-*.mjs`
가 디자인 토큰과 Figma 스펙으로부터 만들어낸다. 여기서 직접 고치면 다음 생성 때
덮어쓰인다. 부모 저장소에서 생성기를 고치고 `npm run sync:ios` 로 반영한다.

컴포넌트 구현(`Component/`)은 직접 작성하는 코드다.
