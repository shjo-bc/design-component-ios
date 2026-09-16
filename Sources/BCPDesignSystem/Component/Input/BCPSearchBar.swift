import SwiftUI

/// 검색바 스타일. Figma `searchbar-1` / `searchbar-2` 세트에 대응한다.
///
/// 두 세트는 표면 색이 다르고, 입력 글자는 서로 상대 번호의 토큰을 물고 있다 (Figma 실측).
public enum BCPSearchBarStyle: Sendable {
    /// `searchbar-1` — 불투명 회색 표면.
    case style1
    /// `searchbar-2` — 반투명 표면. 사진이나 색 위에 얹을 때 쓴다.
    case style2
}

/// 페이북 디자인 시스템 검색바.
///
/// box / line 과 달리 상태가 4개뿐이다(`normal` / `focused` / `typing` / `filled`).
/// Figma 에 `disabled` · `invalid` · `valid` variant 가 없어서 검증 상태를 받지 않는다.
public struct BCPSearchBar: View {
    private let style: BCPSearchBarStyle
    private let placeholder: String
    private let cancelTitle: String?
    private let onCancel: (() -> Void)?
    @Binding private var value: String

    // 색 계산에는 쓰지 않는다 — Figma 실측상 searchbar 는 4개 state 중 어느 것에서도
    // surface·hint 색이 같고, 입력 글자 색은 값 유무로만 갈린다. 키보드 포커스를 잡기
    // 위해서만 필요하다.
    @FocusState private var isFocused: Bool
    @Environment(\.bcpTheme) private var theme

    /// `onCancel` 을 주면 오른쪽에 취소 버튼이 붙는다 (Figma `show cancel=on`).
    public init(
        text: Binding<String>,
        style: BCPSearchBarStyle = .style1,
        placeholder: String = "",
        cancelTitle: String = "취소",
        onCancel: (() -> Void)? = nil
    ) {
        self._value = text
        self.style = style
        self.placeholder = placeholder
        self.cancelTitle = onCancel == nil ? nil : cancelTitle
        self.onCancel = onCancel
    }

    // MARK: - 토큰

    private var surface: Color {
        switch style {
        case .style1: return theme.component.inputSearch1Surface
        case .style2: return theme.component.inputSearch2Surface
        }
    }

    private var hintColor: Color {
        switch style {
        case .style1: return theme.component.inputSearch1TextHint
        case .style2: return theme.component.inputSearch2TextHint
        }
    }

    /// 입력 글자만 **상대 번호** 토큰을 쓴다 — Figma 가 `searchbar-1` 에
    /// `search-2/text-normal` 을, `searchbar-2` 에 `search-1/text-normal` 을 물려 뒀다.
    ///
    /// 두 토큰은 지금 같은 값이라 렌더는 어느 쪽이든 같지만, 값이 아니라 **바인딩된 이름**을
    /// 따른다. 디자이너가 둘을 갈라놓으면 코드를 고치지 않고 따라가야 한다.
    /// 교차가 의도인지 실수인지는 디자이너 확인 사항이다 (docs/naming-contract.md §6).
    private var textColor: Color {
        switch style {
        case .style1: return theme.component.inputSearch2TextNormal
        case .style2: return theme.component.inputSearch1TextNormal
        }
    }

    private var radius: CGFloat {
        switch style {
        case .style1: return BCPDimens.inputSearch1Radius
        case .style2: return BCPDimens.inputSearch2Radius
        }
    }

    public var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: BCPDimens.spacing10) {
                BCPTextField(
                    text: $value,
                    focus: $isFocused,
                    placeholder: placeholder,
                    textColor: textColor,
                    placeholderColor: hintColor
                )
                BCPVectorShape(BCPVectorPaths.searchGlass)
                    .fill(theme.semantic.colorSurface9)
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal, BCPDimens.spacing18)
            .padding(.vertical, BCPDimens.spacing15)
            .frame(height: 56)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(surface))

            if let cancelTitle, let onCancel {
                Button(action: onCancel) {
                    Text(cancelTitle)
                        .bcpTextStyle(BCPTypography.font1Paragraph4_2)
                        .foregroundColor(theme.semantic.colorFontNeutral4)
                }
                .buttonStyle(.plain)
                .padding(.leading, BCPDimens.spacing14)
                .padding(.trailing, BCPDimens.spacing4)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }
}
