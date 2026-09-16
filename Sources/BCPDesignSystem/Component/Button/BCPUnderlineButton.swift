import SwiftUI

/// 밑줄 텍스트 버튼의 색 계열. Figma `underline` 세트의 `color` 축.
public enum BCPUnderlineButtonColor: Sendable {
    case lightGray, darkGray, blue
}

/// 밑줄 텍스트 버튼 크기. Figma `underline` 세트의 `size` 축.
public enum BCPUnderlineButtonSize: Sendable {
    case small, large
}

/// 페이북 디자인 시스템 밑줄 텍스트 버튼.
///
/// 텍스트 아래 1pt 선을 1pt 간격으로 그린다. 패딩이 없어 텍스트 폭에 맞춰 줄어든다.
///
/// Figma 에 `state` 축이 없다 — disabled·pressed 의 시각 정의가 없어서
/// `.disabled(_:)` 는 상호작용만 막고 색은 바꾸지 않는다.
public struct BCPUnderlineButton: View {
    private let title: String
    private let color: BCPUnderlineButtonColor
    private let size: BCPUnderlineButtonSize
    private let action: () -> Void

    @Environment(\.bcpTheme) private var theme

    public init(
        _ title: String,
        color: BCPUnderlineButtonColor = .darkGray,
        size: BCPUnderlineButtonSize = .large,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.color = color
        self.size = size
        self.action = action
    }

    private var textColor: Color {
        let c = theme.component
        switch color {
        case .lightGray: return c.buttonUnderlineLightgray
        case .darkGray: return c.buttonUnderlineDarkgray
        case .blue: return c.buttonUnderlineBlue
        }
    }

    private var lineColor: Color {
        let c = theme.component
        switch color {
        case .lightGray: return c.buttonUnderlineLightgrayLine
        case .darkGray: return c.buttonUnderlineDarkgrayLine
        case .blue: return c.buttonUnderlineBlueLine
        }
    }

    /// ⚠ `large` + `blue` 만 다른 타이포를 쓴다 (17/700, 나머지 large 는 16/400).
    /// 색이 타이포를 바꾸는 건 이상하지만 Figma 실측값이다 —
    /// 의도 확인 전까지 디자인대로 둔다 (shared/figma/underline-style.json 의 anomaly).
    private var textStyle: BCPTextStyle {
        switch (size, color) {
        case (.small, _): return BCPTypography.font1Paragraph6_2
        case (.large, .blue): return BCPTypography.font1Paragraph3_1
        case (.large, _): return BCPTypography.font1Paragraph4_2
        }
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .bcpTextStyle(textStyle)
                    .foregroundColor(textColor)
                    .fixedSize(horizontal: true, vertical: false)
                Rectangle()
                    .fill(lineColor)
                    .frame(height: 1)
            }
            .fixedSize(horizontal: true, vertical: true)
        }
        // 디자인에 disabled 시각 정의가 없다. `.disabled(_:)` 는 상호작용만 막고 색은 그대로다.
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct BCPUnderlineButton_Previews: PreviewProvider {
    private static let colors: [(String, BCPUnderlineButtonColor)] = [
        ("lightGray", .lightGray), ("darkGray", .darkGray), ("blue", .blue),
    ]

    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            VStack(alignment: .leading, spacing: 14) {
                ForEach(colors, id: \.0) { name, color in
                    HStack(spacing: 12) {
                        Text(name).font(.caption).frame(width: 80, alignment: .leading)
                        BCPUnderlineButton("자세히", color: color, size: .large) {}
                        BCPUnderlineButton("자세히", color: color, size: .small) {}
                    }
                }
            }
            .padding()
            .bcpTheme()
            .preferredColorScheme(scheme)
            .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
