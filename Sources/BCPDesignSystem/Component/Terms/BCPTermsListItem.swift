import SwiftUI

/// 약관 목록 항목의 깊이. Figma `terms_list` · `terms_isp_list` 세트의 `type` 축(1depth/2depth/3depth).
///
/// - `depth1` — 약관 묶음 제목. 상자 있는 체크박스(`BCPCheckbox`) + 굵은 글자 + 상세 화살표.
/// - `depth2` — 개별 약관. 상자 없는 체크 표시 + 보통 글자 + (등급 배지) + 상세 화살표.
/// - `depth3` — 약관 안의 세부 선택지(휴대전화·SMS 같은 것). 체크 표시 + 글자만. 여러 개가
///   한 줄에 나란히 놓이므로 `BCPTermsSubItemRow` 안에 넣는다.
public enum BCPTermsDepth: Sendable {
    case depth1, depth2, depth3
}

/// 페이북 디자인 시스템 약관 목록 항목. Figma `terms_list` (`2852:11740`).
///
/// ```swift
/// BCPTermsListItem("페이북 서비스 이용 약관 (필수)", depth: .depth1, selected: all,
///                  onChange: { all = $0 }, onDetail: { showDetail(0) })
/// BCPTermsListItem("[1] 카드 · 금융상품 이용 안내", depth: .depth2, selected: a,
///                  badge: .level2, onChange: { a = $0 }, onDetail: { showDetail(1) })
/// BCPTermsSubItemRow(style: .list) {
///     BCPTermsListItem("휴대전화", depth: .depth3, selected: sms) { sms = $0 }
///     BCPTermsListItem("모바일 메세지(SMS 등)", depth: .depth3, selected: push) { push = $0 }
/// }
/// ```
///
/// 체크가 없는 약관(안내만 하고 동의를 받지 않는 항목)은 `selected` 없이 만든다.
/// 체크와 그 옆 간격이 빠지고 글자가 체크 자리에서 시작한다. 누르면 `onDetail` 만 불린다.
///
/// ```swift
/// BCPTermsListItem("개인정보 처리방침 안내", depth: .depth2, onDetail: { showPolicy() })
/// ```
///
/// - 체크(박스)를 누르면 `onChange`, 글자·화살표를 누르면 `onDetail` 이 불린다.
///   `onDetail` 이 없으면 화살표는 그대로 그려지되 글자 영역은 체크를 토글한다.
/// - `badge` 는 Figma 인스턴스 프로퍼티 `2depht_badge`(Figma 오타 그대로)·`1depth_badge` 다.
///   `1depth_badge` 는 모든 variant 에서 숨겨져 있어 위치는 2depth 와 같다고 보고 화살표 왼쪽에 둔다.
/// - Figma `mode` 축은 옮기지 않았다 — 테마가 정한다.
public struct BCPTermsListItem: View {
    private let title: String
    private let depth: BCPTermsDepth
    /// `nil` 이면 체크가 없는 약관이다.
    private let selected: Bool?
    private let badge: BCPTermsBadgeLevel?
    private let onChange: ((Bool) -> Void)?
    private let onDetail: (() -> Void)?

    @Environment(\.bcpTheme) private var theme

    public init(
        _ title: String,
        depth: BCPTermsDepth,
        selected: Bool,
        badge: BCPTermsBadgeLevel? = nil,
        onChange: ((Bool) -> Void)? = nil,
        onDetail: (() -> Void)? = nil
    ) {
        self.title = title
        self.depth = depth
        self.selected = selected
        self.badge = badge
        self.onChange = onChange
        self.onDetail = onDetail
    }

    /// 체크가 없는 약관. 동의를 받지 않고 내용만 보여 주는 항목에 쓴다.
    public init(
        _ title: String,
        depth: BCPTermsDepth,
        badge: BCPTermsBadgeLevel? = nil,
        onDetail: (() -> Void)? = nil
    ) {
        self.title = title
        self.depth = depth
        self.selected = nil
        self.badge = badge
        self.onChange = nil
        self.onDetail = onDetail
    }

    private var textStyle: BCPTextStyle {
        switch depth {
        case .depth1: return BCPTypography.font1Paragraph4_1  // 16/24 bold
        case .depth2: return BCPTypography.font1Paragraph4_2  // 16/24 regular
        case .depth3: return BCPTypography.font1Paragraph5_2  // 15/22 regular
        }
    }

    private var textColor: Color {
        depth == .depth1 ? theme.semantic.colorFontNeutral2 : theme.semantic.colorFontNeutral4
    }

    public var body: some View {
        switch depth {
        case .depth1, .depth2:
            HStack(spacing: BCPDimens.spacing12) {
                if let selected {
                    BCPTermsRowCheck(depth: depth, selected: selected, onChange: onChange)
                        .accessibilityLabel(title)
                }
                BCPTermsRowContent(
                    title: title, textStyle: textStyle, textColor: textColor,
                    badge: badge, badgeArrowSpacing: BCPDimens.spacing4,
                    selected: selected, onChange: onChange, onDetail: onDetail
                )
            }
            // 체크가 없어도 행 높이는 체크(24)가 있을 때와 같게 둔다 — 섞여 있어도 줄 간격이 흔들리지 않는다.
            .frame(minHeight: 24)
            .padding(.leading, BCPDimens.spacing14)
            .padding(.trailing, BCPDimens.spacing4)
            .padding(.vertical, depth == .depth1 ? BCPDimens.spacing12 : BCPDimens.spacing10)
            .frame(maxWidth: .infinity)
        case .depth3:
            BCPTermsLeaf(title: title, textStyle: textStyle, textColor: textColor,
                         spacing: BCPDimens.spacing6, selected: selected, onChange: onChange)
                .padding(.vertical, BCPDimens.spacing10)
        }
    }
}

