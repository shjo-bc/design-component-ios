import SwiftUI

/// 버튼 크기. Figma 에서는 size 가 variant 축이 아니라 **컴포넌트 세트가 분리**되어 있고,
/// 세트마다 지원하는 type·state 축이 다르다. 자세한 내용은 `shared/figma/button-style.json`.
public enum BCPButtonSize: Sendable {
    case xsmall, small, medium, large, xlarge, xxlarge
}

/// 버튼 스타일.
///
/// Figma 의 `outlined-1` / `outlined-2` 를 각각 `.outlined` / `.outlinedSubtle` 로 옮겼다
/// (네이밍 계약 §5 매핑표).
///
/// `yellow` / `purple`(xxlarge 전용), `gradient`(small 전용) 는 아직 포함하지 않는다 —
/// 대부분의 사이즈에서 존재하지 않는 조합이라 공통 API 에 넣으면 런타임에만 틀린다.
public enum BCPButtonType: Sendable {
    case primary, secondary, outlined, outlinedSubtle
}

struct BCPButtonMetrics {
    let height: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    let gap: CGFloat
    let fontSize: CGFloat
    let lineHeight: CGFloat
    let fontWeight: Int
}

extension BCPButtonSize {
    var metrics: BCPButtonMetrics {
        switch self {
        case .xsmall:
            return BCPButtonMetrics(
                height: 32,
                horizontalPadding: BCPDimens.spacing10,
                cornerRadius: BCPDimens.radius8,
                gap: BCPDimens.spacing4,
                fontSize: BCPTypographyTokens.font1Paragraph7_1Size,
                lineHeight: BCPTypographyTokens.font1Paragraph7_1LineHeight,
                fontWeight: BCPTypographyTokens.font1Paragraph7_1Weight
            )
        case .small:
            return BCPButtonMetrics(
                height: 40,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius8,
                gap: BCPDimens.spacing6,
                fontSize: BCPTypographyTokens.font1Paragraph6_1Size,
                lineHeight: BCPTypographyTokens.font1Paragraph6_1LineHeight,
                fontWeight: BCPTypographyTokens.font1Paragraph6_1Weight
            )
        case .medium:
            return BCPButtonMetrics(
                height: 44,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius10,
                gap: BCPDimens.spacing6,
                fontSize: BCPTypographyTokens.font1Paragraph5_1Size,
                lineHeight: BCPTypographyTokens.font1Paragraph5_1LineHeight,
                fontWeight: BCPTypographyTokens.font1Paragraph5_1Weight
            )
        case .large:
            return BCPButtonMetrics(
                height: 48,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius12,
                gap: BCPDimens.spacing6,
                fontSize: BCPTypographyTokens.font1Paragraph3_1Size,
                lineHeight: BCPTypographyTokens.font1Paragraph3_1LineHeight,
                fontWeight: BCPTypographyTokens.font1Paragraph3_1Weight
            )
        case .xlarge:
            return BCPButtonMetrics(
                height: 56,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius16,
                gap: BCPDimens.spacing6,
                fontSize: BCPTypographyTokens.font1Paragraph2_1Size,
                lineHeight: BCPTypographyTokens.font1Paragraph2_1LineHeight,
                fontWeight: BCPTypographyTokens.font1Paragraph2_1Weight
            )
        case .xxlarge:
            return BCPButtonMetrics(
                height: 64,
                horizontalPadding: BCPDimens.spacing16,
                cornerRadius: BCPDimens.radius16,
                gap: BCPDimens.spacing10,
                fontSize: BCPTypographyTokens.font1Subheading1_1Size,
                lineHeight: BCPTypographyTokens.font1Subheading1_1LineHeight,
                fontWeight: BCPTypographyTokens.font1Subheading1_1Weight
            )
        }
    }
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
    private let size: BCPButtonSize
    private let type: BCPButtonType
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let action: () -> Void

    @Environment(\.bcpTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init(
        _ title: String,
        size: BCPButtonSize = .large,
        type: BCPButtonType = .primary,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.size = size
        self.type = type
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.action = action
    }

    public var body: some View {
        let m = size.metrics
        return Button(action: action) {
            HStack(spacing: m.gap) {
                leadingIcon?
                    .resizable()
                    .frame(width: BCPButtonIconSize.leading, height: BCPButtonIconSize.leading)
                Text(title)
                    .font(BCPFont.font(size: m.fontSize, weight: m.fontWeight))
                    .lineLimit(1)
                    .truncationMode(.tail)
                trailingIcon?
                    .resizable()
                    .frame(width: BCPButtonIconSize.trailing, height: BCPButtonIconSize.trailing)
            }
        }
        .buttonStyle(
            BCPButtonStyle(
                metrics: m,
                palette: type.palette(theme.component, enabled: isEnabled),
                pressedOverlay: theme.component.buttonPressed,
                enabled: isEnabled
            )
        )
    }
}

private struct BCPButtonStyle: ButtonStyle {
    let metrics: BCPButtonMetrics
    let palette: BCPButtonPalette
    let pressedOverlay: Color
    let enabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(palette.content)
            .padding(.horizontal, metrics.horizontalPadding)
            .frame(minHeight: metrics.height)
            .background(
                RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
                    .fill(palette.surface)
            )
            // pressed 는 표면 색 교체가 아니라 오버레이 1장이다 (Figma fills 2장 구조).
            .background(
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
