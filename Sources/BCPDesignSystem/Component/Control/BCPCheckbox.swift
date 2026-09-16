import SwiftUI

/// 체크박스 크기. Figma 에서 `checkbox`(24) 와 `checkbox-small`(20) 이 별도 세트다.
/// 모양도 다르다 — 24는 둥근 사각형(r=8), 20은 원.
public enum BCPCheckboxSize: Sendable {
    case medium, small

    var box: CGFloat { self == .medium ? 24 : 20 }
    var vector: BCPVectorSource { self == .medium ? BCPVectorPaths.checkMedium : BCPVectorPaths.checkSmall }
    var iconSize: CGSize { vector.viewBox }
    /// 24는 둥근 사각형, 20은 원.
    ///
    /// `small` 의 모서리는 Figma 가 `radius/full`(=999) 을 바인딩한다. 999 는 치수가 아니라
    /// "완전히 둥글게" 라는 **센티널**이다. 그대로 넘기면 클램핑 동작에 기대게 되므로
    /// 박스 절반으로 해석한다 — 토큰 참조는 유지되고 원은 보장된다.
    /// `medium` 의 8 은 Figma 에서 변수 바인딩 없는 raw 값이라 토큰으로 위장하지 않는다.
    var cornerRadius: CGFloat {
        self == .medium ? 8 : min(BCPDimens.radiusFull, box / 2)
    }
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
            // 도형만으로 이루어져 있어 그대로 두면 VoiceOver 가 읽을 것이 없다.
            // 하나의 조작 가능한 요소로 묶고 상태를 값으로 알린다.
            //
            // **이름은 호출부 책임이다** — 무엇에 대한 체크박스인지는 여기서 알 수 없다.
            // 호출부가 `.accessibilityLabel("약관 동의")` 를 붙이면 그쪽이 이긴다.
            .accessibilityElement()
            .accessibilityAddTraits(checked ? [.isButton, .isSelected] : .isButton)
            .accessibilityValue(checked ? "선택됨" : "선택 안 함")
    }
}

#if DEBUG
struct BCPCheckbox_Previews: PreviewProvider {
    /// 상태가 바뀌는 것을 눌러서 확인할 수 있어야 한다 — 정적 스냅샷만으로는
    /// 전이 중에 색이 어떻게 가는지 알 수 없다.
    private struct Demo: View {
        @State private var medium = true
        @State private var small = false

        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    BCPCheckbox(checked: medium) { medium = $0 }
                    Text("medium · 눌러서 전환").font(.caption)
                }
                HStack(spacing: 12) {
                    BCPCheckbox(checked: small, size: .small) { small = $0 }
                    Text("small").font(.caption)
                }
                HStack(spacing: 12) {
                    BCPCheckbox(checked: true) { _ in }.disabled(true)
                    BCPCheckbox(checked: false) { _ in }.disabled(true)
                    Text("비활성").font(.caption)
                }
                HStack(spacing: 12) {
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.25)).frame(width: 44, height: 44)
                        BCPCheckbox(checked: medium) { medium = $0 }
                    }
                    Text("회색이 권장 터치 타깃 44×44").font(.caption)
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
