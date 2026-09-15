// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1137-28940&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Input/BCPTextField.swift
// component=BCPTextField

// 자동 생성: node tools/scripts/gen-input-templates.mjs
// Figma 세트 'box-input-basic' (1137:28940) · variant 42개
import figma from 'figma'

const instance = figma.selectedInstance

const kind = instance.getEnum('type', {
    "basic": "basic",
    "basic-amount": "amount",
    "multiline": "multiline",
  })
const type = {"basic":".basic","amount":".amount","multiline":".multiline"}[kind]
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
const unit = instance.getString("unit")
// ⚠ BOOLEAN 인스턴스 프로퍼티다. 실제 Figma 서버에서의 getBoolean 동작은 아직 publish 로
// 확인하지 못했다 (원본 파일 publish 권한 없음). 스니펫이 이상하면 여기부터 의심할 것.
const showHelper = instance.getBoolean("show helpertxt")

const helperLine = showHelper ? figma.code`,\n    helperText: "${helperText}"` : ''
const unitLine = kind === 'amount' ? figma.code`,\n    unit: "${unit}"` : ''
const maxLine = kind === 'multiline' ? ',\n    maxLength: 1000' : ''
const validationLine = validation ? `,\n    validation: ${validation}` : ''
const disabledModifier = enabled ? '' : '\n.disabled(true)'

export default {
  example: figma.code`
BCPTextField(
    text: $text,
    type: ${type},
    placeholder: "${placeholder}"${helperLine}${unitLine}${maxLine}${validationLine}
)${disabledModifier}`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-box-input-basic',
}
