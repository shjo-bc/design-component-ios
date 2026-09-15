// 이 파일은 자동 생성된다. 직접 수정하지 말 것.
// 생성: node tools/scripts/gen-foundation.mjs
// 원본: Figma Variables → shared/tokens/src/

import SwiftUI

/// 그림자 한 벌. Figma 의 drop shadow 네 값(offset x·y, blur, color)을 그대로 담는다.
public struct BCPShadow: Sendable, Equatable {
    public let x: CGFloat
    public let y: CGFloat
    public let blur: CGFloat
    public let color: Color

    public init(x: CGFloat, y: CGFloat, blur: CGFloat, color: Color) {
        self.x = x
        self.y = y
        self.blur = blur
        self.color = color
    }
}

/// 합성 그림자 5개.
///
/// 토큰은 `x` / `y` / `blur` / `color` 로 흩어져 있고 color 만 `BCPSemanticColors` 로 간다.
/// 여기서는 그룹 단위로 합쳐 바로 쓸 수 있게 한다.
public struct BCPShadows: Sendable {
    /// `shadow/layered` — offset(0, -12) blur 24
    public let layered: BCPShadow
    /// `shadow/elevation-1` — offset(0, 0) blur 12
    public let elevation1: BCPShadow
    /// `shadow/elevation-2` — offset(0, 0) blur 20
    public let elevation2: BCPShadow
    /// `shadow/elevation-3` — offset(0, 4) blur 28
    public let elevation3: BCPShadow
    /// `shadow/elevation-4` — offset(0, 8) blur 40
    public let elevation4: BCPShadow

    public init(colors: BCPSemanticColors) {
        self.layered = BCPShadow(x: 0, y: -12, blur: 24, color: colors.shadowLayeredColor)
        self.elevation1 = BCPShadow(x: 0, y: 0, blur: 12, color: colors.shadowElevation1Color)
        self.elevation2 = BCPShadow(x: 0, y: 0, blur: 20, color: colors.shadowElevation2Color)
        self.elevation3 = BCPShadow(x: 0, y: 4, blur: 28, color: colors.shadowElevation3Color)
        self.elevation4 = BCPShadow(x: 0, y: 8, blur: 40, color: colors.shadowElevation4Color)
    }
}

public extension View {
    /// 토큰 그림자를 적용한다.
    ///
    /// SwiftUI 의 `shadow(radius:)` 는 표준편차 기반이라 Figma 의 blur 와 단위가 다르다.
    /// 통상 `radius = blur / 2` 로 맞춘다.
    func bcpShadow(_ shadow: BCPShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.blur / 2, x: shadow.x, y: shadow.y)
    }
}
