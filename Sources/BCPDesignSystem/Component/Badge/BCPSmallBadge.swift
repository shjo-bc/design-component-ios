import SwiftUI

/// 소형 상태 배지 문구. Figma `badge-small` 세트의 `type` 축.
public enum BCPSmallBadgeType: Sendable {
    case new, on, off

    var title: String {
        switch self {
        case .new: return "NEW"
        case .on: return "ON"
        case .off: return "OFF"
        }
    }
}

/// 소형 상태 배지 색 스타일. Figma `badge-small` 세트의 `color` 축을 접은 것.
///
/// Figma 의 `color=1` → `.tint`, `color=2` → `.solid`, `color=light-mode / dark-mode` → `.neutral`.
/// light/dark 는 디자이너가 수동으로 모드를 바꾸는 축이라 코드에서는 테마가 대신한다.
public enum BCPSmallBadgeStyle: Sendable {
    /// 옅은 빨강 바탕 + 빨강 글자 (badge/3)
    case tint
    /// 진한 빨강 바탕 + 흰 글자 (point/1)
    case solid
    /// 회색 바탕 + 회색 글자. `.off` 는 한 단계 더 진하다 (surface/7 + neutral/9).
    case neutral
}

/// 페이북 디자인 시스템 소형 상태 배지 (NEW · ON · OFF). 높이 18, radius 10.
///
/// ```swift
/// BCPSmallBadge(.new)                  // 옅은 빨강
/// BCPSmallBadge(.on, style: .solid)    // 진한 빨강
/// BCPSmallBadge(.off)                  // 회색 — style 은 무시된다
/// ```
///
/// Figma 에는 `off` 가 회색으로만 존재한다. `.off` 는 어떤 style 을 넘겨도 회색으로 그린다.
public struct BCPSmallBadge: View {
    private let type: BCPSmallBadgeType
    private let style: BCPSmallBadgeStyle

    @Environment(\.bcpTheme) private var theme

    public init(_ type: BCPSmallBadgeType, style: BCPSmallBadgeStyle = .tint) {
        self.type = type
        self.style = style
    }

    private var colors: (surface: Color, text: Color) {
        let s = theme.semantic
        let c = theme.component
        if type == .off {
            return (s.colorSurface7, s.colorFontNeutral9)
        }
        switch style {
        case .tint: return (BCPBadgePalette.badge3.surface(c), BCPBadgePalette.badge3.text(c))
        case .solid: return (s.colorPoint1, s.colorFontNeutralWhite)
        case .neutral: return (s.colorSurface4, s.colorFontNeutral7)
        }
    }

    public var body: some View {
        let (surface, text) = colors
        BCPBadge(
            text: type.title,
            surface: surface,
            foreground: text,
            textStyle: BCPTypography.font1BadgeSmall1,
            horizontalPadding: BCPDimens.spacing6,
            topPadding: BCPDimens.spacing4,
            bottomPadding: BCPDimens.spacing4,
            // 4 + line-height 10 + 4
            minHeight: 18,
            cornerRadius: BCPDimens.radius10
        )
    }
}

#if DEBUG
struct BCPSmallBadge_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            HStack(spacing: 8) {
                BCPSmallBadge(.new, style: .tint)
                BCPSmallBadge(.new, style: .solid)
                BCPSmallBadge(.on, style: .tint)
                BCPSmallBadge(.on, style: .solid)
                BCPSmallBadge(.new, style: .neutral)
                BCPSmallBadge(.off)
            }
            .padding()
            .bcpTheme()
            .preferredColorScheme(scheme)
            .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
