// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1430-44507&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Control/BCPCheckbox.swift
// component=BCPCheckbox

// 자동 생성: node tools/scripts/gen-control-templates.mjs
// Figma 세트 'checkbox' (1430:44507) · variant 6개
import figma from 'figma'

const instance = figma.selectedInstance

const checked = instance.getEnum('state', {
    "disabled": false,
    "selected": true,
    "unselected": false,
  })
// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2)
const enabled = instance.getEnum('state', {
    "disabled": false,
    "selected": true,
    "unselected": true,
  })
const disabledModifier = figma.code`${enabled ? '' : '.disabled(true)'}`

export default {
  example: figma.code`
BCPCheckbox(checked: ${checked}, size: .medium) { _ in }
${disabledModifier}
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-checkbox',
}
