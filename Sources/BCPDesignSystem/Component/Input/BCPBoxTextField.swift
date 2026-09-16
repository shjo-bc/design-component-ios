import SwiftUI

/// box 계열 입력 필드의 종류. Figma `box-input-*` 세트들에 대응한다.
public enum BCPBoxTextFieldType: Sendable {
    /// `box-input-basic` type=basic — 단일 행 기본 입력.
    case basic
    /// `box-input-basic` type=basic-amount — 값 뒤에 단위(`원`)를 붙인다.
    case amount
    /// `box-input-basic` type=multiline — 높이가 고정되고 글자 수 카운터가 붙는다.
    case multiline
    /// `box-input-dropdown` — 직접 입력하지 않고 목록에서 고른다. 오른쪽에 아래 방향 chevron 이 붙는다.
    case dropdown
    /// `box-input-date` — 날짜를 고른다. 오른쪽에 달력 아이콘이 붙는다.
    case date
    /// `box-input-amount-large` — 72pt 높이에 22/400 으로 크게 쓰는 금액 입력.
    case amountLarge
    /// `box-input-card-num` — 카드번호. 4자리마다 끊어 보여준다.
    case cardNumber
    /// `box-input-num` — 숫자 입력. 오른쪽에 확인 버튼이 붙을 수 있다.
    case number

    /// 사용자가 키보드로 고치는 종류인가. `dropdown` / `date` 는 값을 **표시만** 한다.
    var isEditable: Bool { self != .dropdown && self != .date }

    /// 오른쪽에 고정으로 붙는 아이콘. 입력 종류에는 없다(대신 값이 있을 때 clear 가 붙는다).
    /// Figma 가 72pt 박스에 24/20 패딩과 22/400 글자를 쓰는 종류인가.
    /// 기본 계열은 56pt 박스에 18/15 패딩, 17/400 이다.
    var isLarge: Bool {
        switch self {
        case .amountLarge, .cardNumber, .number: return true
        default: return false
        }
    }

    var trailingIcon: BCPVectorSource? {
        switch self {
        case .dropdown: return BCPVectorPaths.chevronDown
        case .date: return BCPVectorPaths.calendar
        default: return nil
        }
    }
}

/// 페이북 디자인 시스템 box 입력 필드.
///
/// 배경 surface + 테두리 + 14pt 모서리를 갖는 계열이고, `input/basic/*` 토큰을 쓴다.
/// 종류가 달라도 색이 갈리지 않는다 — Figma 에 종류별 전용 토큰이 없다.
///
/// `clear` 버튼은 **포커스된 상태에서 값이 있을 때만**(= Figma `typing`) 나타난다.
/// Figma 의 `filled` 에는 clear 아이콘이 없다는 실측에서 온 규칙이다.
public struct BCPBoxTextField: View {
    private let type: BCPBoxTextFieldType
    private let placeholder: String
    private let helperText: String?
    private let unit: String
    private let maxLength: Int?
    private let validation: BCPValidation
    private let onTap: (() -> Void)?
    private let buttonTitle: String?
    private let onButtonTap: (() -> Void)?
    @Binding private var value: String

