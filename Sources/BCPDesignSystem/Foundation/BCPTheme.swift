import SwiftUI

/// 디자인 토큰 묶음. 컬렉션별로 분리되어 있다 —
/// `button/primary/normal` 이 Semantic 과 Components 양쪽에 존재하고
/// 실제 컴포넌트가 바인딩하는 쪽은 `component` 다.
public struct BCPTheme: Sendable {
    public let semantic: BCPSemanticColors
    public let component: BCPComponentColors

    public init(semantic: BCPSemanticColors, component: BCPComponentColors) {
        self.semantic = semantic
        self.component = component
    }

    public static let light = BCPTheme(semantic: .light, component: .light)
    public static let dark = BCPTheme(semantic: .dark, component: .dark)

    public static func forScheme(_ scheme: ColorScheme) -> BCPTheme {
        scheme == .dark ? .dark : .light
    }
}

private struct BCPThemeKey: EnvironmentKey {
    static let defaultValue = BCPTheme.light
}

public extension EnvironmentValues {
    var bcpTheme: BCPTheme {
        get { self[BCPThemeKey.self] }
        set { self[BCPThemeKey.self] = newValue }
    }
}

/// 시스템 다크모드를 따라 토큰을 주입한다. 앱 루트에 한 번 붙인다.
private struct BCPThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content.environment(\.bcpTheme, .forScheme(colorScheme))
    }
}

public extension View {
    /// 시스템 다크모드를 따른다.
    func bcpTheme() -> some View { modifier(BCPThemeModifier()) }

    /// 특정 테마로 고정한다 (프리뷰·부분 강제용).
    func bcpTheme(_ theme: BCPTheme) -> some View { environment(\.bcpTheme, theme) }
}
