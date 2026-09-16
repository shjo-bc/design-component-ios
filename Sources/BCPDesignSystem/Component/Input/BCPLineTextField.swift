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

    /// 호출부가 포커스를 쥐지 않을 때 쓰는 내부 상태.
    @FocusState private var internalFocus: Bool
    private let externalFocus: FocusState<Bool>.Binding?
    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    /// `label` / `helperText` 가 `nil` 이면 그 줄이 사라진다.
    /// Figma 의 `show label` / `show helpertxt` 불리언에 대응한다.
    ///
    /// `focus` 를 넘기면 호출부가 포커스를 쥔다 — 화면 진입 직후 자동 포커스처럼
    /// 바깥 사정으로 포커스를 옮겨야 할 때 쓴다. 넘기지 않으면 내부 상태로 동작한다.
    public init(
        text: Binding<String>,
        type: BCPLineTextFieldType = .basic,
        focus: FocusState<Bool>.Binding? = nil,
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

    private var focus: FocusState<Bool>.Binding { externalFocus ?? $internalFocus }

    private var state: BCPInputState {
        // dropdown 은 키보드 포커스를 잡지 않으므로 focused·typing 이 나오지 않는다.
        .resolve(
            enabled: isEnabled,
            validation: validation,
            focused: type.isEditable && focus.wrappedValue,
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

    /// Figma 는 dropdown 의 chevron 에 `input/line/focused/line` 을 물려 뒀다 —
    /// 밑줄과 같은 색 계열이다. disabled 만 semantic 표면 토큰으로 빠진다.
    private var chevronColor: Color {
        state == .disabled ? theme.semantic.colorSurface7 : theme.component.inputLineFocusedLine
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let label {
                // Figma 의 `normal` 만 라벨에 원시 `color/font/neutral/6` 을 물려 뒀는데,
                // `input/line/label` 과 값이 라이트·다크 모두 동일하다. 컴포넌트 토큰으로 통일한다.
                Text(label)
                    .bcpTextStyle(BCPTypography.font1Paragraph6_2)
                    .foregroundColor(theme.component.inputLineLabel)
            }

            VStack(alignment: .leading, spacing: BCPDimens.spacing6) {
                HStack(spacing: BCPDimens.spacing10) {
                    if !type.isEditable {
                        Text(value.isEmpty ? placeholder : value)
                            .bcpTextStyle(BCPTypography.font1Subheading3_1)
                            .foregroundColor(textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        BCPVectorShape(BCPVectorPaths.chevronDown)
                            .fill(chevronColor)
                            .frame(width: 20, height: 20)
                    } else {
                    BCPTextField(
                        text: $value,
                        focus: focus,
                        placeholder: placeholder,
                        textStyle: BCPTypography.font1Subheading3_1,
                        textColor: textColor,
                        placeholderColor: placeholderColor
                    )
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
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnabled else { return }
            if type.isEditable { focus.wrappedValue = true }
            onTap?()
        }
    }
}
