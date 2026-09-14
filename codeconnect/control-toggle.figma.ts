// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1430-44636&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Control/BCPToggle.swift
// component=BCPToggle

// 자동 생성: node tools/scripts/gen-control-templates.mjs
// Figma 세트 'toggle' (1430:44636) · variant 4개
import figma from 'figma'

const instance = figma.selectedInstance

const checked = instance.getEnum('state', {
    "off": false,
    "on": true,
  })
// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2)
const enabled = instance.getEnum('state', {
    "off": true,
    "on": true,
  })
const disabledModifier = figma.code`${enabled ? '' : '.disabled(true)'}`

export default {
  example: figma.code`
BCPToggle(isOn: ${checked}) { _ in }
${disabledModifier}
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-toggle',
}
