import SwiftUI

/// Terms 계열이 함께 쓰는 작은 조각들. 공개 API 가 아니다.
///
/// Figma Terms 페이지(`2820:3343`)의 네 세트는 체크 표시·화살표·글자 규격을 서로 빌려 쓴다.
/// 세트마다 다시 그리지 않도록 여기 모아 둔다.

/// 배경 없는 체크 표시. Figma `checkmark` 인스턴스(24×24, 안쪽 여백 5, 체크 14×10).
///
/// `BCPCheckbox` 와 달리 **상자가 없다** — 색 있는 체크 모양만 있다. 미선택이면 체크박스 미선택
/// 바탕색(`control/checkbox/unselect-surface`, 남색 10%) 으로 흐리게, 선택이면 `color/point/6` 으로
/// 진하게 그려진다. Figma 의 `checkmark` 세트(`1430:44566`)는 variant 이름이 깨져 있어
/// (`docs/naming-contract.md` §6) 공개 컴포넌트로 올리지 않고 Terms 안에서만 쓴다.
struct BCPTermsCheckmark: View {
    let selected: Bool
    let onChange: ((Bool) -> Void)?

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private var color: Color {
        selected ? theme.semantic.colorPoint6 : theme.component.controlCheckboxUnselectSurface
    }

    var body: some View {
        BCPVectorShape(BCPVectorPaths.checkMedium)
            .fill(color)
            .frame(width: BCPVectorPaths.checkMedium.viewBox.width,
                   height: BCPVectorPaths.checkMedium.viewBox.height)
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
            .onTapGesture { if isEnabled { onChange?(!selected) } }
            .accessibilityElement()
            .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
            .accessibilityValue(selected ? "선택됨" : "선택 안 함")
    }
}

/// 16×16 화살표 아이콘. Figma `ico-arrow-{right|down|up}-normal` (안쪽 chevron 7×12).
///
/// 경로는 `BCPVectorPaths.chevronRight` 하나만 쓰고 방향은 회전으로 만든다 — Figma 의
/// down/up 아이콘은 right 를 90° 돌린 것과 좌표까지 같다(실측).
struct BCPTermsChevron: View {
    enum Direction { case right, down, up }

    let direction: Direction
    let color: Color

    private var rotation: Angle {
        switch direction {
        case .right: return .zero
        case .down: return .degrees(90)
        case .up: return .degrees(-90)
        }
    }

    var body: some View {
        BCPVectorShape(BCPVectorPaths.chevronRight)
            .fill(color)
            .frame(width: BCPVectorPaths.chevronRight.viewBox.width,
                   height: BCPVectorPaths.chevronRight.viewBox.height)
            .rotationEffect(rotation)
            .frame(width: 16, height: 16)
            .accessibilityHidden(true)
    }
}

extension View {
    /// Figma 는 텍스트 높이를 line-height 로 잡지만 SwiftUI 한 줄 `Text` 는 서체 행높이를 쓴다
    /// (`BCPBadge` 참고). 행 높이를 디자인과 맞추기 위해 line-height 를 최소 높이로 건다.
    /// 여러 줄로 늘어나면 그대로 커진다.
    func bcpLineHeightFloor(_ style: BCPTextStyle) -> some View {
        frame(minHeight: style.lineHeight)
    }
}
