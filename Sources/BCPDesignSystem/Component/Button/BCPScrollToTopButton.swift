import SwiftUI

/// 페이북 디자인 시스템 '맨 위로' 버튼 (46pt 원형).
///
/// Figma 세트 `go-to-the-top` (1617:14407). `state` 축은 `normal` / `pressed` 뿐이고
/// **disabled 정의가 없다** — `.disabled(_:)` 는 상호작용만 막는다.
///
/// 화살표는 아이콘 라이브러리에 의존하지 않고 직접 그린다.
/// 경로는 Figma `fillGeometry` 실측값이다 (`BCPVectorPaths.scrollTopArrow`).
public struct BCPScrollToTopButton: View {
    private let action: () -> Void

    @Environment(\.bcpTheme) private var theme

    private static let box: CGFloat = 46
    private static let arrowWidth: CGFloat = 14
    private static let arrowHeight: CGFloat = 20

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Color.clear.frame(width: Self.box, height: Self.box)
        }
        .buttonStyle(BCPScrollToTopStyle(theme: theme))
        // 라벨이 Color.clear 라 SwiftUI 가 읽을 텍스트가 없다 — 이름을 직접 준다.
        .accessibilityLabel("맨 위로")
    }
}

private struct BCPScrollToTopStyle: ButtonStyle {
    let theme: BCPTheme

    func makeBody(configuration: Configuration) -> some View {
        let c = theme.component
        return configuration.label
            .background(Circle().fill(c.buttonGototheTopSurface))
            // pressed 는 표면 색 교체가 아니라 오버레이 1장이다 (Figma fills 2장 구조).
            .overlay(Circle().fill(configuration.isPressed ? c.buttonGototheTopPressed : .clear))
            .overlay(Circle().strokeBorder(c.buttonGototheTopBorder, lineWidth: BCPDimens.border1))
            .overlay(
                BCPVectorShape(BCPVectorPaths.scrollTopArrow)
                    .fill(c.buttonGototheTopArrow)
                    .frame(width: 14, height: 20)
            )
            .contentShape(Circle())
    }
}
