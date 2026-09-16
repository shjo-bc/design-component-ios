// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1197-19226&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPLineTextField.swift
// component=BCPLineTextField

// 자동 생성: node tools/scripts/gen-select-templates.mjs
// Figma 세트 'line-input-dropdown' (1197:19226) · variant 6개
import figma from 'figma'

const instance = figma.selectedInstance

// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2).
// filled·focused·normal 은 런타임 상태라 매핑하지 않는다.
const enabled = instance.getEnum('state', {
    "disabled": false,
    "filled": true,
    "normal": true,
  })
const placeholder = instance.getString("placeholder")
const label = instance.getString("lable")
const showLabel = instance.getBoolean("Show label")

const labelLine = showLabel ? figma.code`,\n    label: "${label}"` : ''
const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPLineTextField(
    text: $text,
    type: .dropdown${labelLine},
    placeholder: "${placeholder}",
    onTap: { }
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-line-input-dropdown',
}
