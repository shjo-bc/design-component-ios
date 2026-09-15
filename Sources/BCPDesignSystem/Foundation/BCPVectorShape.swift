import SwiftUI

/// Figma `fillGeometry` 가 주는 SVG path 를 SwiftUI `Path` 로 옮긴다.
/// 경로 자체는 `BCPVectorPaths` 가 들고 있다 (자동 생성).
///
/// Figma 가 내보내는 명령은 절대좌표 `M` / `L` / `C` / `Z` 뿐이다 (실측 확인).
/// 범용 SVG 파서가 아니다 — 그 이상이 필요해지면 여기서 넓히고 테스트를 붙일 것.
/// Compose 쪽은 `PathParser` 가 표준으로 있어서 이 대역이 필요 없다.
struct BCPVectorParser {
    let commands: [Command]

    enum Command {
        case move(CGPoint)
        case line(CGPoint)
        case curve(to: CGPoint, c1: CGPoint, c2: CGPoint)
        case close
    }

    init?(_ d: String) {
        var commands: [Command] = []
        let scanner = Scanner(string: d)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: " ,\n\t")

        func number() -> CGFloat? {
            guard let v = scanner.scanDouble() else { return nil }
            return CGFloat(v)
        }
        func point() -> CGPoint? {
            guard let x = number(), let y = number() else { return nil }
            return CGPoint(x: x, y: y)
        }

        while !scanner.isAtEnd {
            guard let op = scanner.scanCharacter() else { break }
            switch op {
            case "M":
                guard let p = point() else { return nil }
                commands.append(.move(p))
            case "L":
                guard let p = point() else { return nil }
                commands.append(.line(p))
            case "C":
                guard let c1 = point(), let c2 = point(), let p = point() else { return nil }
                commands.append(.curve(to: p, c1: c1, c2: c2))
            case "Z", "z":
                commands.append(.close)
            default:
                // 예상치 못한 명령은 조용히 무시하지 않는다 — 잘못 그려지느니 실패가 낫다.
                return nil
            }
        }
        guard !commands.isEmpty else { return nil }
        self.commands = commands
    }

    /// `size` 크기의 박스에 맞춰 그린다. 경로는 `viewBox` 좌표계 기준이다.
    func path(in rect: CGRect, viewBox: CGSize) -> Path {
        let sx = viewBox.width == 0 ? 1 : rect.width / viewBox.width
        let sy = viewBox.height == 0 ? 1 : rect.height / viewBox.height
        func t(_ p: CGPoint) -> CGPoint { CGPoint(x: rect.minX + p.x * sx, y: rect.minY + p.y * sy) }

        var path = Path()
        for c in commands {
            switch c {
            case .move(let p): path.move(to: t(p))
            case .line(let p): path.addLine(to: t(p))
            case .curve(let p, let c1, let c2): path.addCurve(to: t(p), control1: t(c1), control2: t(c2))
            case .close: path.closeSubpath()
            }
        }
        return path
    }
}

/// 벡터 경로를 그리는 Shape.
public struct BCPVectorShape: Shape {
    private let source: BCPVectorSource

    public init(_ source: BCPVectorSource) {
        self.source = source
    }

    public func path(in rect: CGRect) -> Path {
        guard let parsed = BCPVectorParser(source.d) else { return Path() }
        return parsed.path(in: rect, viewBox: source.viewBox)
    }
}
