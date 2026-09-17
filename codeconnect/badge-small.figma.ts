// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=49409-14313&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Badge/BCPSmallBadge.swift
// component=BCPSmallBadge

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'badge-small' (49409:14313) · variant 8개
import figma from 'figma'

const instance = figma.selectedInstance

// 문구(NEW·ON·OFF)는 컴포넌트가 갖는다 — 텍스트를 넘기지 않는다.
const type = instance.getEnum('type', {
    "new": ".new",
    "on": ".on",
    "off": ".off",
  })

// Figma 의 light-mode / dark-mode 는 디자이너가 모드를 수동으로 바꿔 보는 축이다.
// 코드에서는 테마가 모드를 처리하므로 둘 다 .neutral 하나로 접는다.
const style = instance.getEnum('color', {
    "1": ".tint",
    "2": ".solid",
    "light-mode": ".neutral",
    "dark-mode": ".neutral",
  })

// off 는 Figma 에 회색으로만 있고 코드도 style 을 무시한다 — 인자를 붙이지 않는다.
const example = type === '.off'
  ? figma.code`
BCPSmallBadge(.off)
`
  : figma.code`
BCPSmallBadge(${type}, style: ${style})
`

export default {
  example,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-small-badge',
  metadata: { nestable: true },
}
