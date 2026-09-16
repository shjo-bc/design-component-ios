// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=7575-1370&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPBoxTextField.swift
// component=BCPBoxTextField

// 자동 생성: node tools/scripts/gen-largeinput-templates.mjs
// Figma 세트 'box-input-amount-large' (7575:1370) · variant 14개
import figma from 'figma'

const instance = figma.selectedInstance

// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2).
const enabled = instance.getEnum('state', {
    "disabled": false,
    "filled": true,
    "focused": true,
    "invalid": true,
    "normal": true,
    "typing": true,
    "valid": true,
  })
const validationKey = instance.getEnum('state', {
    "disabled": null,
    "filled": null,
    "focused": null,
    "invalid": "invalid",
    "normal": null,
    "typing": null,
    "valid": "valid",
  })
const validation = validationKey ? {"invalid":".invalid","valid":".valid"}[validationKey] : null
const placeholder = instance.getString("placeholder")
const showHelper = instance.getBoolean("show helpertxt")
const unit = instance.getString("unit")

const helperLine = showHelper ? figma.code`,\n    helperText: "Text"` : ''
const unitLine = figma.code`,\n    unit: "${unit}"`
const validationLine = validation ? `,\n    validation: ${validation}` : ''
const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPBoxTextField(
    text: $text,
    type: .amountLarge,
    placeholder: "${placeholder}"${helperLine}${unitLine}${validationLine}
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-box-input-amount-large',
}
