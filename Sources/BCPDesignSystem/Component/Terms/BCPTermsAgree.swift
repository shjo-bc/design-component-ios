import SwiftUI

/// 전체 동의 상자 크기. Figma `terms_agree` · `terms_agree_accordion` 세트의 `size` 축.
public enum BCPTermsAgreeSize: Sendable {
    case large, small

    /// large 는 `paragraph-2-bold`(18/26). small 은 Figma 에 토큰 없이 Pretendard Bold 16/24 로
    /// 박혀 있어 값이 같은 `font-1/paragraph/4-1` 로 읽는다.
    var textStyle: BCPTextStyle {
        self == .large ? BCPTypography.font1Paragraph2_1 : BCPTypography.font1Paragraph4_1
    }
    /// 위아래 여백. 높이 = 여백×2 + line-height → large 70 · small 56.
    var verticalPadding: CGFloat {
        self == .large ? BCPDimens.spacing22 : BCPDimens.spacing16
    }
}

/// 전체 동의 상자의 공용 코어. `BCPTermsAgree` 와 `BCPTermsAgreeAccordion` 이 쓴다.
///
/// 테두리 1pt 가 선택 여부를 말한다 — 미선택 `terms/line-normal`, 선택 `terms/line-selected`.
/// 바탕은 `terms/sarface`(Figma 토큰 이름의 오타 그대로), 모서리 `terms/radius`(16).
struct BCPTermsAgreeBox<Trailing: View>: View {
    let title: String
    let selected: Bool
    let size: BCPTermsAgreeSize
    let trailingPadding: CGFloat
    let onChange: ((Bool) -> Void)?
    @ViewBuilder let trailing: () -> Trailing

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let c = theme.component
        HStack(spacing: BCPDimens.spacing12) {
            // 체크박스와 제목을 한 덩어리로 묶는다 — 어느 쪽을 눌러도 동의가 바뀐다.
            HStack(spacing: BCPDimens.spacing12) {
                BCPCheckbox(checked: selected) { onChange?($0) }
                Text(title)
                    .bcpTextStyle(size.textStyle)
                    .foregroundColor(theme.semantic.colorPoint6)
                    // Figma: 미선택 텍스트 opacity 60%.
                    .opacity(selected ? 1 : 0.6)
                    .bcpLineHeightFloor(size.textStyle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .onTapGesture { if isEnabled { onChange?(!selected) } }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
            .accessibilityValue(selected ? "선택됨" : "선택 안 함")

            trailing()
        }
        .padding(.leading, BCPDimens.spacing14)
        .padding(.trailing, trailingPadding)
        .padding(.vertical, size.verticalPadding)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: BCPDimens.termsRadius, style: .continuous)
                .fill(c.termsSarface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BCPDimens.termsRadius, style: .continuous)
                .strokeBorder(selected ? c.termsLineSelected : c.termsLineNormal, lineWidth: 1)
        )
    }
}

/// 페이북 디자인 시스템 약관 전체 동의 상자. Figma `terms_agree` (`2820:3466`).
///
/// ```swift
/// BCPTermsAgree("페이북 약관 모두 동의", selected: agreedAll, size: .large) { agreedAll = $0 }
/// ```
///
/// - 문구는 호출부가 넘긴다. "페이북 약관 모두 동의" 는 Figma 예시 문구일 뿐 화면마다 다르다.
/// - Figma `mode` 축(light/dark)은 옮기지 않았다 — 두 변형이 부르는 토큰이 같고 테마가 모드를 정한다.
/// - Figma 인스턴스 프로퍼티 `show badge` 는 모든 variant 에서 숨겨져 있어 위치를 알 수 없다.
///   디자이너가 켜진 예시를 주면 그때 옮긴다.
public struct BCPTermsAgree: View {
    private let title: String
    private let selected: Bool
    private let size: BCPTermsAgreeSize
    private let onChange: ((Bool) -> Void)?

    public init(
        _ title: String,
        selected: Bool,
        size: BCPTermsAgreeSize = .large,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.selected = selected
        self.size = size
        self.onChange = onChange
    }

    public var body: some View {
        BCPTermsAgreeBox(
            title: title,
            selected: selected,
            size: size,
            trailingPadding: BCPDimens.spacing16,
            onChange: onChange
        ) { EmptyView() }
    }
}

/// 펼침 화살표가 붙은 전체 동의 상자. Figma `terms_agree_accordion` (`14330:4993`).
///
/// ```swift
/// BCPTermsAgreeAccordion("페이북 약관 모두 동의", selected: agreedAll, isExpanded: open,
///                        onChange: { agreedAll = $0 }, onToggleExpanded: { open.toggle() })
/// ```
///
/// 화살표는 **동의와 별개의 버튼**이다 — 누르면 `onToggleExpanded` 만 불린다. 아래 약관 목록을
/// 펼치고 접는 것은 호출부가 한다.
///
/// Figma 축 `arrow open` 과의 대응: `arrow open=true` 는 **아래 화살표**(접힌 상태, 누르면 열림),
/// `arrow open=false` 는 위 화살표(펼친 상태). 코드에서는 상태 이름이 더 읽기 쉬워
/// `isExpanded` 로 뒤집어 받는다 — `isExpanded == false` ↔ `arrow open=true`.
public struct BCPTermsAgreeAccordion: View {
    private let title: String
    private let selected: Bool
    private let isExpanded: Bool
    private let size: BCPTermsAgreeSize
    private let onChange: ((Bool) -> Void)?
    private let onToggleExpanded: (() -> Void)?

    @Environment(\.bcpTheme) private var theme

    public init(
        _ title: String,
        selected: Bool,
        isExpanded: Bool,
        size: BCPTermsAgreeSize = .large,
        onChange: ((Bool) -> Void)? = nil,
        onToggleExpanded: (() -> Void)? = nil
    ) {
        self.title = title
        self.selected = selected
        self.isExpanded = isExpanded
        self.size = size
        self.onChange = onChange
        self.onToggleExpanded = onToggleExpanded
    }

    public var body: some View {
        BCPTermsAgreeBox(
            title: title,
            selected: selected,
            size: size,
            trailingPadding: BCPDimens.spacing20,
            onChange: onChange
        ) {
            Button(action: { onToggleExpanded?() }) {
                BCPTermsChevron(direction: isExpanded ? .up : .down,
                                color: theme.semantic.colorPoint6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isExpanded ? "약관 목록 접기" : "약관 목록 펼치기")
        }
    }
}

#if DEBUG
struct BCPTermsAgree_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var agreed = false
        @State private var expanded = false

        var body: some View {
            VStack(spacing: 16) {
                BCPTermsAgree("페이북 약관 모두 동의", selected: agreed) { agreed = $0 }
                BCPTermsAgree("페이북 약관 모두 동의", selected: agreed, size: .small) { agreed = $0 }
                BCPTermsAgreeAccordion("페이북 약관 모두 동의", selected: agreed, isExpanded: expanded,
                                       onChange: { agreed = $0 }, onToggleExpanded: { expanded.toggle() })
                BCPTermsAgreeAccordion("페이북 약관 모두 동의", selected: agreed, isExpanded: expanded,
                                       size: .small,
                                       onChange: { agreed = $0 }, onToggleExpanded: { expanded.toggle() })
                Text("눌러서 전환 · 화살표는 펼침만 바꾼다").font(.caption)
            }
            .frame(width: 320)
        }
    }

    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            Demo()
                .padding()
                .bcpTheme()
                .preferredColorScheme(scheme)
                .previewLayout(.sizeThatFits)
                .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
