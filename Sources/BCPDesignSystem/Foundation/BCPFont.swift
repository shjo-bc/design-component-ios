import SwiftUI

/// 토큰의 `family` / `size` / `weight` / `line-height` 를 SwiftUI 폰트로 옮긴다.
///
/// 디자인 시스템 전체가 Pretendard 를 쓴다 (`font/family/*`).
/// 앱 번들에 폰트가 없으면 `Font.custom` 이 시스템 폰트로 폴백하므로,
/// 폰트 등록은 이 패키지가 아니라 앱 쪽 책임이다.
public enum BCPFont {
    /// 토큰이 지정한 서체 이름. 현재 57개 타이포 그룹 전부 같은 값이지만,
    /// 임의의 한 토큰을 전역 기본값으로 참조하면 한 그룹만 달라져도 조용히 틀린다.
    /// Kotlin 쪽 `BCPFont.TOKEN_FAMILY` 와 같은 리터럴을 쓴다.
    public static let defaultFamily = "Pretendard"

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

    public static func font(family: String = defaultFamily, size: CGFloat, weight: Int) -> Font {
        .custom(family, size: size).weight(self.weight(weight))
    }
}

public extension View {
    /// 토큰 기준 줄간격. SwiftUI 의 `lineSpacing` 은 줄 *사이* 간격이라
    /// line-height 에서 폰트 크기를 뺀 값을 넘긴다.
    func bcpLineHeight(fontSize: CGFloat, lineHeight: CGFloat) -> some View {
        lineSpacing(max(0, lineHeight - fontSize))
    }
}
