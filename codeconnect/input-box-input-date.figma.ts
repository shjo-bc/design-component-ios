// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=4822-6863&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPBoxTextField.swift
// component=BCPBoxTextField

// 자동 생성: node tools/scripts/gen-select-templates.mjs
// Figma 세트 'box-input-date' (4822:6863) · variant 6개
import figma from 'figma'

const instance = figma.selectedInstance

// state=disabled 는 코드에서 enabled/.disabled() 로 표현한다 (docs/naming-contract.md §2).
// filled·focused·normal 은 런타임 상태라 매핑하지 않는다.
const enabled = instance.getEnum('state', {
    "disabled": false,
    "filled": true,
    "normal": true,
  })
const placeholder = instance.getString("Date")

const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPBoxTextField(
    text: $text,
    type: .date,
    placeholder: "${placeholder}",
    onTap: { }
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-box-input-date',
}
