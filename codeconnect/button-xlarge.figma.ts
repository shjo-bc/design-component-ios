// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1103-23604&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Button/BCPButton.swift
// component=BCPButton

// 자동 생성: node tools/scripts/gen-button-templates.mjs
// Figma 세트 'xlarge' (1103:23604) · variant 74개
// 인스턴스 프로퍼티 철자: icon, Label
// ⚠ 이 세트에는 state=loading 이 있으나 BCPButton 에 loading 파라미터가 없다.
//   현재는 normal 과 같게 렌더된다 — shared/figma/button-style.json 의 deferred 참고.
import figma from 'figma'

const instance = figma.selectedInstance

const label = instance.getString("Label")
const type = instance.getEnum('type', {
    "primary": ".primary",
    "secondary": ".secondary",
    "outlined-1": ".outlined",
    "outlined-2": ".outlinedSubtle",
  })
// state=pressed 는 런타임 상태라 코드 prop 이 아니다 (docs/naming-contract.md §2)
const enabled = instance.getEnum('state', {
    "normal": true,
    "pressed": true,
    "disabled": false,
    "loading": true,
  })
const disabledModifier = figma.code`${enabled ? '' : '.disabled(true)'}`

const hasLeading = instance.getEnum('left icon', { 'true': true, 'false': false })
const hasTrailing = instance.getEnum('right icon', { 'true': true, 'false': false })

const example =
  !hasLeading && !hasTrailing ? figma.code`
BCPButton(
    "${label}",
    type: ${type},
    size: .xlarge
) {
    // action
}
${disabledModifier}
` :
  !hasLeading && hasTrailing ? figma.code`
BCPButton(
    "${label}",
    type: ${type},
    size: .xlarge,
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
    size: .xlarge,
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
    size: .xlarge,
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
  id: 'bcp-button-xlarge',
}
