import SwiftUI

/// 페이북 디자인 시스템 토글 (48x28, 손잡이 24pt).
///
/// Figma 에 **disabled variant 가 없다.** `isEnabled == false` 는 관용대로 알파를 낮춘다 —
/// 디자인에 정의되면 토큰으로 교체할 것 (shared/figma/controls-style.json 의 note).
public struct BCPToggle: View {
    private let isOn: Bool
    private let onChange: ((Bool) -> Void)?

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private static let trackWidth: CGFloat = 48
    private static let trackHeight: CGFloat = 28
    private static let thumb: CGFloat = 24
    private static let inset: CGFloat = 2

    public init(isOn: Bool, onChange: ((Bool) -> Void)? = nil) {
        self.isOn = isOn
        self.onChange = onChange
    }

    public var body: some View {
        let c = theme.component
        return ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? c.controlToggleOnSurface : c.controlToggleOffSurface)
                .frame(width: Self.trackWidth, height: Self.trackHeight)
            Circle()
                .fill(c.controlToggleKey)
                .frame(width: Self.thumb, height: Self.thumb)
                .padding(.horizontal, Self.inset)
        }
        .frame(width: Self.trackWidth, height: Self.trackHeight)
        .opacity(isEnabled ? 1 : 0.4)
        .animation(.easeInOut(duration: 0.15), value: isOn)
        .contentShape(Rectangle())
        .onTapGesture { if isEnabled { onChange?(!isOn) } }
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "켜짐" : "꺼짐")
    }
}
