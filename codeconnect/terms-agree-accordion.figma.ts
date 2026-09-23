// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=14330-4993&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Terms/BCPTermsAgree.swift
// component=BCPTermsAgreeAccordion

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'terms_agree_accordion' (14330:4993) · variant 16개
import figma from 'figma'

const instance = figma.selectedInstance

// mode(light/dark) 축은 옮기지 않는다 — 두 변형이 부르는 토큰이 같고 모드는 테마가 정한다.
const selected = instance.getEnum('selected', {
    "true": true,
    "false": false,
  })
// Figma 'arrow open=true' 는 아래 화살표(접힌 상태). 코드의 isExpanded 는 그 반대다.
const isExpanded = instance.getEnum('arrow open', {
    "true": false,
    "false": true,
  })
const size = instance.getEnum('size', {
    "large": ".large",
    "small": ".small",
  })

export default {
  example: figma.code`
BCPTermsAgreeAccordion(
    "페이북 약관 모두 동의",
    selected: ${selected},
    isExpanded: ${isExpanded},
    size: ${size},
    onChange: { _ in },
    onToggleExpanded: { }
)
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-terms-agree-accordion',
}
