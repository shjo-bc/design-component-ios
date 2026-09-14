// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=1755-7525&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Button/BCPUnderlineButton.swift
// component=BCPUnderlineButton

// 자동 생성: node tools/scripts/gen-textbutton-templates.mjs
// Figma 세트 'underline' (1755:7525) · variant 12개
// ⚠ 이 세트에는 인스턴스 프로퍼티가 없다 (텍스트가 일반 레이어).
//   따라서 스니펫의 "Label" 은 고정값이며 실제 텍스트를 반영하지 못한다.
import figma from 'figma'

const instance = figma.selectedInstance

const color = instance.getEnum('color', {
    "light-gray": ".lightGray",
    "dark-gray": ".darkGray",
    "blue": ".blue",
  })
const size = instance.getEnum('size', {
    "small": ".small",
    "large": ".large",
  })

export default {
  example: figma.code`
BCPUnderlineButton("Label", color: ${color}, size: ${size}) {
    // action
}
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-underline',
}
