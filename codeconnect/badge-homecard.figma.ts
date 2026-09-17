// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=49409-14329&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Badge/BCPHomeCardBadge.swift
// component=BCPHomeCardBadge

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'badge-homecard' (49409:14329) · variant 8개
import figma from 'figma'

const instance = figma.selectedInstance

// ⚠ 'company' variant 의 실제 이름은 앞에 백스페이스 문자(U+0008)가 붙은 '\bcompany' 다.
// Figma 에서 이름을 편집하다 들어간 제어문자로 보이며, 철자를 그대로 맞추지 않으면 매핑이 빈다.
const type = instance.getEnum('type', {
    "price": ".price",
    "count": ".count",
    "openapp": ".openApp",
    "woori": ".woori",
    "\bcompany": ".company",
    "isp": ".isp",
    "dday": ".dday",
    "error": ".error",
  })

const txt = instance.findText('txt')
const label = txt && txt.type === 'TEXT' ? txt.textContent : ''

export default {
  example: figma.code`
BCPHomeCardBadge("${label}", type: ${type})
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-homecard-badge',
  metadata: { nestable: true },
}
