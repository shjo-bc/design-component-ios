import SwiftUI

/// 페이북 디자인 시스템 line 입력 필드.
///
/// 배경 없이 **밑줄 2pt** 로만 경계를 그리는 계열이고 `input/line/*` 토큰을 쓴다.
/// box 계열과 달리 위에 라벨이 붙고, 입력 글자가 20/700 으로 더 크다.
///
/// `clear` 버튼은 box 와 같은 규칙 — 포커스 상태에서 값이 있을 때만(= Figma `typing`) 나타난다.
/// line 계열 입력 필드의 종류. Figma `line-input-*` 세트들에 대응한다.
public enum BCPLineTextFieldType: Sendable {
    /// `line-input-basic` — 직접 입력한다.
    case basic
    /// `line-input-dropdown` — 목록에서 고른다. 밑줄 위 오른쪽에 아래 방향 chevron 이 붙는다.
    case dropdown

    var isEditable: Bool { self == .basic }
}

public struct BCPLineTextField: View {
    private let type: BCPLineTextFieldType
    private let label: String?
    private let placeholder: String
    private let helperText: String?
    private let validation: BCPValidation
    private let onTap: (() -> Void)?
    @Binding private var value: String

    /// 포커스는 항상 여기가 쥔다 — `@FocusState` 는 선언한 뷰에서만 값 변화로 재렌더를 일으킨다.
    /// 바깥 `FocusState` 를 그대로 읽으면 이 뷰가 무효화되지 않아 밑줄·clear 버튼이 상태를 따라가지 못한다.
    @FocusState private var isFocused: Bool
    private let externalFocus: Binding<Bool>?
    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    /// `label` / `helperText` 가 `nil` 이면 그 줄이 사라진다.
    /// Figma 의 `show label` / `show helpertxt` 불리언에 대응한다.
    ///
    /// `focus` 를 넘기면 호출부가 포커스를 읽고 쓸 수 있다 — 화면 진입 직후 자동 포커스처럼
    /// 바깥 사정으로 포커스를 옮겨야 할 때 쓴다. 넘기지 않으면 내부 상태로만 동작한다.
    public init(
        text: Binding<String>,
        type: BCPLineTextFieldType = .basic,
        focus: Binding<Bool>? = nil,
        label: String? = nil,
        placeholder: String = "",
        helperText: String? = nil,
        validation: BCPValidation = .none,
        onTap: (() -> Void)? = nil
    ) {
        self._value = text
        self.type = type
        self.externalFocus = focus
        self.label = label
        self.placeholder = placeholder
        self.helperText = helperText
        self.validation = validation
        self.onTap = onTap
    }

    private var state: BCPInputState {
        // dropdown 은 키보드 포커스를 잡지 않으므로 focused·typing 이 나오지 않는다.
        .resolve(
            enabled: isEnabled,
            validation: validation,
            focused: type.isEditable && isFocused,
            isEmpty: value.isEmpty
        )
    }

    // MARK: - 토큰

    private var lineColor: Color {
        let c = theme.component
        switch state {
        case .normal: return c.inputLineNormalLine
        case .focused: return c.inputLineFocusedLine
        case .typing: return c.inputLineTypingLine
        case .filled: return c.inputLineFilledLine
        case .disabled: return c.inputLineDisabledLine
        case .invalid: return c.inputLineInvalidLine
        case .valid: return c.inputLineValidLine
        }
    }

    /// `focused` 는 값이 비어 있는 상태라 입력 글자가 보이지 않는다.
    /// Figma 에 전용 text 토큰도 없어서 placeholder 와 같은 `normal/text-hint` 를 쓴다.
    private var textColor: Color {
        let c = theme.component
        switch state {
        case .normal, .focused: return c.inputLineNormalTextHint
        case .typing: return c.inputLineTypingText
        case .filled: return c.inputLineFilledText
        case .disabled: return c.inputLineDisabledText
        case .invalid: return c.inputLineInvalidText
        case .valid: return c.inputLineValidText
        }
    }

    private var placeholderColor: Color { theme.component.inputLineNormalTextHint }

    /// `normal` 만 원시 `color/font/neutral/6` 을, 나머지 state 는 `input/line/label` 을
    /// 물고 있다 (Figma 실측). 두 토큰은 지금 같은 값이지만 바인딩된 이름을 그대로 따른다 —
    /// 값으로 묶어 버리면 디자이너가 한쪽을 바꿔도 코드가 따라가지 않는다.
    /// normal 만 원시 토큰인 것이 의도인지는 디자이너 확인 사항이다 (docs/naming-contract.md §6).
    private var labelColor: Color {
        state == .normal ? theme.semantic.colorFontNeutral6 : theme.component.inputLineLabel
    }

    /// Figma 는 helper 색을 `invalid` / `valid` 에만 정의한다.
    /// 나머지 상태에서 helper 를 띄우면 라벨과 같은 색으로 둔다 — 디자인에 근거가 없는 자리다.
    private var helperColor: Color {
        let c = theme.component
        switch state {
        case .invalid: return c.inputLineInvalidTextHelper
        case .valid: return c.inputLineValidTextHelper
        default: return c.inputLineLabel
        }
    }

