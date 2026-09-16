# CHANGELOG

버전은 [Semantic Versioning](https://semver.org/lang/ko/) 을 따른다.
**0.x 대에서는 공개 API 가 안정적이지 않다** — minor 가 아니라 patch 에서도 깨지는
변경이 들어갈 수 있으므로, 올릴 때 이 문서를 먼저 확인할 것.

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
