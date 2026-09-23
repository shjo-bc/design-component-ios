// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=2852-11740&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Terms/BCPTermsListItem.swift
// component=BCPTermsListItem

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'terms_list' (2852:11740) · variant 12개
import figma from 'figma'

const instance = figma.selectedInstance

// mode(light/dark) 축은 옮기지 않는다 — 두 변형이 부르는 토큰이 같고 모드는 테마가 정한다.
const selected = instance.getEnum('selected', {
    "true": true,
    "false": false,
  })
const depth = instance.getEnum('type', {
    "1depth": ".depth1",
    "2depth": ".depth2",
    "3depth": ".depth3",
  })
const isLeaf = instance.getEnum('type', {
    "1depth": false,
    "2depth": false,
    "3depth": true,
  })
// 인스턴스 프로퍼티 '2depht_badge' (Figma 오타 그대로). Figma 예시 배지가 '다소안심'(level 2) 이다.
const showBadge = instance.getBoolean('2depht_badge')
const badge = figma.code`${showBadge ? ', badge: .level2' : ''}`

const leaf = figma.code`
BCPTermsSubItemRow(style: .list) {
    BCPTermsListItem("휴대전화", depth: .depth3, selected: ${selected}) { _ in }
    BCPTermsListItem("모바일 메세지(SMS 등)", depth: .depth3, selected: ${selected}) { _ in }
}
`
const row = figma.code`
BCPTermsListItem("약관내용", depth: ${depth}, selected: ${selected}${badge}, onChange: { _ in }, onDetail: { })
`

export default {
  example: isLeaf ? leaf : row,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-terms-list-item',
}