    // MARK: - 조각

    private var showsClearButton: Bool { type.isEditable && state == .typing }

    /// VoiceOver 가 필드에 이어서 읽을 보조 설명.
    ///
    /// helper text 는 화면상 별도 줄이지만 필드와 떨어져 읽히면 무엇에 대한 설명인지
    /// 알 수 없다. 오류일 때는 그 사실을 먼저 알린다 — 색만으로는 전달되지 않는다.
    private var accessibilityHintText: String? {
        var parts: [String] = []
        if state == .invalid { parts.append("오류") }
        if let helperText, !helperText.isEmpty { parts.append(helperText) }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    /// Figma 는 dropdown 의 chevron 에 `input/line/focused/line` 을 물려 뒀다 —
    /// 밑줄과 같은 색 계열이다. disabled 만 semantic 표면 토큰으로 빠진다.
    private var chevronColor: Color {
        state == .disabled ? theme.semantic.colorSurface7 : theme.component.inputLineFocusedLine
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                Text(label)
                    .bcpTextStyle(BCPTypography.font1Paragraph6_2)
                    .foregroundColor(labelColor)
                    // 라벨은 아래 입력 필드의 이름으로 다시 읽힌다. 따로 읽으면 중복이다.
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: BCPDimens.spacing6) {
                HStack(spacing: BCPDimens.spacing10) {
                    if !type.isEditable {
                        Text(value.isEmpty ? placeholder : value)
                            .bcpTextStyle(BCPTypography.font1Subheading3_1)
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            // 값을 고르는 칸이다 — 편집 가능한 텍스트 필드가 아니라 버튼으로 읽혀야
                            // VoiceOver 사용자가 키보드를 기대하지 않는다.
                            .accessibilityAddTraits(.isButton)
                            .accessibilityLabel(label ?? placeholder)
                            .accessibilityValue(value.isEmpty ? "선택 안 함" : value)
                        // 경로는 오른쪽 방향(8×12)이고 Figma 노드가 90° 돌아가 아래를 가리킨다.
                        // 자리는 Figma 의 인스턴스 크기(20×20)를 유지한다.
                        BCPVectorShape(BCPVectorPaths.chevronDown)
                            .fill(chevronColor)
                            .frame(width: 8, height: 12)
                            .rotationEffect(.degrees(90))
                            .frame(width: 20, height: 20)
                    } else {
                    BCPTextField(
                        text: $value,
                        focus: $isFocused,
                        placeholder: placeholder,
                        textStyle: BCPTypography.font1Subheading3_1,
                        textColor: textColor,
                        placeholderColor: placeholderColor
                    )
                    // 라벨이 있으면 그쪽이 필드 이름이다 (placeholder 보다 구체적이다).
                    .bcpFieldAccessibilityName(label ?? "")
                    }
                    if showsClearButton {
                        // Figma 의 아이콘 색은 Variable 이 걸려 있지 않다(#8f96a0).
                        // 원시값을 코드에 박지 않고 가장 가까운 컴포넌트 토큰인 라벨 색을 쓴다.
                        BCPInputClearButton(color: theme.component.inputLineLabel) { value = "" }
                    }
                }
                .frame(height: 28)

                Rectangle()
                    .fill(lineColor)
                    .frame(height: 2)
            }
            .padding(.top, BCPDimens.spacing4)

            if let helperText {
                Text(helperText)
                    .bcpTextStyle(BCPTypography.font1Paragraph6_2)
                    .foregroundColor(helperColor)
                    .padding(.top, BCPDimens.spacing6)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityHint(accessibilityHintText ?? "")
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnabled else { return }
            if type.isEditable { isFocused = true }
            onTap?()
        }
        .onChange(of: isFocused) { focused in
            guard let externalFocus, externalFocus.wrappedValue != focused else { return }
            externalFocus.wrappedValue = focused
        }
        .onChange(of: externalFocus?.wrappedValue ?? false) { focused in
            guard externalFocus != nil, isFocused != focused else { return }
            isFocused = focused
        }
    }
}

#if DEBUG
struct BCPLineTextField_Previews: PreviewProvider {
    /// 밑줄 색이 포커스를 따라가는지, 값이 생기면 지우기 버튼이 나오는지 눌러서 확인한다.
    private struct Demo: View {
        @State private var basic = ""
        @State private var dropdown = ""
        @State private var focus = false

        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                BCPLineTextField(text: $basic, focus: $focus, label: "이메일",
                                 placeholder: "Text", helperText: "도움말")
                BCPLineTextField(text: .constant("wrong"), label: "오류", placeholder: "Text",
                                 helperText: "형식이 올바르지 않습니다", validation: .invalid)
                BCPLineTextField(text: $dropdown, type: .dropdown, label: "카드사",
                                 placeholder: "선택하세요",
                                 onTap: { dropdown = dropdown.isEmpty ? "BC카드" : "" })
                BCPLineTextField(text: .constant(""), label: "비활성", placeholder: "Text").disabled(true)
            }
            .padding()
        }
    }

    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            Demo()
                .bcpTheme()
                .preferredColorScheme(scheme)
                .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
