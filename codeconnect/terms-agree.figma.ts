// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=2820-3466&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Terms/BCPTermsAgree.swift
// component=BCPTermsAgree

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'terms_agree' (2820:3466) · variant 8개
import figma from 'figma'

const instance = figma.selectedInstance

// mode(light/dark) 축은 옮기지 않는다 — 두 변형이 부르는 토큰이 같고 모드는 테마가 정한다.
const selected = instance.getEnum('selected', {
    "true": true,
    "false": false,
  })
const size = instance.getEnum('size', {
    "large": ".large",
    "small": ".small",
  })

export default {
  example: figma.code`
BCPTermsAgree("페이북 약관 모두 동의", selected: ${selected}, size: ${size}) { _ in }
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-terms-agree',
}
