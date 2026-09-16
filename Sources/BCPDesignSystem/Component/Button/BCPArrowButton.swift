import SwiftUI

/// 화살표 텍스트 버튼의 색 계열. Figma `arrow` 세트의 `color` 축.
/// 텍스트와 화살표가 같은 색을 쓴다.
public enum BCPArrowButtonColor: Sendable {
    case lightGray, darkGray, blue
}

/// 화살표 텍스트 버튼 크기. Figma `arrow` 세트의 `size` 축.
/// `small` 과 `medium` 은 아이콘 크기가 같고(12) 타이포만 다르다.
public enum BCPArrowButtonSize: Sendable {
    case small, medium, large

    var iconBox: CGFloat { self == .large ? 16 : 12 }

    var textStyle: BCPTextStyle {
        switch self {
        case .small: return BCPTypography.font1Paragraph6_2
        case .medium: return BCPTypography.font1Paragraph4_2
        case .large: return BCPTypography.font1Paragraph2_2
        }
    }
}

/// 화살표 방향. Figma `arrow` 축.
///
/// 세 방향의 SVG path 가 동일하다 — 같은 셰브론을 회전해 쓴다.
public enum BCPArrowButtonDirection: Sendable {
    case right, down, up

    var rotation: Angle {
        switch self {
        case .right: return .degrees(0)
        case .down: return .degrees(90)
        case .up: return .degrees(-90)
        }
    }
}

/// 페이북 디자인 시스템 화살표 텍스트 버튼.
///
/// 텍스트 + 셰브론을 2pt 간격으로 배치한다. 패딩이 없어 내용 폭에 맞춰 줄어든다.
///
/// Figma 에 `state` 축이 없다 — disabled·pressed 의 시각 정의가 없어서
/// `.disabled(_:)` 는 상호작용만 막고 색은 바꾸지 않는다.
public struct BCPArrowButton: View {
    private let title: String
    private let color: BCPArrowButtonColor
    private let size: BCPArrowButtonSize
    private let direction: BCPArrowButtonDirection
    private let action: () -> Void

    @Environment(\.bcpTheme) private var theme

    public init(
        _ title: String,
        color: BCPArrowButtonColor = .darkGray,
        size: BCPArrowButtonSize = .large,
        direction: BCPArrowButtonDirection = .right,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.size = size
        self.direction = direction
        self.action = action
    }

    private var tint: Color {
        let c = theme.component
        switch color {
        case .lightGray: return c.buttonArrowLightgray
        case .darkGray: return c.buttonArrowDarkgray
        case .blue: return c.buttonArrowBlue
        }
    }

    public var body: some View {
        let box = size.iconBox
        // 셰브론은 16pt 아이콘 박스에서 7x12 다. 다른 박스 크기에도 같은 비율로 맞춘다.
        let glyph = CGSize(width: box * 7 / 16, height: box * 12 / 16)

        return Button(action: action) {
            HStack(spacing: 2) {
                Text(title)
                    .bcpTextStyle(size.textStyle)
                    .foregroundColor(tint)
                // 화살표는 장식이다 — 버튼 이름은 title 이 맡는다.
                BCPVectorShape(BCPVectorPaths.chevronRight)
                    .fill(tint)
                    .frame(width: glyph.width, height: glyph.height)
                    .rotationEffect(direction.rotation)
                    .frame(width: box, height: box)
                    .accessibilityHidden(true)
            }
            .fixedSize()
        }
        // 디자인에 disabled 시각 정의가 없다. `.disabled(_:)` 는 상호작용만 막는다.
        .buttonStyle(.plain)
    }
}
