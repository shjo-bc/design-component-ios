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
                // Figma 손잡이에 drop shadow 가 있다 (black 10%, offset 1/1, blur 2).
                // `shadow/*` 다섯 토큰 중 어느 것과도 맞지 않는 raw 값이라 토큰으로 위장하지 않는다.
                // SwiftUI 의 radius 는 표준편차 기반이라 BCPShadows 와 같은 blur/2 규칙을 쓴다.
                .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1)
                .padding(.horizontal, Self.inset)
        }
        .frame(width: Self.trackWidth, height: Self.trackHeight)
        .opacity(isEnabled ? 1 : 0.4)
        .animation(.easeInOut(duration: 0.15), value: isOn)
        .contentShape(Rectangle())
        .onTapGesture { if isEnabled { onChange?(!isOn) } }
        // 도형만으로 이루어져 있어 그대로 두면 VoiceOver 가 읽을 것이 없다.
        // 이름은 호출부 책임이다 — `.accessibilityLabel(_:)` 로 붙인다.
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isOn ? "켜짐" : "꺼짐")
        // VoiceOver 로 "켜기/끄기" 를 직접 부를 수 있게 한다. 더블탭과 같은 동작이다.
        .accessibilityAction(named: isOn ? "끄기" : "켜기") { if isEnabled { onChange?(!isOn) } }
    }
}

#if DEBUG
struct BCPToggle_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var isOn = true

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    BCPToggle(isOn: isOn) { isOn = $0 }
                    Text(isOn ? "켜짐 · 눌러서 전환" : "꺼짐 · 눌러서 전환").font(.caption)
                }
                HStack(spacing: 12) {
                    BCPToggle(isOn: true) { _ in }.disabled(true)
                    BCPToggle(isOn: false) { _ in }.disabled(true)
                    Text("비활성").font(.caption)
                }
            }
        }
    }

    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            Demo()
                .padding()
                .bcpTheme()
                .preferredColorScheme(scheme)
                .previewLayout(.sizeThatFits)
                .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
