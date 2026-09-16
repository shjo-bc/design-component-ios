// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=7953-2347&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPBoxTextField.swift
// component=BCPBoxTextField

// 자동 생성: node tools/scripts/gen-largeinput-templates.mjs
// Figma 세트 'box-input-card-num' (7953:2347) · variant 8개
import figma from 'figma'

const instance = figma.selectedInstance

// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2).
const enabled = instance.getEnum('state', {
    "filled": true,
    "focused": true,
    "normal": true,
    "typing": true,
  })
const placeholder = instance.getString("placeholder")
const helperText = instance.getString("help text")
const showHelper = instance.getBoolean("Show Helper text")

const helperLine = showHelper ? figma.code`,\n    helperText: "${helperText}"` : ''
const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPBoxTextField(
    text: $text,
    type: .cardNumber,
    placeholder: "${placeholder}"${helperLine}
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-box-input-card-num',
}