/// 3depth 항목을 한 줄에 나란히 놓는 컨테이너. Figma `type=3depth` variant 의 바깥 프레임.
///
/// 들여쓰기와 항목 간격이 세트마다 다르다 — `terms_list` 는 50/8, `terms_isp_list` 는 36/12.
public struct BCPTermsSubItemRow<Content: View>: View {
    public enum Style: Sendable {
        /// `terms_list` — 들여쓰기 50, 간격 8.
        case list
        /// `terms_isp_list` — 들여쓰기 36, 간격 12.
        case isp

        var leadingPadding: CGFloat { self == .list ? 50 : BCPDimens.spacing36 }
        var trailingPadding: CGFloat { self == .list ? BCPDimens.spacing4 : 0 }
        var spacing: CGFloat { self == .list ? BCPDimens.spacing8 : BCPDimens.spacing12 }
    }

    private let style: Style
    private let content: Content

    public init(style: Style, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: style.spacing) {
            content
            Spacer(minLength: 0)
        }
        .padding(.leading, style.leadingPadding)
        .padding(.trailing, style.trailingPadding)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 공용 조각

/// 1depth 는 상자 있는 체크박스, 그 아래는 상자 없는 체크 표시.
struct BCPTermsRowCheck: View {
    let depth: BCPTermsDepth
    let selected: Bool
    let onChange: ((Bool) -> Void)?

    var body: some View {
        if depth == .depth1 {
            BCPCheckbox(checked: selected) { onChange?($0) }
        } else {
            BCPTermsCheckmark(selected: selected, onChange: onChange)
        }
    }
}

/// 글자 + (배지) + 상세 화살표. 누르면 상세로 간다.
struct BCPTermsRowContent: View {
    let title: String
    let textStyle: BCPTextStyle
    let textColor: Color
    let badge: BCPTermsBadgeLevel?
    let badgeArrowSpacing: CGFloat
    /// `nil` 이면 체크가 없는 약관 — 글자를 눌러도 토글할 것이 없다.
    let selected: Bool?
    let onChange: ((Bool) -> Void)?
    let onDetail: (() -> Void)?

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    /// 누르면 무언가 일어나는가. 체크도 상세도 없으면 그냥 글자다.
    private var isActionable: Bool { onDetail != nil || selected != nil }

    var body: some View {
        HStack(spacing: BCPDimens.spacing8) {
            Text(title)
                .bcpTextStyle(textStyle)
                .foregroundColor(textColor)
                .bcpLineHeightFloor(textStyle)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: badgeArrowSpacing) {
                if let badge { BCPTermsBadge(level: badge) }
                // 체크도 상세도 없는 행은 눌러도 아무 일이 없으므로 이동할 것처럼 보이는 화살표를 뺀다.
                if isActionable {
                    BCPTermsChevron(direction: .right, color: theme.semantic.colorSurface7)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEnabled else { return }
            if let onDetail { onDetail() } else if let selected { onChange?(!selected) }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isActionable ? .isButton : [])
        .accessibilityHint(onDetail == nil ? "" : "약관 내용 보기")
    }
}

/// 체크 표시 + 글자만 있는 잎 항목(3depth). 어디를 눌러도 체크가 바뀐다.
struct BCPTermsLeaf: View {
    let title: String
    let textStyle: BCPTextStyle
    let textColor: Color
    let spacing: CGFloat
    /// `nil` 이면 체크 없이 글자만 그린다.
    let selected: Bool?
    let onChange: ((Bool) -> Void)?

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        if let selected {
            HStack(spacing: spacing) {
                BCPTermsCheckmark(selected: selected, onChange: onChange)
                label
            }
            .contentShape(Rectangle())
            .onTapGesture { if isEnabled { onChange?(!selected) } }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(title)
            .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
            .accessibilityValue(selected ? "선택됨" : "선택 안 함")
        } else {
            label.frame(minHeight: 24)
        }
    }

    private var label: some View {
        Text(title)
            .bcpTextStyle(textStyle)
            .foregroundColor(textColor)
            .bcpLineHeightFloor(textStyle)
            .fixedSize(horizontal: true, vertical: false)
    }
}

#if DEBUG
struct BCPTermsListItem_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var all = false
        @State private var a = true
        @State private var b = false
        @State private var phone = true
        @State private var sms = false

        var body: some View {
            VStack(spacing: 0) {
                BCPTermsListItem("페이북 서비스 이용 약관 (필수)", depth: .depth1, selected: all,
                                 onChange: { all = $0 }, onDetail: {})
                BCPTermsListItem("[1] 카드 · 금융상품 이용 안내", depth: .depth2, selected: a,
                                 badge: .level2, onChange: { a = $0 }, onDetail: {})
                BCPTermsListItem("[2] 개인정보 수집 · 이용 동의", depth: .depth2, selected: b,
                                 onChange: { b = $0 }, onDetail: {})
                // 체크 없는 약관 — 안내만 한다
                BCPTermsListItem("개인정보 처리방침 안내", depth: .depth2, onDetail: {})
                BCPTermsSubItemRow(style: .list) {
                    BCPTermsListItem("휴대전화", depth: .depth3, selected: phone) { phone = $0 }
                    BCPTermsListItem("모바일 메세지(SMS 등)", depth: .depth3, selected: sms) { sms = $0 }
                }
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
