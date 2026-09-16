// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=6723-2201&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPSearchBar.swift
// component=BCPSearchBar

// 자동 생성: node tools/scripts/gen-search-templates.mjs
// Figma 세트 'searchbar-2' (6723:2201) · variant 16개
import figma from 'figma'

const instance = figma.selectedInstance

// state 4개(normal·focused·typing·filled)는 전부 런타임 상태라 매핑하지 않는다.
// 이 세트에는 disabled·invalid·valid variant 가 없다.
const showCancel = instance.getEnum('show cancel', {
    "off": false,
    "on": true,
  })

const cancelLine = showCancel ? ',\n    onCancel: { }' : ''

export default {
  example: figma.code`
BCPSearchBar(
    text: $text,
    style: .style2,
    placeholder: "검색어를 입력하세요"${cancelLine}
)`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-searchbar-2',
}
