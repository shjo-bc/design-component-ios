// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=2080-22357&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Button/BCPButton.swift
// component=BCPButton

// 자동 생성: node tools/scripts/gen-button-templates.mjs
// Figma 세트 'small' (2080:22357) · variant 120개
// 인스턴스 프로퍼티 철자: icon, icon-3d, Label
import figma from 'figma'

const instance = figma.selectedInstance

const label = instance.getString("Label")
const type = instance.getEnum('type', {
    "primary": ".primary",
    "secondary": ".secondary",
    "outlined-1": ".outlined",
    "outlined-2": ".outlinedSubtle",
    "gradient": "/* gradient 타입은 SwiftUI 구현에 아직 없습니다 */",
  })
// state=pressed 는 런타임 상태라 코드 prop 이 아니다 (docs/naming-contract.md §2)
const enabled = instance.getEnum('state', {
    "normal": true,
    "pressed": true,
    "disabled": false,
  })
const disabledModifier = figma.code`${enabled ? '' : '.disabled(true)'}`

const hasLeading = instance.getEnum('left icon', { 'true': true, 'false': false }) || instance.getEnum('left icon-3d', { 'true': true, 'false': false })
const hasTrailing = instance.getEnum('right icon', { 'true': true, 'false': false })

const example =
  !hasLeading && !hasTrailing ? figma.code`
BCPButton(
    "${label}",
    type: ${type},
    size: .small
) {
    // action
}
${disabledModifier}
` :
  !hasLeading && hasTrailing ? figma.code`
BCPButton(
    "${label}",
    type: ${type},
    size: .small,
    trailingIcon: Image("<아이콘>")
) {
    // action
}
${disabledModifier}
` :
  hasLeading && !hasTrailing ? figma.code`
BCPButton(
    "${label}",
    type: ${type},
    size: .small,
    leadingIcon: Image("<아이콘>")
) {
    // action
}
${disabledModifier}
` :
  figma.code`
BCPButton(
    "${label}",
    type: ${type},
    size: .small,
    leadingIcon: Image("<아이콘>"),
    trailingIcon: Image("<아이콘>")
) {
    // action
}
${disabledModifier}
`

export default {
  example,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-button-small',
}
