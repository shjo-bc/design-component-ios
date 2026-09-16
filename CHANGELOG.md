# CHANGELOG

버전은 [Semantic Versioning](https://semver.org/lang/ko/) 을 따른다.
**0.x 대에서는 공개 API 가 안정적이지 않다** — minor 가 아니라 patch 에서도 깨지는
변경이 들어갈 수 있으므로, 올릴 때 이 문서를 먼저 확인할 것.

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
