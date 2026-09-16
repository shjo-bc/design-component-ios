// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1192-12257&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPLineTextField.swift
// component=BCPLineTextField

// 자동 생성: node tools/scripts/gen-line-templates.mjs
// Figma 세트 'line-input-basic' (1192:12257) · variant 14개
import figma from 'figma'

const instance = figma.selectedInstance

// state=disabled 는 코드에서 enabled/.disabled() 로, invalid·valid 는 validation 으로 표현한다
// (docs/naming-contract.md §2). focused·typing·filled·normal 은 런타임 상태라 매핑하지 않는다.
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
const helperText = instance.getString("helper txt")
const showHelper = instance.getBoolean("show helpertxt")
const showLabel = instance.getBoolean("show label")

const labelLine = showLabel ? ',\n    label: "Lable"' : ''
const helperLine = showHelper ? figma.code`,\n    helperText: "${helperText}"` : ''
const validationLine = validation ? `,\n    validation: ${validation}` : ''
const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPLineTextField(
    text: $text${labelLine},
    placeholder: "${placeholder}"${helperLine}${validationLine}
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-line-input-basic',
}
