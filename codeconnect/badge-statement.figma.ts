// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=49409-14261&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Badge/BCPStatementBadge.swift
// component=BCPStatementBadge

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// 생성기에 배지가 들어가면 이 파일은 그쪽 산출물로 대체된다.
// Figma 세트 'badge-statement' (49409:14261) · variant 34개 (size 2 × type 17)
import figma from 'figma'

const instance = figma.selectedInstance

const size = instance.getEnum('size', {
    "large": ".large",
    "small": ".small",
  })
const type = instance.getEnum('type', {
    "family": ".family",
    "top": ".top",
    "company-1": ".company1",
    "company-2": ".company2",
    "woori": ".woori",
    "goal-OK": ".goalOK",
    "QR": ".qr",
    "confirm": ".confirm",
    "undetermined": ".undetermined",
    "property": ".property",
    "onnuri": ".onnuri",
    "openapp": ".openApp",
    "openpay": ".openPay",
    "charge-OK": ".chargeOK",
    "error-1": ".error1",
    "error-2": ".error2",
    "isp": ".isp",
  })

// 텍스트 레이어 이름이 variant 마다 다르다 — Badge Text / Text / Badge text / Badge Label /
// Label / Error Message 6종. 이름으로 찾으면 대부분의 variant 에서 놓치므로
// 첫 텍스트 레이어의 내용을 쓴다.
const textLayers = instance.findLayers((node) => node.type === 'TEXT')
const label = textLayers.length > 0 ? textLayers[0].textContent : ''

export default {
  example: figma.code`
BCPStatementBadge("${label}", type: ${type}, size: ${size})
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-statement-badge',
  metadata: { nestable: true },
}
