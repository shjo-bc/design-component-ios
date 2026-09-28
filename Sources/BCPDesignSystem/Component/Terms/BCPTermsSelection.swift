/// 약관 동의 묶음의 선택 상태. 상위 체크와 하위 체크를 서로 이어 준다.
///
/// - 상위를 체크하거나 풀면 그 아래 항목이 전부 같은 값이 된다.
/// - 하위가 전부 체크되면 상위도 체크된 것으로 보이고, 하나라도 풀리면 상위도 풀린다.
///
/// **맨 아래 항목(잎)의 상태만 저장한다.** 상위의 상태는 저장하지 않고 매번 잎에서 계산한다.
/// 그래서 두 방향을 따로 맞춰 줄 필요가 없고, 어긋난 상태가 생길 수 없다. 전체 동의 →
/// 1depth → 2depth → 3depth 처럼 여러 단계가 겹쳐도 같은 규칙이다.
///
/// 뷰가 아니라 값이다. `@State` 에 넣어도 되고 뷰 모델이 들고 있어도 된다. 뷰에는 계산한
/// 값만 넘긴다.
///
/// ```swift
/// @State private var terms = BCPTermsSelection([
///     .init("service", children: [.init("card"), .init("privacy")]),
///     .init("marketing", children: [.init("phone"), .init("sms")]),
/// ])
///
/// BCPTermsAgree("페이북 약관 모두 동의", selected: terms.isAllSelected) { terms.setAll($0) }
/// BCPTermsListItem("페이북 서비스 이용 약관 (필수)", depth: .depth1,
///                  selected: terms.isSelected("service")) { terms.set("service", $0) }
/// BCPTermsListItem("[1] 카드 · 금융상품 이용 안내", depth: .depth2,
///                  selected: terms.isSelected("card")) { terms.set("card", $0) }
/// ```
///
/// 체크가 없는 약관(안내만 하는 항목)은 동의 대상이 아니므로 여기 넣지 않는다.
///
/// 하위가 일부만 체크된 상위는 **미선택으로 보인다**. Figma 에 "일부 선택" 모양이 없어서다.
/// 구분이 필요해지면 `isPartiallySelected(_:)` 로 알 수 있다.
public struct BCPTermsSelection<ID: Hashable>: Equatable {
    /// 묶음 구조의 한 칸. 자식이 없으면 잎이다.
    public struct Node {
        public let id: ID
        public let children: [Node]

        public init(_ id: ID, children: [Node] = []) {
            self.id = id
            self.children = children
        }
    }

    /// 항목마다 그 아래 잎 목록. 잎은 자기 자신 하나다.
    private let leavesOf: [ID: [ID]]
    /// 전체 잎. 선언 순서를 지킨다.
    private let allLeaves: [ID]
    /// 체크된 잎.
    public private(set) var selectedLeaves: Set<ID>

    /// - Parameters:
    ///   - nodes: 묶음 구조. 같은 id 가 두 번 나오면 멈춘다 — 어느 칸을 말하는지 알 수 없어서다.
    ///   - selected: 처음부터 체크돼 있을 항목. 상위 id 를 주면 그 아래가 전부 체크된다.
    public init(_ nodes: [Node], selected: Set<ID> = []) {
        var leavesOf: [ID: [ID]] = [:]
        var allLeaves: [ID] = []

        @discardableResult
        func visit(_ node: Node) -> [ID] {
            precondition(leavesOf[node.id] == nil, "BCPTermsSelection: id 가 중복됐다 — \(node.id)")
            let leaves: [ID]
            if node.children.isEmpty {
                leaves = [node.id]
                allLeaves.append(node.id)
            } else {
                leaves = node.children.flatMap { visit($0) }
            }
            leavesOf[node.id] = leaves
            return leaves
        }
        nodes.forEach { visit($0) }

        self.leavesOf = leavesOf
        self.allLeaves = allLeaves
        self.selectedLeaves = Set(selected.flatMap { leavesOf[$0] ?? [] })
    }

    /// 이 항목이 체크된 것으로 보이는가. 상위면 그 아래가 전부 체크됐을 때만 `true` 다.
    ///
    /// 모르는 id 는 `false` 다. 구조에 없는 항목은 동의한 것이 아니다.
    public func isSelected(_ id: ID) -> Bool {
        guard let leaves = leavesOf[id], !leaves.isEmpty else { return false }
        return leaves.allSatisfy(selectedLeaves.contains)
    }

