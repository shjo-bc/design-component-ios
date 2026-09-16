// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1191-11138&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPBoxTextField.swift
// component=BCPBoxTextField

// 자동 생성: node tools/scripts/gen-select-templates.mjs
// Figma 세트 'box-input-dropdown' (1191:11138) · variant 10개
import figma from 'figma'

const instance = figma.selectedInstance

// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2).
// filled·focused·normal 은 런타임 상태라 매핑하지 않는다.
const enabled = instance.getEnum('state', {
    "disabled": false,
    "filled": true,
    "focused": true,
    "invalid": true,
    "normal": true,
  })
const validationKey = instance.getEnum('state', {
    "disabled": null,
    "filled": null,
    "focused": null,
    "invalid": "invalid",
    "normal": null,
  })
const validation = validationKey ? {"invalid":".invalid","valid":".valid"}[validationKey] : null
const placeholder = instance.getString("placehorder")

const validationLine = validation ? `,\n    validation: ${validation}` : ''
const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPBoxTextField(
    text: $text,
    type: .dropdown,
    placeholder: "${placeholder}"${validationLine},
    onTap: { }
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-box-input-dropdown',
}
