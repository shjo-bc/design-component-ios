import SwiftUI

/// 입력 필드 종류. Figma `box-input-basic` 세트의 `type` 축.
public enum BCPTextFieldType: Sendable {
    /// 단일 행 기본 입력.
    case basic
    /// 금액 입력. 값 뒤에 단위(`원`)를 붙인다.
    case amount
    /// 여러 줄 입력. 높이가 고정되고 글자 수 카운터가 붙는다.
    case multiline
}

/// 검증 상태. Figma `state` 축의 `invalid` / `valid` 를 분리한 것이다
/// (docs/naming-contract.md §2 — `state` 는 분리한다).
public enum BCPValidation: Sendable {
    case none, invalid, valid
}

/// Figma `state` 축 7개 값. 파라미터가 아니라 **파생 결과**다.
///
/// 파생 규칙과 우선순위 결정 근거는 `shared/figma/input-style.json` 의 `stateResolution` 에 있다.
enum BCPTextFieldState {
    case normal, focused, typing, filled, disabled, invalid, valid

    static func resolve(
        enabled: Bool,
        validation: BCPValidation,
        focused: Bool,
        isEmpty: Bool
    ) -> BCPTextFieldState {
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

/// 페이북 디자인 시스템 입력 필드.
///
/// 세 종류(`basic` / `amount` / `multiline`)가 `input/basic/*` 토큰을 그대로 공유한다.
/// Figma 에 전용 토큰이 따로 없어서 종류별로 색이 갈리지 않는다.
///
/// `clear` 버튼은 **포커스된 상태에서 값이 있을 때만**(= Figma `typing`) 나타난다.
/// Figma 의 `filled` 에는 clear 아이콘이 없다는 실측에서 온 규칙이다.
public struct BCPTextField: View {
    private let type: BCPTextFieldType
    private let placeholder: String
    private let helperText: String?
    private let unit: String
    private let maxLength: Int?
    private let validation: BCPValidation
    @Binding private var value: String

    @FocusState private var isFocused: Bool
    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        text: Binding<String>,
        type: BCPTextFieldType = .basic,
        placeholder: String = "",
        helperText: String? = nil,
        unit: String = "원",
        maxLength: Int? = nil,
        validation: BCPValidation = .none
    ) {
        self._value = text
        self.type = type
        self.placeholder = placeholder
        self.helperText = helperText
        self.unit = unit
        self.maxLength = maxLength
        self.validation = validation
    }

    private var state: BCPTextFieldState {
        .resolve(enabled: isEnabled, validation: validation, focused: isFocused, isEmpty: value.isEmpty)
    }

    // MARK: - 토큰

    /// `disabled` 만 표면이 2장이다 — 불투명 surface-1 위에 반투명 surface-2 를 덮는다.
    /// 버튼 pressed 와 같은 오버레이 방식이라 표면을 교체하지 않는다.
    private var surfaces: [Color] {
        let c = theme.component
        switch state {
        case .normal: return [c.inputBasicNormalSurface]
        case .focused: return [c.inputBasicFocusedSurface]
        case .typing: return [c.inputBasicTypingSurface]
        case .filled: return [c.inputBasicFilledSurface]
        case .disabled: return [c.inputBasicDisabledSurface1, c.inputBasicDisabledSurface2]
        case .invalid: return [c.inputBasicInvalidSurface]
        case .valid: return [c.inputBasicValidSurface]
        }
    }

    private var borderColor: Color {
        let c = theme.component
        switch state {
        case .normal: return c.inputBasicNormalBorder
        case .focused: return c.inputBasicFocusedBorder
        case .typing: return c.inputBasicTypingBorder
        case .filled: return c.inputBasicFilledBorder
        case .disabled: return c.inputBasicDisabledBorder
        case .invalid: return c.inputBasicInvalidBorder
        case .valid: return c.inputBasicValidBorder
        }
    }

    /// 포커스 계열만 2pt 다. 토큰(`input/basic/*/border-weight`)에 들어 있는 값이다.
    private var borderWidth: CGFloat {
        switch state {
        case .normal: return BCPDimens.inputBasicNormalBorderWeight
        case .focused: return BCPDimens.inputBasicFocusedBorderWeight
        case .typing: return BCPDimens.inputBasicTypingBorderWeight
        case .filled: return BCPDimens.inputBasicFilledBorderWeight
        case .disabled: return BCPDimens.inputBasicDisabledBorderWeight
        case .invalid: return BCPDimens.inputBasicInvalidBorderWeight
        case .valid: return BCPDimens.inputBasicValidBorderWeight
        }
    }

    private var textColor: Color {
        let c = theme.component
        switch state {
        case .normal: return c.inputBasicNormalText
        case .focused: return c.inputBasicFocusedText
        case .typing: return c.inputBasicTypingText
        case .filled: return c.inputBasicFilledText
        case .disabled: return c.inputBasicDisabledText
        case .invalid: return c.inputBasicInvalidText
        case .valid: return c.inputBasicValidText
        }
    }

    private var helperColor: Color {
        let c = theme.component
        switch state {
        case .normal: return c.inputBasicNormalTextHelp
        case .focused: return c.inputBasicFocusedTextHelp
        case .typing: return c.inputBasicTypingTextHelp
        case .filled: return c.inputBasicFilledTextHelp
        case .disabled: return c.inputBasicDisabledTextHelp
        case .invalid: return c.inputBasicInvalidTextHelp
        case .valid: return c.inputBasicValidTextHelp
        }
    }

    // MARK: - 조각

    private var showsClearButton: Bool { state == .typing }

    @ViewBuilder
    private var field: some View {
        if type == .multiline {
            TextEditor(text: $value)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .bcpTextStyle(BCPTypography.font1Paragraph3_2)
                .foregroundColor(textColor)
                .focused($isFocused)
                .frame(height: 110)
        } else {
            // `prompt:` 를 쓰지 않는다 — SwiftUI 가 prompt 를 자체 스타일로 그려서
            // `.foregroundColor` 가 반영되지 않는다. 그러면 iOS 만 시스템 회색으로 뜨고
            // Compose(BasicText 로 직접 그림)와 색이 갈린다. 같은 방식으로 직접 그린다.
            TextField("", text: $value)
                .textFieldStyle(.plain)
                .bcpTextStyle(BCPTypography.font1Paragraph3_2)
                .foregroundColor(textColor)
                .focused($isFocused)
                .overlay(alignment: .leading) {
                    if value.isEmpty && !placeholder.isEmpty {
                        Text(placeholder)
                            .bcpTextStyle(BCPTypography.font1Paragraph3_2)
                            .foregroundColor(textColor)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    /// 금액에 단위가 따라붙는 배치인가. Figma 에서 값이 비어 있으면 단위가 아예 없고
    /// 간격도 10 이다 (`7736:6362`). 값이 생기면 단위가 붙고 간격이 2 로 좁아진다.
    private var amountInline: Bool { type == .amount && !value.isEmpty }

    // 모서리는 원시 `radius/14` 가 아니라 컴포넌트 토큰 `input/basic/radius` 를 쓴다.
    // 둘 다 값은 14 지만, 입력 필드 모서리만 바뀔 때 원시 토큰을 따라가면 안 된다.
    private var box: some View {
        HStack(spacing: amountInline ? 2 : BCPDimens.spacing10) {
            if amountInline {
                // Figma 는 금액을 HUG, 단위를 FILL 로 둔다 (`7736:6365`: 금액 58 hug / 단위 224 fill).
                // 단위가 남는 폭을 흡수하므로 "원" 은 금액 **바로 옆**에 붙는다.
                // 필드를 FILL 로 두면 단위가 오른쪽 끝으로 밀려나 디자인과 어긋난다.
                field.fixedSize(horizontal: true, vertical: false)
                Text(unit)
                    .bcpTextStyle(BCPTypography.font1Paragraph3_2)
                    .foregroundColor(textColor)
                    .fixedSize()
                Spacer(minLength: 0)
            } else {
                field
            }
            if showsClearButton {
                Button {
                    value = ""
                } label: {
                    BCPVectorShape(BCPVectorPaths.inputClear)
                        .fill(theme.component.inputBasicTypingTextHelp)
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("지우기")
            }
        }
        .padding(.horizontal, BCPDimens.spacing18)
        .padding(.vertical, BCPDimens.spacing15)
        .frame(height: type == .multiline ? 140 : 56)
        .background(
            ZStack {
                ForEach(Array(surfaces.enumerated()), id: \.offset) { _, color in
                    RoundedRectangle(cornerRadius: BCPDimens.inputBasicRadius, style: .continuous).fill(color)
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: BCPDimens.inputBasicRadius, style: .continuous)
                .strokeBorder(borderColor, lineWidth: borderWidth)
        )
    }

    /// `multiline` 은 helper 오른쪽에 `{현재}/{최대}` 카운터가 붙는다.
    /// 현재 글자 수만 입력 중일 때 본문 색으로 바뀐다 (Figma 실측).
    @ViewBuilder
    private var infoRow: some View {
        let counter = type == .multiline ? maxLength : nil
        if helperText != nil || counter != nil {
            HStack(spacing: 8) {
                if let helperText {
                    Text(helperText)
                        .bcpTextStyle(BCPTypography.font1Paragraph6_2)
                        .foregroundColor(helperColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Spacer(minLength: 0)
                }
                if let counter {
                    HStack(spacing: 1) {
                        Text("\(value.count)")
                            .foregroundColor(state == .typing ? textColor : helperColor)
                        Text("/").foregroundColor(helperColor)
                        Text("\(counter)").foregroundColor(helperColor)
                    }
                    .bcpTextStyle(BCPTypography.font1Paragraph6_2)
                }
            }
            .padding(.horizontal, BCPDimens.spacing4)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: BCPDimens.spacing10) {
            box
            infoRow
        }
        .contentShape(Rectangle())
        .onTapGesture { if isEnabled { isFocused = true } }
    }
}
