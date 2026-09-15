import SwiftUI

/// 체크박스 크기. Figma 에서 `checkbox`(24) 와 `checkbox-small`(20) 이 별도 세트다.
/// 모양도 다르다 — 24는 둥근 사각형(r=8), 20은 원.
public enum BCPCheckboxSize: Sendable {
    case medium, small

    var box: CGFloat { self == .medium ? 24 : 20 }
    var vector: BCPVectorSource { self == .medium ? BCPVectorPaths.checkMedium : BCPVectorPaths.checkSmall }
    var iconSize: CGSize { vector.viewBox }
    /// 24는 둥근 사각형, 20은 원.
    /// `small` 의 모서리는 Figma 가 `radius/full` 을 바인딩하고 있어 토큰을 그대로 쓴다.
    /// `medium` 의 8 은 Figma 에서 변수 바인딩 없는 raw 값이라 토큰으로 위장하지 않는다.
    var cornerRadius: CGFloat { self == .medium ? 8 : BCPDimens.radiusFull }
}

/// 페이북 디자인 시스템 체크박스.
///
/// 체크 표시는 세 상태 모두 그려지고 **색만 바뀐다** (Figma 구조 그대로).
/// 미선택 상태의 아이콘 색이 흰색이라 배경에 묻힌다.
public struct BCPCheckbox: View {
    private let checked: Bool
    private let size: BCPCheckboxSize
    private let onChange: ((Bool) -> Void)?

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        checked: Bool,
        size: BCPCheckboxSize = .medium,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.checked = checked
        self.size = size
        self.onChange = onChange
    }

    private var surface: Color {
        let c = theme.component
        if !isEnabled { return c.controlCheckboxDisabledSurface }
        return checked ? c.controlCheckboxSelectSurface : c.controlCheckboxUnselectSurface
    }

    private var icon: Color {
        let c = theme.component
        if !isEnabled { return c.controlCheckboxDisabledIcon }
        return checked ? c.controlCheckboxSelectIcon : c.controlCheckboxUnselectIcon
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
            .fill(surface)
            .frame(width: size.box, height: size.box)
            .overlay(
                BCPVectorShape(size.vector)
                    .fill(icon)
                    .frame(width: size.iconSize.width, height: size.iconSize.height)
            )
            .contentShape(Rectangle())
            .onTapGesture { if isEnabled { onChange?(!checked) } }
            .accessibilityAddTraits(checked ? [.isButton, .isSelected] : .isButton)
    }
}
