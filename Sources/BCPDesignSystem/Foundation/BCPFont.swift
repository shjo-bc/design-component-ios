import SwiftUI
import UIKit

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
        .custom(BCPFont.resolvedFamily(family), size: size).weight(BCPFont.weight(weight))
    }

    /// 같은 토큰의 `UIFont`. 줄간격 계산과 텍스트 폭 측정이 렌더와 같은 서체를 쓰게 한다.
    public var uiFont: UIFont {
        BCPFont.uiFont(family: family, size: size, weight: weight)
    }

    /// SwiftUI 의 `lineSpacing` 은 줄 *사이* 간격이라 line-height 에서 서체의 실제 행높이를 뺀다.
    /// 폰트 크기를 빼면 ascender·descender 만큼 줄이 더 벌어져 디자인보다 헐거워진다.
    public var lineSpacing: CGFloat { max(0, lineHeight - uiFont.lineHeight) }
}

public enum BCPFont {
    /// Figma 가 쓰는 서체 이름과 기기에 설치된 폰트의 **family 이름이 다를 수 있다.**
    ///
    /// 실측: 토큰은 `Gmarket Sans` 를 부르는데 페이북 앱이 번들에 넣은 파일의 family 는
    /// `Gmarket Sans TTF` 다. 이름이 한 글자만 달라도 `Font.custom` 은 조용히 시스템
    /// 폰트로 폴백한다 — 경고도 없어서 알아채기 어렵다.
    ///
    /// 토큰 값(= Figma 이름)은 그대로 두고 **읽는 시점에만** 실제 이름으로 바꾼다.
    /// 후보 중 기기에 실제로 있는 것을 고르므로, 앱이 어느 판본을 넣었든 따라간다.
    public static func resolvedFamily(_ family: String) -> String {
        candidates(for: family).first { UIFont(name: $0, size: 12) != nil } ?? family
    }

    /// 같은 서체가 배포 판본에 따라 갖는 이름들. 첫 번째가 Figma 가 부르는 이름이다.
    private static func candidates(for family: String) -> [String] {
        switch family {
        case "Gmarket Sans": return [family, "Gmarket Sans TTF", "GmarketSansTTF"]
        default: return [family]
        }
    }

    /// 토큰이 요구하는 서체가 기기에 있는지 확인한다.
    ///
    /// 없으면 레이아웃이 조용히 어긋난다(글자 폭이 달라져 줄바꿈·잘림·버튼 폭이 바뀐다).
    /// 앱 시작 시 한 번 불러 두면 빠뜨린 것을 바로 알 수 있다.
    /// - Returns: 찾지 못한 서체 이름들. 비어 있으면 전부 준비된 것이다.
    @discardableResult
    public static func missingFamilies() -> [String] {
        let required = ["Pretendard", "Gmarket Sans"]
        let missing = required.filter { UIFont(name: resolvedFamily($0), size: 12) == nil }
        #if DEBUG
        if !missing.isEmpty {
            print("⚠️ BCPDesignSystem: 서체를 찾지 못했다 — \(missing.joined(separator: ", "))")
            print("   앱 번들에 폰트를 넣고 UIAppFonts 또는 CTFontManagerRegisterFontsForURL 로 등록할 것.")
            print("   등록하지 않으면 시스템 폰트로 그려져 디자인과 글자 폭이 달라진다.")
        }
        #endif
        return missing
    }
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

    /// 토큰의 family·weight 로 `UIFont` 를 만든다. 번들에 서체가 없으면 시스템 폰트로 폴백한다.
    public static func uiFont(family: String, size: CGFloat, weight: Int) -> UIFont {
        let descriptor = UIFontDescriptor(fontAttributes: [
            .family: family,
            .traits: [UIFontDescriptor.TraitKey.weight: uiWeight(weight)],
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    /// `weight(_:)` 의 UIKit 짝. 두 경로가 같은 굵기로 해석되도록 구간을 맞춘다.
    public static func uiWeight(_ value: Int) -> UIFont.Weight {
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
