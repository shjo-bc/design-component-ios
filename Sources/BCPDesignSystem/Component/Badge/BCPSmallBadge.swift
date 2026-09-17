import SwiftUI

/// 소형 상태 배지 문구. Figma `badge-small` 세트가 그리는 세 가지다.
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

/// 소형 상태 배지의 강조 정도.
///
/// 타입마다 색이 다르지만 규칙은 같다 — `subtle` 은 옅은 바탕에 같은 계열 글자,
/// `strong` 은 꽉 찬 바탕에 대비되는 글자다.
///
/// | | subtle | strong |
/// |---|---|---|
/// | NEW · ON | 옅은 빨강 + 빨강 글자 (badge/3) | 빨강 + 흰 글자 (point/1) |
/// | OFF | 옅은 회색 + 회색 글자 (surface/4 + neutral/7) | 진회색 + 대비 글자 (surface/7 + neutral/9) |
public enum BCPSmallBadgeStyle: Sendable {
    case subtle, strong
}

/// 페이북 디자인 시스템 소형 상태 배지 (NEW · ON · OFF). 높이 18, radius 10.
///
/// ```swift
/// BCPSmallBadge(.new)                    // 옅은 빨강
/// BCPSmallBadge(.on, style: .strong)     // 꽉 찬 빨강
/// BCPSmallBadge(.off)                    // 진회색 + 흰 글자
/// BCPSmallBadge(.off, style: .subtle)    // 옅은 회색 + 회색 글자
/// ```
///
/// `style` 을 생략하면 Figma 의 기본 변형을 따른다 — NEW·ON 은 `subtle`, OFF 는 `strong` 이다.
///
/// ⚠ Figma 에서 **옅은 회색 OFF 배지의 변형 이름이 `type=new`** 로 잘못 붙어 있다
/// (`color=light-mode` / `dark-mode`). 이름과 달리 그려지는 글자는 "OFF" 이므로 여기서는
/// `.off` 의 `subtle` 로 옮겼다. Figma 쪽 이름을 정리하는 편이 맞아 보인다.
///
/// Figma 의 `color=light-mode` / `dark-mode` 축 자체는 디자이너가 모드를 손으로 바꿔 보려고
/// 둔 것이라 코드에는 옮기지 않았다 — 두 변형이 부르는 토큰이 같고, 모드는 테마가 처리한다.
public struct BCPSmallBadge: View {
    private let type: BCPSmallBadgeType
    private let style: BCPSmallBadgeStyle

    @Environment(\.bcpTheme) private var theme

    /// - Parameter style: 생략하면 Figma 기본값을 따른다 (NEW·ON 은 `subtle`, OFF 는 `strong`).
    public init(_ type: BCPSmallBadgeType, style: BCPSmallBadgeStyle? = nil) {
        self.type = type
        self.style = style ?? (type == .off ? .strong : .subtle)
    }

    private var colors: (surface: Color, text: Color) {
        let s = theme.semantic
        let c = theme.component
        switch (type, style) {
        case (.off, .subtle):
            return (s.colorSurface4, s.colorFontNeutral7)
        case (.off, .strong):
            return (s.colorSurface7, s.colorFontNeutral9)
        case (_, .subtle):
            return (BCPBadgePalette.badge3.surface(c), BCPBadgePalette.badge3.text(c))
        case (_, .strong):
            return (s.colorPoint1, s.colorFontNeutralWhite)
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
    /// Figma 세트의 변형 6종을 그대로 늘어놓는다.
    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            HStack(spacing: 8) {
                BCPSmallBadge(.new, style: .subtle)
                BCPSmallBadge(.new, style: .strong)
                BCPSmallBadge(.on, style: .subtle)
                BCPSmallBadge(.on, style: .strong)
                BCPSmallBadge(.off, style: .subtle)
                BCPSmallBadge(.off, style: .strong)
            }
            .padding()
            .bcpTheme()
            .preferredColorScheme(scheme)
            .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
