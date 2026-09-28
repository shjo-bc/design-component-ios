import SwiftUI

/// ISP(인터넷 안전결제) 약관 목록 항목. Figma `terms_isp_list` (`50165:528`).
///
/// `BCPTermsListItem` 과 구조는 같고 **더 촘촘하다** — 위아래 여백 6, 글자 한 단계 작음(15/14pt),
/// 좌우 여백 없음. 배지 자리가 없다.
///
/// 체크가 없는 약관은 `selected` 없이 만든다 (`BCPTermsListItem` 과 같은 규칙).
///
/// ```swift
/// BCPTermsISPListItem("필수약관 전체동의", depth: .depth1, selected: all,
///                     onChange: { all = $0 }, onDetail: { showDetail() })
/// BCPTermsISPListItem("서비스 이용 동의 (필수)", depth: .depth2, selected: a,
///                     onChange: { a = $0 }, onDetail: { showDetail() })
/// BCPTermsSubItemRow(style: .isp) {
///     BCPTermsISPListItem("모바일 메세지(SMS 등)", depth: .depth3, selected: sms) { sms = $0 }
/// }
/// ```
public struct BCPTermsISPListItem: View {
    private let title: String
    private let depth: BCPTermsDepth
    /// `nil` 이면 체크가 없는 약관이다.
    private let selected: Bool?
    private let onChange: ((Bool) -> Void)?
    private let onDetail: (() -> Void)?

    @Environment(\.bcpTheme) private var theme

    public init(
        _ title: String,
        depth: BCPTermsDepth,
        selected: Bool,
        onChange: ((Bool) -> Void)? = nil,
        onDetail: (() -> Void)? = nil
    ) {
        self.title = title
        self.depth = depth
        self.selected = selected
        self.onChange = onChange
        self.onDetail = onDetail
    }

    /// 체크가 없는 약관. 동의를 받지 않고 내용만 보여 주는 항목에 쓴다.
    public init(
        _ title: String,
        depth: BCPTermsDepth,
        onDetail: (() -> Void)? = nil
    ) {
        self.title = title
        self.depth = depth
        self.selected = nil
        self.onChange = nil
        self.onDetail = onDetail
    }

    private var textStyle: BCPTextStyle {
        depth == .depth1 ? BCPTypography.font1Paragraph5_1   // 15/22 bold
                         : BCPTypography.font1Paragraph6_2   // 14/20 regular
    }

    private var textColor: Color {
        depth == .depth1 ? theme.semantic.colorFontNeutral2 : theme.semantic.colorFontNeutral4
    }

    public var body: some View {
        Group {
            switch depth {
            case .depth1, .depth2:
                HStack(spacing: BCPDimens.spacing12) {
                    if let selected {
                        BCPTermsRowCheck(depth: depth, selected: selected, onChange: onChange)
                            .accessibilityLabel(title)
                    }
                    BCPTermsRowContent(
                        title: title, textStyle: textStyle, textColor: textColor,
                        badge: nil, badgeArrowSpacing: 0,
                        selected: selected, onChange: onChange, onDetail: onDetail
                    )
                }
                // 체크가 없어도 행 높이 36 을 지킨다.
                .frame(minHeight: 24)
                .frame(maxWidth: .infinity)
            case .depth3:
                BCPTermsLeaf(title: title, textStyle: textStyle, textColor: textColor,
                             spacing: BCPDimens.spacing12, selected: selected, onChange: onChange)
            }
        }
        // 높이 36 = 6 + 체크 24 + 6.
        .padding(.vertical, BCPDimens.spacing6)
    }
}

#if DEBUG
struct BCPTermsISPListItem_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var all = false
        @State private var a = true
        @State private var b = false
        @State private var sms1 = true
        @State private var sms2 = false

        var body: some View {
            VStack(spacing: 0) {
                BCPTermsISPListItem("필수약관 전체동의", depth: .depth1, selected: all,
                                    onChange: { all = $0 }, onDetail: {})
                BCPTermsISPListItem("서비스 이용 동의 (필수)", depth: .depth2, selected: a,
                                    onChange: { a = $0 }, onDetail: {})
                BCPTermsISPListItem("개인정보 제3자 제공 동의 (필수)", depth: .depth2, selected: b,
                                    onChange: { b = $0 }, onDetail: {})
                // 체크 없는 약관 — 안내만 한다
                BCPTermsISPListItem("ISP 서비스 안내", depth: .depth2, onDetail: {})
                BCPTermsSubItemRow(style: .isp) {
                    BCPTermsISPListItem("휴대전화", depth: .depth3, selected: sms1) { sms1 = $0 }
                    BCPTermsISPListItem("모바일 메세지(SMS 등)", depth: .depth3, selected: sms2) { sms2 = $0 }
                }
            }
            .frame(width: 380)
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