    @FocusState private var isFocused: Bool
    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        text: Binding<String>,
        type: BCPBoxTextFieldType = .basic,
        placeholder: String = "",
        helperText: String? = nil,
        unit: String = "원",
        maxLength: Int? = nil,
        validation: BCPValidation = .none,
        onTap: (() -> Void)? = nil,
        buttonTitle: String? = nil,
        onButtonTap: (() -> Void)? = nil
    ) {
        self._value = text
        self.type = type
        self.placeholder = placeholder
        self.helperText = helperText
        self.unit = unit
        self.maxLength = maxLength
        self.validation = validation
        self.onTap = onTap
        self.buttonTitle = buttonTitle
        self.onButtonTap = onButtonTap
    }

    private var state: BCPInputState {
        // dropdown / date 는 키보드 포커스를 잡지 않으므로 focused·typing 이 나오지 않는다.
        // Figma 에도 그 variant 가 없다 (dropdown 의 focused 는 목록이 열린 상태다).
        .resolve(
            enabled: isEnabled,
            validation: validation,
            focused: type.isEditable && isFocused,
            isEmpty: value.isEmpty
        )
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

    /// 두께 계산용 상태. `validation` 을 빼고 포커스만 반영한다.
    ///
    /// `focused` 와 `typing` 을 각각 그대로 남기는 것이 중요하다 — 두 토큰은 지금 같은 값
    /// (`border/2`)을 물고 있지만 Figma 에 **별도 변수로** 존재한다. 디자이너가 둘을 갈라놓으면
    /// 코드를 고치지 않고 따라가야 한다. 포커스 여부만 보고 한쪽으로 고정하면 그 연결이 끊긴다.
    ///
    /// `validation` 을 빼도 두께는 어긋나지 않는다 — invalid·valid 의 border-weight 가
    /// normal·filled 와 같은 1pt 라, 포커스가 없을 때는 어느 쪽으로 계산해도 결과가 같다.
    private var weightState: BCPInputState {
        .resolve(
            enabled: isEnabled,
            validation: .none,
            focused: type.isEditable && isFocused,
            isEmpty: value.isEmpty
        )
    }

    /// 포커스 계열만 2pt 다. 토큰(`input/basic/*/border-weight`)에 들어 있는 값이다.
    ///
    /// **색과 두께를 분리한다.** `validation` 이 켜지면 `state` 가 `invalid`/`valid` 로 고정돼
    /// 색은 오류색을 유지하는데, 그때 두께까지 1pt 로 묶이면 포커스 피드백이 통째로 사라진다
    /// (오류난 필드를 고치려고 탭해도 아무 반응이 없다). Figma 에 invalid+focused 교차
    /// variant 가 없어 코드가 정하는 자리이므로, 색은 validation 이 갖고 두께는 포커스가 갖는다.
    /// 두 값 모두 Figma 에 있는 것을 조합할 뿐이다.
    private var borderWidth: CGFloat {
        switch weightState {
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

    /// Figma 가 종류마다 패딩을 달리 준다 — 일괄값으로 덮으면 실측과 어긋난다.
    /// `date` 는 오른쪽에 아이콘이 붙어 14 로 좁고, `number` 는 버튼이 들어가면 12 까지 줄어든다.
    private var boxPadding: (leading: CGFloat, trailing: CGFloat, vertical: CGFloat) {
        switch type {
        case .date:
            return (BCPDimens.spacing18, BCPDimens.spacing14, BCPDimens.spacing15)
        case .number where buttonTitle != nil:
            return (BCPDimens.spacing24, BCPDimens.spacing12, BCPDimens.spacing12)
        default:
            return type.isLarge
                ? (BCPDimens.spacing24, BCPDimens.spacing24, BCPDimens.spacing20)
                : (BCPDimens.spacing18, BCPDimens.spacing18, BCPDimens.spacing15)
        }
    }

    /// `date` 만 아이콘과의 간격이 8 이다 (나머지는 10).
    private var contentSpacing: CGFloat {
        if amountInline { return 2 }
        return type == .date ? BCPDimens.spacing8 : BCPDimens.spacing10
    }

    private var boxHeight: CGFloat {
        if type == .multiline { return 140 }
        return type.isLarge ? 72 : 56
    }

    /// 큰 계열은 22/400(`font1Subheading2_2`), 기본 계열은 17/400(`font1Paragraph3_2`) 이다.
    private var inputTextStyle: BCPTextStyle {
        type.isLarge ? BCPTypography.font1Subheading2_2 : BCPTypography.font1Paragraph3_2
    }

    /// 고정 아이콘 색은 컴포넌트 토큰이 아니라 semantic 표면 토큰에 걸려 있다 (Figma 실측).
    private var trailingIconColor: Color {
        state == .disabled ? theme.semantic.colorSurface7 : theme.semantic.colorSurface17
    }

    /// 카드번호는 4자리마다 끊어 보여준다.
    ///
    /// Figma 는 네 덩어리를 각각 TEXT 로 두고 사이에 6×1 사각형을 그렸지만, 그 구조는
    /// 입력 커서를 한 줄로 이어 옮길 수 없다. 값 자체를 `1234-5678-...` 로 포맷해
    /// 한 필드로 다룬다 — 보이는 결과는 같고 편집만 자연스러워진다.
    static func formatCardNumber(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(16)
        return stride(from: 0, to: digits.count, by: 4).map { offset -> String in
            let start = digits.index(digits.startIndex, offsetBy: offset)
            let end = digits.index(start, offsetBy: min(4, digits.count - offset))
            return String(digits[start..<end])
        }.joined(separator: "-")
    }

    /// `cardNumber` 만 표시값과 저장값이 같은 포맷을 쓰도록 한 번 걸러 준다.
    private var editingBinding: Binding<String> {
        guard type == .cardNumber else { return $value }
        return Binding(
            get: { Self.formatCardNumber(value) },
            set: { value = Self.formatCardNumber($0) }
        )
    }

    // MARK: - 조각

    private var showsClearButton: Bool { type.isEditable && state == .typing }

    @ViewBuilder
    private var field: some View {
        if !type.isEditable {
            Text(value.isEmpty ? placeholder : value)
                .bcpTextStyle(inputTextStyle)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            BCPTextField(
                text: editingBinding,
                focus: $isFocused,
                placeholder: placeholder,
                textStyle: inputTextStyle,
                textColor: textColor,
                placeholderColor: textColor,
                multilineHeight: type == .multiline ? 110 : nil
            )
        }
    }

    /// 금액에 단위가 따라붙는 배치인가. Figma 에서 값이 비어 있으면 단위가 아예 없고
    /// 간격도 10 이다 (`7736:6362`). 값이 생기면 단위가 붙고 간격이 2 로 좁아진다.
    private var amountInline: Bool { (type == .amount || type == .amountLarge) && !value.isEmpty }

    /// 단위는 금액보다 한 단계 작다 — 22/400 옆에 20/400 (`font1Subheading3_2`).
    private var unitTextStyle: BCPTextStyle {
        type == .amountLarge ? BCPTypography.font1Subheading3_2 : BCPTypography.font1Paragraph3_2
    }

    // 모서리는 원시 `radius/14` 가 아니라 컴포넌트 토큰 `input/basic/radius` 를 쓴다.
    // 둘 다 값은 14 지만, 입력 필드 모서리만 바뀔 때 원시 토큰을 따라가면 안 된다.
    private var box: some View {
        HStack(spacing: contentSpacing) {
            if amountInline {
                // Figma 는 금액을 HUG, 단위를 FILL 로 둔다 (`7736:6365`: 금액 58 hug / 단위 224 fill).
                // 단위가 남는 폭을 흡수하므로 "원" 은 금액 **바로 옆**에 붙는다.
                // 필드를 FILL 로 두면 단위가 오른쪽 끝으로 밀려나 디자인과 어긋난다.
                field.fixedSize(horizontal: true, vertical: false)
                Text(unit)
                    .bcpTextStyle(unitTextStyle)
                    .foregroundColor(textColor)
                    .fixedSize()
                Spacer(minLength: 0)
            } else {
                field
            }
            if showsClearButton {
                BCPInputClearButton(color: theme.component.inputBasicTypingTextHelp) { value = "" }
            }
            if type == .number, let buttonTitle {
                BCPButton(buttonTitle, type: .primary, size: .large, width: .hug) { onButtonTap?() }
            }
            if let icon = type.trailingIcon {
                BCPVectorShape(icon)
                    .fill(trailingIconColor)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.leading, boxPadding.leading)
        .padding(.trailing, boxPadding.trailing)
        .padding(.vertical, boxPadding.vertical)
        .frame(height: boxHeight)
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
        .onTapGesture {
            guard isEnabled else { return }
            if type.isEditable { isFocused = true }
            onTap?()
        }
    }
}
