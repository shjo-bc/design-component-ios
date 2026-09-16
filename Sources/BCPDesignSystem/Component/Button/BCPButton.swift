import SwiftUI

/// 버튼 스타일.
///
/// Figma 의 `outlined-1` / `outlined-2` 를 각각 `.outlined` / `.outlinedSubtle` 로 옮겼다
/// (네이밍 계약 §5 매핑표).
///
/// `isp` / `openApp` 은 **xxlarge 전용**이다. Figma variant 이름은 `yellow` / `purple` 이지만
/// 실제로 바인딩하는 토큰이 `button/isp/*` · `button/open-app/*` 이라 용도 기준으로 명명했다
/// (색 이름은 네이밍 계약 §2 위반이기도 하다).
///
/// `gradient`(small 전용)는 아직 포함하지 않는다.
public enum BCPButtonType: Sendable {
    case primary, secondary, outlined, outlinedSubtle

    /// xxlarge 전용 — Figma `type=yellow`, 토큰 `button/isp/*`
    case isp

    /// xxlarge 전용 — Figma `type=purple`, 토큰 `button/open-app/*`
    case openApp

    /// 자동완성·필터 칩처럼 연한 채움 위에 gradient 텍스트를 얹는 배치.
    /// 전용 버튼 세트가 아니라 `button/1` 표면 + `button/gradient/text/*` 조합이라 용도 기준으로 명명했다.
    case chip
}

/// 버튼 크기. Figma 에서는 size 가 variant 축이 아니라 **컴포넌트 세트가 분리**되어 있고,
/// 세트마다 지원하는 type·state 축이 다르다. 자세한 내용은 `shared/figma/button-style.json`.
public enum BCPButtonSize: Sendable {
    case xsmall, small, medium, large, xlarge, xxlarge
}

/// 버튼이 가로 공간을 쓰는 방식. Figma 의 전폭 CTA(`bottom-button`)처럼 컨테이너를 채워야 하는 배치가 있다.
///
/// 호출부에서 `.frame(maxWidth: .infinity)` 를 버튼 **바깥**에 붙이면 표면은 내용 크기 그대로 남고
/// 프레임만 넓어진다 — 폭은 표면을 그리는 `ButtonStyle` 안에서 정해져야 한다.
public enum BCPButtonWidth: Sendable {
    /// 내용 크기에 맞춘다.
    case hug
    /// 컨테이너 폭을 채운다.
    case fill
}

struct BCPButtonPalette {
    let surface: Color
    let content: Color
    let border: Color?
}

extension BCPButtonType {
    func palette(_ c: BCPComponentColors, enabled: Bool) -> BCPButtonPalette {
        switch self {
        case .primary:
            return BCPButtonPalette(
                surface: enabled ? c.buttonPrimaryNormal : c.buttonPrimaryDisabled,
                content: enabled ? c.buttonPrimaryTextNormal : c.buttonPrimaryTextDisabled,
                border: nil
            )
        case .secondary:
            return BCPButtonPalette(
                surface: enabled ? c.buttonSecondaryNormal : c.buttonSecondaryDisabled,
                content: enabled ? c.buttonSecondaryTextNormal : c.buttonSecondaryTextDisabled,
                border: nil
            )
        case .outlined:
            return BCPButtonPalette(
                surface: enabled ? c.buttonOutlined1Normal : c.buttonOutlined1Disabled,
                content: enabled ? c.buttonOutlined1TextNormal : c.buttonOutlined1TextDisabled,
                border: enabled ? c.buttonOutlined1NormalBorder : c.buttonOutlined1DisabledBorder
            )
        case .outlinedSubtle:
            return BCPButtonPalette(
                surface: enabled ? c.buttonOutlined2Normal : c.buttonOutlined2Disabled,
                content: enabled ? c.buttonOutlined2TextNormal : c.buttonOutlined2TextDisabled,
                border: enabled ? c.buttonOutlined2NormalBorder : c.buttonOutlined2DisabledBorder
            )
        case .isp:
            return BCPButtonPalette(
                surface: enabled ? c.buttonIspNormal : c.buttonIspDisabled,
                content: enabled ? c.buttonIspTextNormal : c.buttonIspTextDisabled,
                border: nil
            )
        case .openApp:
            return BCPButtonPalette(
                surface: enabled ? c.buttonOpenAppNormal : c.buttonOpenAppDisabled,
                content: enabled ? c.buttonOpenAppTextNormal : c.buttonOpenAppTextDisabled,
                border: nil
            )
        case .chip:
            // 칩에는 disabled 표면 토큰이 없다. 같은 텍스트 계열인 gradient 가 표면을 그대로 두고
            // 텍스트만 흐리는 방식(`gradient/normal` == `gradient/disabled`)이라 그 규칙을 따른다.
            return BCPButtonPalette(
                surface: c.button1,
                content: enabled ? c.buttonGradientTextNormal : c.buttonGradientTextDisabled,
                border: nil
            )
        }
    }
}