    /// 아래 항목 중 일부만 체크됐는가. 잎은 항상 `false` 다.
    public func isPartiallySelected(_ id: ID) -> Bool {
        guard let leaves = leavesOf[id], leaves.count > 1 else { return false }
        let count = leaves.filter(selectedLeaves.contains).count
        return count > 0 && count < leaves.count
    }

    /// 전체가 체크됐는가. 전체 동의 상자에 넘긴다.
    public var isAllSelected: Bool {
        !allLeaves.isEmpty && allLeaves.allSatisfy(selectedLeaves.contains)
    }

    /// 이 항목을 체크하거나 푼다. 상위면 그 아래가 전부 같은 값이 된다.
    public mutating func set(_ id: ID, _ selected: Bool) {
        guard let leaves = leavesOf[id] else {
            assertionFailure("BCPTermsSelection: 구조에 없는 id — \(id)")
            return
        }
        if selected {
            selectedLeaves.formUnion(leaves)
        } else {
            selectedLeaves.subtract(leaves)
        }
    }

    /// 전체를 체크하거나 푼다. 전체 동의 상자의 `onChange` 에 넘긴다.
    public mutating func setAll(_ selected: Bool) {
        selectedLeaves = selected ? Set(allLeaves) : []
    }
}

extension BCPTermsSelection: Sendable where ID: Sendable {}
extension BCPTermsSelection.Node: Sendable where ID: Sendable {}

#if DEBUG
import SwiftUI

/// 전체 동의 · 1depth · 2depth · 3depth 가 서로 이어지는지 눌러서 확인한다.
struct BCPTermsSelection_Previews: PreviewProvider {
    struct Demo: View {
        @State var terms: BCPTermsSelection<String>
        @State private var expanded = true

        init(selected: Set<String> = []) {
            _terms = State(initialValue: BCPTermsSelection([
                .init("service", children: [.init("card"), .init("privacy")]),
                .init("marketing", children: [.init("phone"), .init("sms")]),
            ], selected: selected))
        }

        var body: some View {
            VStack(spacing: 0) {
                BCPTermsAgreeAccordion("페이북 약관 모두 동의", selected: terms.isAllSelected,
                                       isExpanded: expanded,
                                       onChange: { terms.setAll($0) },
                                       onToggleExpanded: { expanded.toggle() })
                    .padding(.bottom, 8)
                if expanded {
                    BCPTermsListItem("페이북 서비스 이용 약관 (필수)", depth: .depth1,
                                     selected: terms.isSelected("service"),
                                     onChange: { terms.set("service", $0) }, onDetail: {})
                    BCPTermsListItem("[1] 카드 · 금융상품 이용 안내", depth: .depth2,
                                     selected: terms.isSelected("card"), badge: .level2,
                                     onChange: { terms.set("card", $0) }, onDetail: {})
                    BCPTermsListItem("[2] 개인정보 수집 · 이용 동의", depth: .depth2,
                                     selected: terms.isSelected("privacy"),
                                     onChange: { terms.set("privacy", $0) }, onDetail: {})
                    BCPTermsListItem("개인정보 처리방침 안내", depth: .depth2, onDetail: {})
                    BCPTermsListItem("마케팅 정보 수신 동의 (선택)", depth: .depth1,
                                     selected: terms.isSelected("marketing"),
                                     onChange: { terms.set("marketing", $0) }, onDetail: {})
                    BCPTermsSubItemRow(style: .list) {
                        BCPTermsListItem("휴대전화", depth: .depth3,
                                         selected: terms.isSelected("phone")) { terms.set("phone", $0) }
                        BCPTermsListItem("모바일 메세지(SMS 등)", depth: .depth3,
                                         selected: terms.isSelected("sms")) { terms.set("sms", $0) }
                    }
                }
            }
            .frame(width: 320)
        }
    }

    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            Demo()
                .padding()
                .bcpTheme()
                .preferredColorScheme(scheme)
                .previewLayout(.sizeThatFits)
                .previewDisplayName(scheme == .light ? "Light · 눌러서 연계 확인" : "Dark · 눌러서 연계 확인")
        }
    }
}
#endif
