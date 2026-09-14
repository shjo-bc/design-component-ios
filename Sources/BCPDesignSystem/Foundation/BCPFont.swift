import SwiftUI

/// 합성된 타이포 스타일 하나. `BCPTypography` 가 이 타입으로 57개를 제공한다.
///
/// 폰트 리소스 등록은 이 패키지가 아니라 **앱 책임**이다.
/// 번들에 없으면 `Font.custom` 이 시스템 폰트로 폴백한다 — 레이아웃은 맞고 서체만 다르다.
public struct BCPTextStyle: Sendable, Equatable {
    public let family: String
    public let size: CGFloat
    public let weight: Int
    public let lineHeight: CGFloat

    public init(family: String, size: CGFloat, weight: Int, lineHeight: CGFloat) {
        self.family = family
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
    }

    public var font: Font {
        .custom(family, size: size).weight(BCPFont.weight(weight))
    }

    /// SwiftUI 의 `lineSpacing` 은 줄 *사이* 간격이라 line-height 에서 폰트 크기를 뺀다.
    public var lineSpacing: CGFloat { max(0, lineHeight - size) }
}

public enum BCPFont {
    /// 디자인 시스템이 쓰는 서체는 둘이다 — `font-1/…` Pretendard, `font-2/…` Gmarket Sans.
    /// 스타일마다 자기 서체를 들고 있으므로 전역 기본값은 두지 않는다.
    public static func weight(_ value: Int) -> Font.Weight {
        switch value {
        case ..<200: return .ultraLight
        case ..<300: return .thin
        case ..<400: return .light
        case ..<500: return .regular
        case ..<600: return .medium
        case ..<700: return .semibold
        case ..<800: return .bold
        case ..<900: return .heavy
        default: return .black
        }
    }
}

public extension View {
    /// 토큰 기준 폰트와 줄간격을 한 번에 적용한다.
    func bcpTextStyle(_ style: BCPTextStyle) -> some View {
        font(style.font).lineSpacing(style.lineSpacing)
    }
}
