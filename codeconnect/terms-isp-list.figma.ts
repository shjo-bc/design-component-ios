// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=50165-528&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Terms/BCPTermsISPListItem.swift
// component=BCPTermsISPListItem

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'terms_isp_list' (50165:528) · variant 12개
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

const leaf = figma.code`
BCPTermsSubItemRow(style: .isp) {
    BCPTermsISPListItem("휴대전화", depth: .depth3, selected: ${selected}) { _ in }
    BCPTermsISPListItem("모바일 메세지(SMS 등)", depth: .depth3, selected: ${selected}) { _ in }
}
`
const row = figma.code`
BCPTermsISPListItem("약관내용", depth: ${depth}, selected: ${selected}, onChange: { _ in }, onDetail: { })
`

export default {
  example: isLeaf ? leaf : row,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-terms-isp-list-item',
}
