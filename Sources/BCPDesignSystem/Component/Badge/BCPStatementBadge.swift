import SwiftUI

/// 명세서·카드 목록용 배지의 의미 유형. Figma `badge-statement` 세트의 `type` 축 17종.
///
/// 타입은 **색 역할만** 결정한다. Figma 에는 타입마다 문구가 박혀 있지만(아래 표), 업무 문구를
/// 디자인 시스템이 소유하지 않도록 텍스트는 호출부가 넘긴다.
///
/// | type | Figma 기본 문구 | 색 |
/// |---|---|---|
/// | family / top | 가족 / TOP | badge/3 (red) |
/// | company1 / company2 / woori / goalOK | 법인 / 법인공용 / 우리 / 목표OK | badge/10 (blue) |
/// | qr | QR | badge/9 |
/// | confirm | 확정 | badge/8 (emerald) |
/// | undetermined | 예정 | badge/11 (gray) |
/// | property | 내자산 | badge/6 (yellow) |
/// | onnuri | 온누리 | badge/4 (orange) |
/// | openApp / openPay / chargeOK | 오픈앱 / 오픈페이 / 자동충전ON | badge/1 (violet) |
/// | error1 / error2 | 이용불가 / 교체불가 | badge/2 (pink) |
/// | isp | ISP | badge/5 (yellow) |
public enum BCPStatementBadgeType: Sendable {
    case family, top
    case company1, company2, woori, goalOK
    case qr
    case confirm
    case undetermined
    case property
    case onnuri
    case openApp, openPay, chargeOK
    case error1, error2
    case isp

    var palette: BCPBadgePalette {
        switch self {
        case .family, .top: return .badge3
        case .company1, .company2, .woori, .goalOK: return .badge10
        case .qr: return .badge9
        case .confirm: return .badge8
        case .undetermined: return .badge11
        case .property: return .badge6
        case .onnuri: return .badge4
        case .openApp, .openPay, .chargeOK: return .badge1
        case .error1, .error2: return .badge2
        case .isp: return .badge5
        }
    }
}

/// 명세서 배지 크기. Figma `badge-statement` 세트의 `size` 축.
public enum BCPStatementBadgeSize: Sendable {
    /// 높이 24 — 12pt 볼드(`font-1/paragraph/8-1`), 좌우 8, radius 12
    case large
    /// 높이 18 — 9pt 볼드, 좌우 6, radius 10
    case small
}

/// 페이북 디자인 시스템 명세서 배지.
///
/// ```swift
/// BCPStatementBadge("가족", type: .family, size: .large)
/// ```
public struct BCPStatementBadge: View {
    private let text: String
    private let type: BCPStatementBadgeType
    private let size: BCPStatementBadgeSize

    @Environment(\.bcpTheme) private var theme

    public init(_ text: String, type: BCPStatementBadgeType, size: BCPStatementBadgeSize = .large) {
        self.text = text
        self.type = type
        self.size = size
    }

    public var body: some View {
        let c = theme.component
        switch size {
        case .large:
            BCPBadge(
                text: text,
                surface: type.palette.surface(c),
                foreground: type.palette.text(c),
                // Figma 텍스트 스타일 `Font-1/Paragraph/paragraph-8-bold` — 배지 전용 토큰이 아니라
                // paragraph 계열을 빌려 쓴다. 처음엔 토큰 없이 12/20 실측값이었는데 디자이너가 토큰을
                // 붙이면서 line-height 가 16 으로, 세로 패딩이 2 → 4 로 바뀌었다. 높이 24 는 그대로다.
                textStyle: BCPTypography.font1Paragraph8_1,
                horizontalPadding: BCPDimens.spacing8,
                topPadding: BCPDimens.spacing4,
                bottomPadding: BCPDimens.spacing4,
                // 4 + line-height 16 + 4
                minHeight: 24,
                cornerRadius: BCPDimens.radius12
            )
        case .small:
            BCPBadge(
                text: text,
                surface: type.palette.surface(c),
                foreground: type.palette.text(c),
                textStyle: BCPTypography.font1BadgeSmall1,
                horizontalPadding: BCPDimens.spacing6,
                topPadding: BCPDimens.spacing4,
                bottomPadding: BCPDimens.spacing4,
                // 4 + line-height 10 + 4
                minHeight: 18,
                cornerRadius: BCPDimens.radius10
            )
        }
    }
}

#if DEBUG
struct BCPStatementBadge_Previews: PreviewProvider {
    /// Figma 세트의 variant 순서와 기본 문구를 그대로 따른다.
    private static let samples: [(String, BCPStatementBadgeType)] = [
        ("가족", .family), ("법인", .company1), ("법인공용", .company2), ("TOP", .top),
        ("QR", .qr), ("확정", .confirm), ("예정", .undetermined), ("내자산", .property),
        ("온누리", .onnuri), ("우리", .woori), ("목표OK", .goalOK), ("오픈앱", .openApp),
        ("오픈페이", .openPay), ("이용불가", .error1), ("교체불가", .error2), ("ISP", .isp),
        ("자동충전ON", .chargeOK),
    ]

    private static func row(_ size: BCPStatementBadgeSize) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 4), spacing: 8) {
            ForEach(samples, id: \.0) { text, type in
                BCPStatementBadge(text, type: type, size: size)
            }
        }
    }

    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            VStack(alignment: .leading, spacing: 16) {
                Text("large").font(.caption)
                row(.large)
                Text("small").font(.caption)
                row(.small)
            }
            .padding()
            .bcpTheme()
            .preferredColorScheme(scheme)
            .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