struct BCPButtonMetrics {
    let height: CGFloat
    /// Figma 가 세로 패딩을 Variable 로 묶어뒀다. 높이는 이 값 ×2 + lineHeight 와 정확히 같다.
    /// 높이만 박아두면 토큰이 바뀌어도 따라가지 않고, 글자가 커지면 패딩이 0이 된다.
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    let gap: CGFloat
    let textStyle: BCPTextStyle
    /// Figma 에서 높이가 FIXED 로 잡힌 사이즈. `xlarge` 만 해당한다.
    let fixedHeight: Bool
}

extension BCPButtonSize {
    var metrics: BCPButtonMetrics {
        switch self {
        case .xsmall:
            return BCPButtonMetrics(
                height: 32,
                verticalPadding: BCPDimens.spacing7,
                horizontalPadding: BCPDimens.spacing10,
                cornerRadius: BCPDimens.radius8,
                gap: BCPDimens.spacing4,
                textStyle: BCPTypography.font1Paragraph7_1,
                fixedHeight: false
            )
        case .small:
            return BCPButtonMetrics(
                height: 40,
                verticalPadding: BCPDimens.spacing10,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius8,
                gap: BCPDimens.spacing6,
                textStyle: BCPTypography.font1Paragraph6_1,
                fixedHeight: false
            )
        case .medium:
            return BCPButtonMetrics(
                height: 44,
                verticalPadding: BCPDimens.spacing11,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius10,
                gap: BCPDimens.spacing6,
                textStyle: BCPTypography.font1Paragraph5_1,
                fixedHeight: false
            )
        case .large:
            return BCPButtonMetrics(
                height: 48,
                verticalPadding: BCPDimens.spacing11,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius12,
                gap: BCPDimens.spacing6,
                textStyle: BCPTypography.font1Paragraph3_1,
                fixedHeight: false
            )
        case .xlarge:
            return BCPButtonMetrics(
                height: 56,
                verticalPadding: 0,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius16,
                gap: BCPDimens.spacing6,
                textStyle: BCPTypography.font1Paragraph2_1,
                fixedHeight: true
            )
        case .xxlarge:
            return BCPButtonMetrics(
                height: 64,
                verticalPadding: BCPDimens.spacing16,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius16,
                gap: BCPDimens.spacing10,
                textStyle: BCPTypography.font1Subheading1_1,
                fixedHeight: false
            )
        }
    }
}

private enum BCPButtonIconSize {
    static let leading: CGFloat = 20
    static let trailing: CGFloat = 16
}

