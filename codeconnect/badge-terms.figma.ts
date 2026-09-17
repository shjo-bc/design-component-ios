// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=49409-14260&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Badge/BCPTermsBadge.swift
// component=BCPTermsBadge

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'badge-terms' (49409:14260) · variant 5개
import figma from 'figma'

const instance = figma.selectedInstance

// 등급 문구(안심·다소안심·보통·신중·주의)는 컴포넌트가 갖는다 — 텍스트를 넘기지 않는다.
const level = instance.getEnum('Property 1', {
    "1": ".level1",
    "2": ".level2",
    "3": ".level3",
    "4": ".level4",
    "5": ".level5",
  })

export default {
  example: figma.code`
BCPTermsBadge(level: ${level})
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-terms-badge',
  metadata: { nestable: true },
}
