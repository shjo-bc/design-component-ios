// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=9498-2205&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Button/BCPButton.swift
// component=BCPButton

// 자동 생성: node tools/scripts/gen-button-templates.mjs
// Figma 세트 'xxlarge' (9498:2205) · variant 24개
// 인스턴스 프로퍼티 철자: 없음
import figma from 'figma'

const instance = figma.selectedInstance

// ⚠ 이 세트에는 텍스트 인스턴스 프로퍼티가 없다 (텍스트가 일반 레이어).
//   스니펫의 문구는 고정값이며 실제 텍스트를 반영하지 못한다.
const label = 'Label'
const type = instance.getEnum('type', {
    "primary": ".primary",
    "outlined-1": ".outlined",
    "yellow": ".isp",
    "purple": ".openApp",
  })
// state=pressed 는 런타임 상태라 코드 prop 이 아니다 (docs/naming-contract.md §2)
const enabled = instance.getEnum('state', {
    "normal": true,
    "pressed": true,
    "disabled": false,
  })
const disabledModifier = figma.code`${enabled ? '' : '.disabled(true)'}`

const example =
  figma.code`
BCPButton(
    "${label}",
    type: ${type},
    size: .xxlarge
) {
    // action
}
${disabledModifier}
`

export default {
  example,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-button-xxlarge',
}
