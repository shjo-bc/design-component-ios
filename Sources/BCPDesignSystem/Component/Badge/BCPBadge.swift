import SwiftUI

/// 배지 색 역할. Figma Components 컬렉션의 `badge/1` ~ `badge/11` (surface + text 한 쌍).
///
/// 배지 4종(statement · homecard · terms · small)이 모두 이 11개 팔레트 안에서 색을 고른다.
/// 각 컴포넌트의 `type` 은 업무 의미(우리·법인·ISP …)이고, 여기서 색 역할로 번역된다.
enum BCPBadgePalette: Sendable {
    case badge1, badge2, badge3, badge4, badge5, badge6, badge7, badge8, badge9, badge10, badge11

    func surface(_ c: BCPComponentColors) -> Color {
        switch self {
        case .badge1: return c.badge1Surface
        case .badge2: return c.badge2Surface
        case .badge3: return c.badge3Surface
        case .badge4: return c.badge4Surface
        case .badge5: return c.badge5Surface
        case .badge6: return c.badge6Surface
        case .badge7: return c.badge7Surface
        case .badge8: return c.badge8Surface
        case .badge9: return c.badge9Surface
        case .badge10: return c.badge10Surface
        case .badge11: return c.badge11Surface
        }
    }

    func text(_ c: BCPComponentColors) -> Color {
        switch self {
        case .badge1: return c.badge1Text
        case .badge2: return c.badge2Text
        case .badge3: return c.badge3Text
        case .badge4: return c.badge4Text
        case .badge5: return c.badge5Text
        case .badge6: return c.badge6Text
        case .badge7: return c.badge7Text
        case .badge8: return c.badge8Text
        case .badge9: return c.badge9Text
        case .badge10: return c.badge10Text
        case .badge11: return c.badge11Text
        }
    }
}

/// 배지 공용 코어. 텍스트 하나를 색 있는 둥근 상자에 담는다.
///
/// 공개 API 가 아니다 — `BCPStatementBadge` · `BCPHomeCardBadge` · `BCPTermsBadge` · `BCPSmallBadge` 가
/// Figma 세트별 규격(패딩·radius·타이포·색)을 정해 이 뷰에 넘긴다. Input 계열에서 `BCPTextField` 가
/// 코어 역할을 하는 것과 같은 구조다.
///
/// 상호작용이 없고 텍스트만 있으므로 접근성은 SwiftUI `Text` 가 그대로 읽어 준다.
struct BCPBadge: View {
    let text: String
    let surface: Color
    let foreground: Color
    let textStyle: BCPTextStyle
    let horizontalPadding: CGFloat
    let topPadding: CGFloat
    let bottomPadding: CGFloat
    /// Figma 높이 = 세로 패딩 + **line-height**. SwiftUI 의 한 줄 `Text` 높이는 line-height 가
    /// 아니라 서체의 실제 행높이(ascender + descender)라 패딩만으로는 디자인 높이가 나오지 않는다 —
    /// 12pt Pretendard 면 20 이 아니라 약 14 다. `BCPButton` 이 높이를 따로 갖는 것과 같은 이유다.
    ///
    /// 고정이 아니라 `minHeight` 로 둔다. 기본 글자 크기에서는 디자인과 같고, 문구가 길어지거나
    /// 서체가 폴백돼 커져도 잘리지 않고 늘어난다.
    let minHeight: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        Text(text)
            .bcpTextStyle(textStyle)
            .foregroundColor(foreground)
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
            .frame(minHeight: minHeight)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(surface)
            )
    }
}
