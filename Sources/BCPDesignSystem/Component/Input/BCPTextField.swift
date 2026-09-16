import SwiftUI

/// 검증 상태. Figma `state` 축의 `invalid` / `valid` 를 분리한 것이다
/// (docs/naming-contract.md §2 — `state` 는 분리한다).
public enum BCPValidation: Sendable {
    case none, invalid, valid
}

/// Figma `state` 축 7개 값. 파라미터가 아니라 **파생 결과**다.
///
/// box / line / search 세 계열이 같은 축을 쓰므로 여기서 한 번만 정의한다.
/// 파생 규칙과 우선순위 결정 근거는 `shared/figma/input-style.json` 의 `stateResolution` 에 있다.
enum BCPInputState {
    case normal, focused, typing, filled, disabled, invalid, valid

    static func resolve(
        enabled: Bool,
        validation: BCPValidation,
        focused: Bool,
        isEmpty: Bool
    ) -> BCPInputState {
        if !enabled { return .disabled }
        switch validation {
        case .invalid: return .invalid
        case .valid: return .valid
        case .none: break
        }
        if focused { return isEmpty ? .focused : .typing }
        return isEmpty ? .normal : .filled
    }
}

/// 입력 본체. **chrome 이 없다** — 배경·테두리·밑줄·라벨은 감싸는 쪽이 그린다.
///
/// `BCPBoxTextField` / `BCPLineTextField` / `BCPSearchBar` 가 공유한다.
/// 세 계열은 Figma 에서 껍데기만 다르고 안쪽 입력 동작은 같아서, 여기를 한 번만 맞추면 된다.
public struct BCPTextField: View {
    @Binding private var text: String
    private let placeholder: String
    private let textStyle: BCPTextStyle
    private let textColor: Color
    private let placeholderColor: Color
    private let multilineHeight: CGFloat?
    private var focus: FocusState<Bool>.Binding

    public init(
        text: Binding<String>,
        focus: FocusState<Bool>.Binding,
        placeholder: String = "",
        textStyle: BCPTextStyle = BCPTypography.font1Paragraph3_2,
        textColor: Color,
        placeholderColor: Color,
        multilineHeight: CGFloat? = nil
    ) {
        self._text = text
        self.focus = focus
        self.placeholder = placeholder
        self.textStyle = textStyle
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.multilineHeight = multilineHeight
    }

    public var body: some View {
        if let multilineHeight {
            TextEditor(text: $text)
                .bcpHiddenScrollBackground()
                .background(Color.clear)
                .bcpTextStyle(textStyle)
                .foregroundColor(textColor)
                .focused(focus)
                .frame(height: multilineHeight)
                .bcpFieldAccessibilityName(placeholder)
        } else {
            // `prompt:` 를 쓰지 않는다 — SwiftUI 가 prompt 를 자체 스타일로 그려서
            // `.foregroundColor` 가 반영되지 않는다. 그러면 iOS 만 시스템 회색으로 뜨고
            // Web(직접 그림)과 색이 갈린다. 같은 방식으로 직접 그린다.
            TextField("", text: $text)
                .textFieldStyle(.plain)
                .bcpTextStyle(textStyle)
                .foregroundColor(textColor)
                .focused(focus)
                .overlay(alignment: .leading) {
                    if text.isEmpty && !placeholder.isEmpty {
                        Text(placeholder)
                            .bcpTextStyle(textStyle)
                            .foregroundColor(placeholderColor)
                            .allowsHitTesting(false)
                            // 겹쳐 그린 placeholder 가 필드와 별개 요소로 읽히면
                            // VoiceOver 가 같은 문구를 두 번 말한다. 아래에서 필드 이름으로 쓴다.
                            .accessibilityHidden(true)
                    }
                }
                .bcpFieldAccessibilityName(placeholder)
        }
    }
}

/// 입력 필드 오른쪽의 지우기 버튼. box / line 이 공유한다.
struct BCPInputClearButton: View {
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BCPVectorShape(BCPVectorPaths.inputClear)
                .fill(color)
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("지우기")
    }
}

// MARK: - 접근성

extension View {
    /// 입력 필드에 VoiceOver 가 읽을 이름을 준다.
    ///
    /// `TextField("", text:)` 로 placeholder 를 직접 그리기 때문에 SwiftUI 가 붙여 주는
    /// 이름이 없다 — 그대로 두면 VoiceOver 가 "텍스트 필드" 라고만 말하고 무엇을 넣는
    /// 칸인지 알려주지 못한다. 겹쳐 그린 placeholder 를 이름으로 승격시킨다.
    ///
    /// 호출부가 바깥에서 `.accessibilityLabel(_:)` 을 붙이면 그쪽이 이긴다.
    @ViewBuilder
    func bcpFieldAccessibilityName(_ name: String) -> some View {
        if name.isEmpty { self } else { accessibilityLabel(name) }
    }
}

// MARK: - 버전 분기

extension View {
    /// `TextEditor` 의 기본 스크롤 배경을 지운다.
    /// iOS 16 미만에는 대체 API 가 없다 — `UITextView.appearance()` 전역 변경은 앱 전체에 번지므로 쓰지 않고,
    /// 그 버전에서는 `multiline` 에 한해 기본 배경이 남는다.
    @ViewBuilder
    func bcpHiddenScrollBackground() -> some View {
        if #available(iOS 16.0, *) {
            scrollContentBackground(.hidden)
        } else {
            self
        }
    }
}
