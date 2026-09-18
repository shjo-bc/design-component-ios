# CHANGELOG

버전은 [Semantic Versioning](https://semver.org/lang/ko/) 을 따른다.
**0.x 대에서는 공개 API 가 안정적이지 않다** — minor 가 아니라 patch 에서도 깨지는
변경이 들어갈 수 있으므로, 올릴 때 이 문서를 먼저 확인할 것.

## 0.1.10

### 추가 — Badge 계열 4종

Figma `Badges` 페이지를 구현했다. `Component/Badge/` 가 `.gitkeep` 만 있던 자리다.

- **`BCPStatementBadge`** — Figma `badge-statement`. `size` 2종 × `type` 17종. 타입은 색 역할만
  정하고 **문구는 호출부가 넘긴다** — "가족"·"법인공용" 같은 업무 문구를 디자인 시스템이
  소유하지 않기 위해서다. 타입별 Figma 기본 문구는 doc 주석의 표에 남겼다.
- **`BCPHomeCardBadge`** — Figma `badge-homecard`. `type` 8종. "잔액"·"D-8" 처럼 데이터가 들어가는
  자리라 문구는 호출부가 넘긴다.
- **`BCPTermsBadge`** — Figma `badge-terms`. `level` 1~5. 등급 명칭(안심·다소안심·보통·신중·주의)은
  디자인이 정한 고정 문구라 컴포넌트가 갖는다.
- **`BCPSmallBadge`** — Figma `badge-small`. `type` 3종(NEW·ON·OFF) × `style` 2종.
  `subtle` 은 옅은 바탕에 같은 계열 글자, `strong` 은 꽉 찬 바탕에 대비되는 글자다.
  `style` 을 생략하면 Figma 기본 변형을 따른다 — NEW·ON 은 `subtle`, OFF 는 `strong`.
  Figma 의 `color=light-mode`/`dark-mode` 축은 디자이너가 모드를 손으로 바꿔 보려고 둔 것이라
  옮기지 않았다 — 두 변형이 부르는 토큰이 같고 모드는 테마가 처리한다.

색은 생성된 `badge/1` ~ `badge/11` (surface + text 11쌍) 토큰 안에서 전부 해결된다.
네 컴포넌트가 공유하는 내부 코어 `BCPBadge` 가 텍스트·색·패딩·radius 를 받아 그린다.

Code Connect 템플릿 4개(`codeconnect/badge-*.figma.ts`)도 함께 넣었다. **이 4개는 수동 작성이다** —
부모 저장소 생성기(`tools/scripts/gen-*.mjs`)에 배지가 아직 없다. 생성기에 들어가면 대체된다.

### 높이를 패딩이 아니라 값으로 갖는다

Figma 의 배지 높이는 `세로 패딩 + line-height` 다. 그런데 **SwiftUI 의 한 줄 `Text` 높이는
line-height 가 아니라 서체의 실제 행높이**(ascender + descender)다 — 12pt Pretendard 면 20 이
아니라 약 14 다. 패딩만 옮기면 statement large 가 24 가 아니라 18 로 나온다.

그래서 `BCPBadge` 가 `minHeight` 를 받는다. `BCPButton` 이 높이를 따로 갖는 것과 같은 이유이고,
고정이 아니라 최소값이라 문구가 길어지거나 서체가 폴백돼 커져도 잘리지 않는다.

### 확인한 것

**Xcode Preview 로 라이트·다크 양쪽을 네 컴포넌트 모두 Figma 와 대조했다.** 위 `badge-small`
건이 그 과정에서 드러났다 — 컴파일도 Code Connect 문법 검사도 통과한 상태였다. 0.1.9 에서와
같다. 코드가 말이 되는지는 도구가 보지만, 결과가 디자인과 같은지는 사람이 봐야 안다.

### statement large 의 타이포 토큰

처음 구현할 때는 Pretendard 12/20 w700 에 맞는 토큰이 없어 파일 안 private 스타일로 실측값을
박아 두었다. 그 뒤 디자이너가 Figma 의 해당 글자에 텍스트 스타일 `Font-1/Paragraph/paragraph-8-bold`
(`font-1/paragraph/8-1`, 12/16 w700)를 연결해 주어 `BCPTypography.font1Paragraph8_1` 로 교체했다.

- line-height 가 20 → 16 으로 바뀌었고 Figma 는 세로 패딩을 2 → 4 로 늘려 높이 24 를 유지했다.
  코드도 `spacing4` 로 따라간다. 배지 겉 크기는 변하지 않는다.
- 토큰은 부모 저장소 `shared/tokens/src/typography.json` 에 **Typography 컬렉션의 신규 8개
  (`paragraph/8-1`, `8-2`)만 부분 반영**해 `gen-foundation` 으로 생성했다. Figma 에는 그 사이
  다른 변경(Primitives `font/size/*` 이름 변경, Semantic 8개 삭제)도 있어 전체 `pull-tokens`
  는 별도 작업으로 남긴다.
- Figma 쪽 텍스트 스타일은 family·weight·line-height 만 Variable 에 묶여 있고 **size 12 는
  raw 값**이다. `font-1/paragraph/8-1/size` 변수는 있지만 스타일에 바인딩되지 않았다 — 코드는
  토큰 값을 쓰므로 지금은 같다.

### 남은 것

- **서체는 아직 대조하지 못했다.** 패키지 Preview 는 Pretendard 를 번들에 넣지 않아 시스템
  폰트로 떨어진다. 글자 폭이 달라 배지 가로 길이가 실제 앱과 다르다. 서체까지 보려면 갤러리
  앱에 Badges 탭이 필요한데 아직 없다.

### Figma 를 그대로 따른 것

디자인 파일은 건드리지 않는다. 코드가 맞춘다. 둘 다 이름과 실제가 어긋나 있어
모르고 보면 틀리기 쉬운 자리다.

- **`badge-small` 의 옅은 회색 OFF 배지는 변형 이름이 `type=new` 다**
  (`color=light-mode` / `dark-mode`). 이름은 new 지만 그려지는 글자는 "OFF" 라서
  코드에서는 `.off` 의 `subtle` 로 받는다. Preview 를 화면으로 대조하다 드러났다 —
  그 전까지는 Figma 에 없는 "회색 NEW" 를 만들 수 있고 정작 옅은 회색 OFF 는 만들 수 없는
  상태였다.
- **`badge-homecard` 의 `company` variant 이름 앞에 백스페이스 문자(U+0008)가 있다.**
  눈에 보이지 않으므로 Code Connect 템플릿에서 철자를 그대로 맞춰야 한다 — 빠뜨리면
  이 variant 만 매핑이 빈다.

## 0.1.9

**시뮬레이터에 띄워 화면으로 확인하면서 찾은 것들이다.** 아래 다섯 건 모두 컴파일·스니펫
검증·Code Connect 검증을 전부 통과한 상태였다 — 코드가 말이 되는지는 보고 있었지만
결과가 디자인과 같은지는 아무도 보지 않고 있었다.

### 고침

- **돋보기 아이콘이 원만 그려졌다.** `fillGeometry` 가 2조각(원 + 손잡이)인데 첫 조각만
  가져오고 있었다.
- **달력 아이콘이 가로 막대만 그려졌다.** 같은 원인 (4조각 중 1개).
- **dropdown 화살표가 아래가 아니라 오른쪽을 가리켰다.** viewBox 를 `absoluteBoundingBox`
  로 잡았는데 그것은 **회전이 반영된 화면상 크기**다. 경로는 회전 전(8×12, 오른쪽 방향)이라
  12×7 비율로 그리니 찌그러졌다. 경로 좌표에서 viewBox 를 구하고 90° 회전을 코드에서 준다.
- **`Gmarket Sans` 가 적용되지 않았다.** 토큰은 `Gmarket Sans` 를 부르는데 앱이 번들에 넣은
  파일의 family 는 `Gmarket Sans TTF` 다. 이름이 한 글자만 달라도 `Font.custom` 은 조용히
  시스템 폰트로 떨어지고 경고도 없다. `font-2/*` 토큰 19개가 전부 이 상태였다(현재 컴포넌트가
  `font-1` 만 써서 드러나지 않았을 뿐이다).

  토큰 값은 그대로 두고 **읽는 시점에만** 실제 이름으로 해석한다 — 후보 중 기기에 있는 것을
  고르므로 앱이 어느 판본을 넣었든 따라간다.
- **오류·성공 상태에서 placeholder 가 진한 본문 색으로 나왔다.** 이미 입력된 값처럼 보였다.
  Figma 가 placeholder 상태를 그려 둔 것은 `normal` 과 `focused` 둘뿐이라, 근거가 없는
  나머지 상태는 `normal` 의 hint 톤으로 떨어뜨린다. `line` 계열은 원래 이렇게 하고 있어
  두 계열이 어긋나 있던 것이기도 하다.

### 추가

- `BCPFont.missingFamilies()` — 토큰이 요구하는 서체가 기기에 없으면 디버그 빌드에서
  경고한다. 폰트를 빠뜨리면 글자 폭이 달라져 줄바꿈·잘림·버튼 폭이 전부 어긋나는데,
  지금까지는 알아챌 방법이 없었다.
- **Xcode Preview** — 전 컴포넌트에 붙였다. 파일을 열면 캔버스에서 라이트·다크가 나란히
  뜨고 Live 모드로 상태 전이를 눌러볼 수 있다. `#if DEBUG` 안에 있어 릴리스 빌드에는
  포함되지 않는다(심볼 0개로 확인).
- **갤러리 앱** (`Examples/BCPGallery`) — 전 변형을 한 화면에 늘어놓는다. 실제 앱과 같은
  폰트를 등록해 디자인과 같은 서체로 대조할 수 있고, 44×44pt 터치 타깃 대비와 폰트 해석
  결과도 눈으로 볼 수 있다. `--tab` / `--scroll` / `--dark` 인자로 원하는 화면을 바로 띄운다.

### 확인한 것

라이트·다크 양쪽을 시뮬레이터(iOS 26.5)에서 스크린샷으로 확인했다. 토큰이 모드별로 제대로
해석된다 — primary 버튼이 다크에서 보라로 바뀌고, isp 는 브랜드 색이라 노랑을 유지한다.

## 0.1.8

### 추가 — 접근성 (SwiftUI 전 컴포넌트)

컴포넌트가 **역할·상태·동작**을 스스로 알리도록 일괄 적용했다. API 는 바뀌지 않는다.

- **입력 필드에 이름이 생겼다.** `TextField("", text:)` 로 placeholder 를 직접 그리는 구조라
  VoiceOver 가 "텍스트 필드" 라고만 말하고 무엇을 넣는 칸인지 알려주지 못했다. placeholder 를
  이름으로 승격시키고, 겹쳐 그린 placeholder 는 중복해서 읽히지 않게 숨겼다.
  `BCPLineTextField` 는 `label` 이 있으면 그쪽이 이름이다.
- **helper text 와 오류가 필드에 이어 읽힌다.** `validation: .invalid` 면 "오류" 를 먼저 말한다 —
  색만으로는 전달되지 않는다.
- **`dropdown` · `date` 는 버튼으로 읽힌다.** 값을 고르는 칸이라 텍스트 필드로 읽히면
  VoiceOver 사용자가 키보드를 기대하게 된다. 현재 선택값도 값으로 알린다.
- **체크박스 · 라디오 · 토글이 하나의 조작 요소로 묶였다.** 도형만 있어 읽을 것이 없던 상태였다.
  상태를 값으로 알리고(`선택됨`/`켜짐` 등), 토글에는 "켜기"/"끄기" 사용자 동작을 붙였다.
- **장식 아이콘을 숨겼다.** `BCPButton` 의 leading/trailing 아이콘, `BCPArrowButton` 의 화살표,
  검색 돋보기. 그대로 두면 "이미지, 확인, 버튼" 처럼 들린다.
- **아이콘 전용 버튼에 이름을 줬다.** `BCPScrollToTopButton` → "맨 위로".

### 호출부가 해야 할 일

`BCPCheckbox` · `BCPRadioButton` · `BCPToggle` 은 **무엇에 대한 컨트롤인지 컴포넌트가 알 수
없다.** 이름을 붙여야 한다 (없으면 "선택 안 함, 버튼" 만 읽힌다).

```swift
BCPCheckbox(checked: agreed) { agreed = $0 }
    .accessibilityLabel("이용약관 동의")
```

다른 컴포넌트도 바깥에서 `.accessibilityLabel(_:)` 을 붙이면 그쪽이 이긴다.

### 아직 안 된 것

- **터치 타깃이 Apple 권장(44×44pt)보다 작다** — 체크박스 24pt(small 20pt), 라디오 24pt,
  토글 높이 28pt. 키우면 주변 간격이 달라져 Figma 레이아웃과 어긋나므로 디자인 확인이 필요하다.
- **Dynamic Type 미지원** — `BCPTextStyle` 이 고정 pt 를 쓴다.
- VoiceOver 로 실제 읽어 본 검증은 하지 않았다. 코드상 semantics 만 맞춘 상태다.

## 0.1.7

### 고침

- `validation` 이 켜진 필드에서 **포커스 피드백이 통째로 사라지던 문제.** 상태 파생이
  `validation` 을 `focus` 보다 먼저 반환해서, `invalid`/`valid` 일 때는 포커스 전후로
  테두리 색도 두께도 바뀌지 않았다. 오류난 필드를 고치려고 탭해도 아무 반응이 없었다.

  색은 `validation` 이, 두께는 포커스가 갖도록 나눴다. 오류 색을 유지하면서 테두리가
  1px ↔ 2px 로 반응한다. 두 값 모두 Figma 에 있는 것을 조합할 뿐이다.

  `BCPLineTextField` 는 밑줄이 7개 state 전부 2pt 고정이라 이 방법이 통하지 않는다 —
  `validation` 이 켜진 line 필드는 **여전히 포커스 표시가 없다** (Figma 토큰 추가 필요).

### 바뀐 동작 (렌더 결과는 동일)

값이 아니라 **Figma 에 바인딩된 토큰 이름**을 따르도록 세 곳을 되돌렸다. 두 토큰이 같은
원시 색을 가리켜도 이름이 다르면 각각 참조한다 — 값으로 묶으면 디자이너가 한쪽을 바꿔도
코드가 따라가지 않기 때문이다. 현재 값이 같아 **화면에 보이는 결과는 달라지지 않는다.**

- 테두리 두께가 `focused`/`typing` 토큰을 각각 참조한다 (전에는 포커스면 `focused` 로 고정)
- `BCPSearchBar` 입력 글자가 Figma 의 상대 번호 교차 바인딩을 그대로 따른다
  (`searchbar-1` → `input/search-2/text-normal`)
- `BCPLineTextField` 의 `normal` 라벨이 Figma 대로 원시 `color/font/neutral/6` 을 쓴다

### 디자이너 확인 대기

`docs/naming-contract.md` §6 에 5건을 적었다. 특히 `input/{basic,line}/typing/*` 이
`focused/*` 와 같은 원시 토큰을 가리키고 있어, 두 상태를 시각적으로 구분하려면 Figma 에서
별칭을 갈라야 한다 (코드는 이미 각각 참조하므로 값만 바꾸면 반영된다).

## 0.1.6

### 추가

- `BCPButtonType.chip` — 연한 채움(`button/1`) 위에 gradient 텍스트를 얹는 칩 배치.
  자동완성·필터 칩에 쓴다. `xsmall` 과 조합하면 높이 32 · 좌우 10 · radius 8 이다.

  ```swift
  BCPButton(domain, type: .chip, size: .xsmall) { ... }
  ```

## 0.1.5

### ⚠️ 깨지는 변경

- `BCPLineTextField` 의 `focus` 파라미터 타입이 `FocusState<Bool>.Binding?` → **`Binding<Bool>?`** 로
  바뀌었다. 호출부는 `@FocusState` 대신 `@State` 를 쓴다.

  ```swift
  // 0.1.4
  @FocusState private var isFocused: Bool
  // 0.1.5
  @State private var isFocused = false

  BCPLineTextField(text: $text, focus: $isFocused, label: "이메일")
  ```

### 고침

- 0.1.4 에서 외부 `focus` 를 넘기면 포커스 상태가 화면에 반영되지 않던 문제. `@FocusState` 는
  선언한 뷰에서만 값 변화로 재렌더를 일으키는데, 바깥 `FocusState` 를 그대로 읽는 구조라
  컴포넌트가 무효화되지 않았다. 밑줄 색이 `focused` 로 바뀌지 않고 지우기 버튼도 나타나지
  않았다. 포커스는 컴포넌트가 쥐고 외부 `Binding` 과 양방향 동기화하도록 고쳤다.

## 0.1.4

### 추가

- `BCPLineTextField` 에 `focus: FocusState<Bool>.Binding?` 파라미터. 화면 진입 직후
  자동 포커스처럼 호출부가 포커스를 쥐어야 할 때 쓴다. 기본값 `nil` 이라 기존
  호출부는 그대로 내부 상태로 동작한다.

  ```swift
  @FocusState private var isEmailFocused: Bool

  BCPLineTextField(text: $email, focus: $isEmailFocused, label: "이메일")
  ```

## 0.1.3

### ⚠️ 깨지는 변경

- **`BCPTextField` 가 다른 것을 가리킨다.** box 계열 입력 필드는
  **`BCPBoxTextField`** 로 이름이 바뀌었다. `BCPTextField` 라는 이름은 남아 있지만
  이제 배경·테두리가 없는 **입력 코어**다 (box/line/search 가 공유한다).
  이름이 살아 있어 컴파일이 통과할 수 있으니 주의할 것.

  ```swift
  // 0.1.2
  BCPTextField(text: $text, type: .basic, placeholder: "Text")
  // 0.1.3
  BCPBoxTextField(text: $text, type: .basic, placeholder: "Text")
  ```

- `BCPTextFieldType` → `BCPBoxTextFieldType`

### 추가

- `BCPLineTextField` — 밑줄 계열 입력 (`line-input-basic`, `line-input-dropdown`)
- `BCPSearchBar` — 검색바 (`searchbar-1`, `searchbar-2`, style1/style2)
- `BCPBoxTextField` 에 종류 추가 — `dropdown` · `date` · `amountLarge` · `cardNumber` · `number`
- 벡터 경로 `searchGlass` · `chevronDown` · `calendar`

이로써 Figma Inputs 페이지 10개 세트가 모두 연결됐다 (Code Connect 렌더 확인 완료).

### 수정

- 큰 계열(72pt) 박스 패딩을 일괄값으로 덮던 것을 실측대로 나눴다 —
  `date` 는 오른쪽 14·간격 8, `number` 는 버튼이 붙으면 오른쪽·상하 12 다.

### 알려진 제약

- **렌더를 검증하지 않았다.** 컴파일과 Figma Code Connect 스니펫만 확인했고,
  시뮬레이터에 띄워 디자인과 비교한 적은 없다. 스냅샷 테스트가 없어 회귀도 잡히지 않는다.
- 접근성 지정이 Checkbox · RadioButton · Toggle · clear 버튼에만 있다. 버튼 계열에는 없다.

## 0.1.2

- `BCPButton` 에 폭 모드(`hug` / `fill`) 추가

## 0.1.1

- 배포 타깃을 iOS 15.8 로 낮추고 macOS 선언 제거

## 0.1.0

- 최초 릴리스 — Foundation(토큰) · Button · Control · Input(box-input-basic)
