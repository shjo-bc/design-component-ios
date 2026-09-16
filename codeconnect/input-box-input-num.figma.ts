// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=7682-1610&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPBoxTextField.swift
// component=BCPBoxTextField

// 자동 생성: node tools/scripts/gen-largeinput-templates.mjs
// Figma 세트 'box-input-num' (7682:1610) · variant 20개
import figma from 'figma'

const instance = figma.selectedInstance

// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2).
const enabled = instance.getEnum('state', {
    "filled": true,
    "focused": true,
    "invalid": true,
    "normal": true,
    "nromal": true,
    "typing": true,
  })
const validationKey = instance.getEnum('state', {
    "filled": null,
    "focused": null,
    "invalid": "invalid",
    "normal": null,
    "nromal": null,
    "typing": null,
  })
const validation = validationKey ? {"invalid":".invalid","valid":".valid"}[validationKey] : null
const placeholder = instance.getString("placeholder")
const helperText = instance.getString("help text")
const showHelper = instance.getBoolean("Show Helper text")
const showButton = instance.getEnum("Showbutton", {
    "off": false,
    "on": true,
  })

const helperLine = showHelper ? figma.code`,\n    helperText: "${helperText}"` : ''
const validationLine = validation ? `,\n    validation: ${validation}` : ''
const buttonLine = showButton ? ',\n    buttonTitle: "확인",\n    onButtonTap: { }' : ''
const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPBoxTextField(
    text: $text,
    type: .number,
    placeholder: "${placeholder}"${helperLine}${validationLine}${buttonLine}
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-box-input-num',
}
