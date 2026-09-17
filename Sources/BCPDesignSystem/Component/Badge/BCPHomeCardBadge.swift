import SwiftUI

/// 홈 카드 배지의 의미 유형. Figma `badge-homecard` 세트의 `type` 축 8종.
///
/// 타입은 색 역할만 결정한다. "잔액" · "D-8" 처럼 데이터가 들어가는 문구라 텍스트는 호출부가 넘긴다.
///
/// | type | Figma 기본 문구 | 색 |
/// |---|---|---|
/// | price / count / openApp | 잔액 / D-8 / 오픈앱 | badge/1 (violet) |
/// | woori / company | 우리 / 법인공용 | badge/10 (blue) |
/// | isp | ISP | badge/5 (yellow) |
/// | dday / error | D-day / 미등록 | badge/3 (red) |
public enum BCPHomeCardBadgeType: Sendable {
    case price, count, openApp
    case woori, company
    case isp
    case dday, error

    var palette: BCPBadgePalette {
        switch self {
        case .price, .count, .openApp: return .badge1
        case .woori, .company: return .badge10
        case .isp: return .badge5
        case .dday, .error: return .badge3
        }
    }
}

/// 페이북 디자인 시스템 홈 카드 배지. 높이 20, radius 4.
///
/// ```swift
/// BCPHomeCardBadge("D-8", type: .count)
/// ```
///
/// ⚠ Figma 에서 isp · dday · error 는 line-height 14 + 상하 3, 나머지는 line-height 12 + 상하 4 로
/// 그려져 있다. 최종 높이는 둘 다 20 으로 같아서 `font-1/badge/medium-1`(11/12) 토큰 하나로 통일했다.
public struct BCPHomeCardBadge: View {
    private let text: String
    private let type: BCPHomeCardBadgeType

    @Environment(\.bcpTheme) private var theme

    public init(_ text: String, type: BCPHomeCardBadgeType) {
        self.text = text
        self.type = type
    }

    public var body: some View {
        let c = theme.component
        BCPBadge(
            text: text,
            surface: type.palette.surface(c),
            foreground: type.palette.text(c),
            textStyle: BCPTypography.font1BadgeMedium1,
            // 좌우 5 — spacing 토큰에 5 가 없다 (Figma 실측값).
            horizontalPadding: 5,
            topPadding: BCPDimens.spacing4,
            bottomPadding: BCPDimens.spacing4,
            // 4 + line-height 12 + 4
            minHeight: 20,
            cornerRadius: BCPDimens.radius4
        )
    }
}

#if DEBUG
struct BCPHomeCardBadge_Previews: PreviewProvider {
    private static let samples: [(String, BCPHomeCardBadgeType)] = [
        ("잔액", .price), ("우리", .woori), ("법인공용", .company), ("ISP", .isp),
        ("D-8", .count), ("D-day", .dday), ("미등록", .error), ("오픈앱", .openApp),
    ]

    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            HStack(spacing: 8) {
                ForEach(samples, id: \.0) { text, type in
                    BCPHomeCardBadge(text, type: type)
                }
            }
            .padding()
            .bcpTheme()
            .preferredColorScheme(scheme)
            .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
