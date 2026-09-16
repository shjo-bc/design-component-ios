import SwiftUI

/// 페이북 디자인 시스템 라디오 버튼 (24pt).
///
/// Figma 의 `disabled` 는 **선택된 상태의 비활성**이다 — 미선택 비활성 variant 는 디자인에 없다.
/// 여기서는 `isEnabled == false` 일 때 선택 여부와 무관하게 disabled 토큰을 쓴다.
public struct BCPRadioButton: View {
    private let selected: Bool
    private let onSelect: (() -> Void)?

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private static let box: CGFloat = 24
    private static let dot: CGFloat = 10

    public init(selected: Bool, onSelect: (() -> Void)? = nil) {
        self.selected = selected
        self.onSelect = onSelect
    }

    public var body: some View {
        let c = theme.component
        let showDot = !isEnabled || selected
        let fill: Color = !isEnabled ? c.controlRadioDisabledSurface : (selected ? c.controlRadioSelectSurface : .clear)
        let line: Color = !isEnabled ? c.controlRadioDisabledLine : (selected ? c.controlRadioSelectLine : c.controlRadioUnselectLine)
        let lineWidth: CGFloat = (isEnabled && selected) ? 2 : 1

        return Circle()
            .fill(fill)
            .frame(width: Self.box, height: Self.box)
            .overlay(Circle().strokeBorder(line, lineWidth: lineWidth))
            .overlay(
                Circle()
                    .fill(line)
                    .frame(width: Self.dot, height: Self.dot)
                    .opacity(showDot ? 1 : 0)
            )
            .contentShape(Circle())
            .onTapGesture { if isEnabled { onSelect?() } }
            // 도형만으로 이루어져 있어 그대로 두면 VoiceOver 가 읽을 것이 없다.
            // 이름은 호출부 책임이다 — `.accessibilityLabel(_:)` 로 붙인다.
            .accessibilityElement()
            .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
            .accessibilityValue(selected ? "선택됨" : "선택 안 함")
    }
}

#if DEBUG
struct BCPRadioButton_Previews: PreviewProvider {
    private struct Demo: View {
        @State private var selected = 0

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(0..<3, id: \.self) { i in
                    HStack(spacing: 12) {
                        BCPRadioButton(selected: selected == i) { selected = i }
                        Text("옵션 \(i + 1)").font(.caption)
                    }
                }
                HStack(spacing: 12) {
                    BCPRadioButton(selected: true) {}.disabled(true)
                    BCPRadioButton(selected: false) {}.disabled(true)
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
