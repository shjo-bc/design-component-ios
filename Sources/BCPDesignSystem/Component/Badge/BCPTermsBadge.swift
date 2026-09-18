import SwiftUI

/// 약관 위험도 등급. Figma `badge-terms` 세트의 `Property 1` 축 1~5.
///
/// 등급 명칭은 디자인 시스템이 정한 고정 문구라 컴포넌트가 직접 갖는다.
public enum BCPTermsBadgeLevel: Int, Sendable, CaseIterable {
    case level1 = 1, level2, level3, level4, level5

    /// Figma 에 박힌 등급 문구.
    public var title: String {
        switch self {
        case .level1: return "안심"
        case .level2: return "다소안심"
        case .level3: return "보통"
        case .level4: return "신중"
        case .level5: return "주의"
        }
    }

    var palette: BCPBadgePalette {
        switch self {
        case .level1: return .badge10  // blue
        case .level2: return .badge7   // green
        case .level3: return .badge5   // yellow
        case .level4: return .badge4   // orange
        case .level5: return .badge2   // pink
        }
    }
}

/// 페이북 디자인 시스템 약관 등급 배지. radius 4.
///
/// ```swift
/// BCPTermsBadge(level: .level1)   // "안심"
/// ```
///
/// ⚠ Figma 는 11pt 에 line-height 11 (상 6 · 하 5, 높이 22) 로 그려져 있다. line-height 11 토큰이
/// 없어 `font-1/badge/medium-1`(11/12) 을 써서 높이가 23 이 된다 — 1pt 차이는 디자이너 확인 전까지 둔다.
public struct BCPTermsBadge: View {
    private let level: BCPTermsBadgeLevel

    @Environment(\.bcpTheme) private var theme

    public init(level: BCPTermsBadgeLevel) {
        self.level = level
    }

    public var body: some View {
        let c = theme.component
        BCPBadge(
            text: level.title,
            surface: level.palette.surface(c),
            foreground: level.palette.text(c),
            textStyle: BCPTypography.font1BadgeMedium1,
            horizontalPadding: BCPDimens.spacing6,
            topPadding: BCPDimens.spacing6,
            // 하단 5 — spacing 토큰에 5 가 없다 (Figma 실측값).
            bottomPadding: 5,
            // 6 + line-height 11 + 5
            minHeight: 22,
            cornerRadius: BCPDimens.radius4
        )
    }
}

#if DEBUG
struct BCPTermsBadge_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            HStack(spacing: 8) {
                ForEach(BCPTermsBadgeLevel.allCases, id: \.rawValue) { level in
                    BCPTermsBadge(level: level)
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