/// 페이북 디자인 시스템 기본 버튼.
///
/// Figma 의 variant 축 중 코드 파라미터가 되는 것만 노출한다 (네이밍 계약 §2):
/// - `mode` → 파라미터 아님. `.bcpTheme()` 가 주입한다.
/// - `state=pressed` → 파라미터 아님. `ButtonStyle` 의 `configuration.isPressed` 로 감지한다.
/// - `state=disabled` → SwiftUI 관용대로 `.disabled(_:)` modifier
/// - `left icon` / `left icon-3d` → `leadingIcon` 하나. 둘은 크기가 같고 에셋만 다르다.
///
/// - Parameters:
///   - leadingIcon: 20pt 로 그려진다. 평면 아이콘과 3D 아이콘 모두 여기로 넘긴다.
///   - trailingIcon: 16pt 로 그려진다.
public struct BCPButton: View {
    private let title: String
    private let type: BCPButtonType
    private let size: BCPButtonSize
    private let width: BCPButtonWidth
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let action: () -> Void

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: String,
        type: BCPButtonType = .primary,
        size: BCPButtonSize = .large,
        width: BCPButtonWidth = .hug,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.size = size
        self.width = width
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.action = action
    }

    public var body: some View {
        let m = size.metrics
        return Button(action: action) {
            HStack(spacing: m.gap) {
                // 아이콘은 장식이다 — 버튼 이름은 title 이 맡는다. 숨기지 않으면 VoiceOver 가
                // 에셋 이름까지 읽어 "이미지, 확인, 버튼" 처럼 들린다.
                leadingIcon?
                    .resizable()
                    .frame(width: BCPButtonIconSize.leading, height: BCPButtonIconSize.leading)
                    .accessibilityHidden(true)
                Text(title)
                    .bcpTextStyle(m.textStyle)
                    .lineLimit(1)
                    .truncationMode(.tail)
                trailingIcon?
                    .resizable()
                    .frame(width: BCPButtonIconSize.trailing, height: BCPButtonIconSize.trailing)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(
            BCPButtonStyle(
                metrics: m,
                width: width,
                palette: type.palette(theme.component, enabled: isEnabled),
                pressedOverlay: theme.component.buttonPressed,
                enabled: isEnabled
            )
        )
    }
}

/// Figma 에서 `xlarge` 만 높이 FIXED 56 이고 나머지는 세로 패딩으로 높이가 결정된다.
/// 고정 높이 세트는 `.frame(height:)`, 나머지는 `minHeight` 로 내용에 따라 늘어난다.
private struct BCPButtonHeight: ViewModifier {
    let metrics: BCPButtonMetrics

    func body(content: Content) -> some View {
        if metrics.fixedHeight {
            content.frame(height: metrics.height)
        } else {
            content.frame(minHeight: metrics.height)
        }
    }
}

/// 표면(`background`)보다 먼저 적용해야 채운 폭이 그대로 배경이 된다.
private struct BCPButtonWidthLayout: ViewModifier {
    let width: BCPButtonWidth

    @ViewBuilder
    func body(content: Content) -> some View {
        switch width {
        case .hug:
            content
        case .fill:
            content.frame(maxWidth: .infinity)
        }
    }
}

private struct BCPButtonStyle: ButtonStyle {
    let metrics: BCPButtonMetrics
    let width: BCPButtonWidth
    let palette: BCPButtonPalette
    let pressedOverlay: Color
    let enabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(palette.content)
            .padding(.horizontal, metrics.horizontalPadding)
            .padding(.vertical, metrics.verticalPadding)
            .modifier(BCPButtonHeight(metrics: metrics))
            .modifier(BCPButtonWidthLayout(width: width))
            .background(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .fill(palette.surface)
            )
            // pressed 는 표면 색 교체가 아니라 오버레이 1장이다 (Figma fills 2장 구조).
            // `.background` 를 두 번 쌓으면 뒤로 밀려 불투명 표면에 가려지므로 `.overlay` 여야 한다.
            .overlay(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .fill(enabled && configuration.isPressed ? pressedOverlay : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .strokeBorder(palette.border ?? .clear, lineWidth: palette.border == nil ? 0 : BCPDimens.border1)
            )
            .contentShape(RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous))
    }
}
