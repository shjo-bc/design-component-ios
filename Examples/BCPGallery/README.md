# BCPGallery

디자인 시스템 컴포넌트를 **눈으로 확인하고 손으로 만져보기 위한** 앱이다.

스니펫 컴파일(`check:snippets`)과 Code Connect 검증은 "코드가 말이 되는가" 만 본다.
실제로 어떻게 그려지는지, 포커스·입력·토글이 어떻게 반응하는지는 여기서만 드러난다 —
지금까지 발견된 렌더 버그는 전부 사람이 화면을 보고 찾은 것이다.

## 실행

```bash
open Examples/BCPGallery/Package.swift   # Xcode 가 열린다 → ⌘R
```

⚠ **`xcodebuild` 로는 앱으로 빌드되지 않는다.** `.iOSApplication` product 는 Xcode 가
열었을 때만 앱 번들로 처리되고, CLI 에서는 실행 파일로만 나온다. 컴파일 여부만 확인하려면:

```bash
xcodebuild -scheme BCPGallery -destination 'generic/platform=iOS Simulator' build
```

## 무엇을 보는가

| 탭 | 확인할 것 |
|---|---|
| Buttons | 타입 7종 × 크기 6종의 높이·패딩·색, hug/fill 폭, 비활성 |
| Controls | 체크박스·라디오·토글의 상태 전이, **44×44pt 터치 타깃 대비** |
| Inputs | 포커스 시 테두리 2pt, 오류 상태에서도 포커스 반응, 카드번호 4자리 끊김, 밑줄 색 전이 |

오른쪽 위 버튼으로 **라이트/다크를 전환**한다. 토큰이 모드별로 다르게 해석되므로
한쪽만 보면 절반만 확인하는 셈이다.

## VoiceOver 로 확인할 것

시뮬레이터에서 **설정 → 손쉬운 사용 → VoiceOver** 를 켜고:

- 체크박스·라디오·토글이 호출부가 붙인 이름(`이용약관 동의` 등)으로 읽히는가
- 입력 필드가 placeholder 를 이름으로 읽는가 ("텍스트 필드" 라고만 말하면 실패)
- 오류 상태 필드가 "오류" 를 먼저 말하는가
- dropdown·date 가 텍스트 필드가 아니라 **버튼**으로 읽히는가
- 버튼의 장식 아이콘이 따로 읽히지 않는가

## 의존성

개발 중 수정을 바로 보기 위해 상위 저장소를 `path` 로 참조한다.

⚠ path 의존성의 패키지 식별자는 **디렉터리 이름**이다. 이 저장소는 부모(design-component)에
`platforms/ios` 로 마운트되므로 식별자가 `ios` 다. `design-component-ios` 를 독립 클론해서
열면 `Package.swift` 의 `package:` 인자를 그 디렉터리 이름으로 바꿔야 한다.
