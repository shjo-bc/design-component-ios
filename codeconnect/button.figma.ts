// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=2046-6159&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Button/BCPButton.swift
// component=BCPButton
import figma from 'figma'

// ⚠ 이 템플릿은 `large` (2046:6159) 세트의 프로퍼티 철자를 전제한다: icon / icon-3d / Label.
//   `xsmall` (2080:25710) 만 Icon / Icon-3D (대문자) 이므로 그대로 복사하면 조용히 빈 값이 된다.
//   세트별 철자는 shared/figma/button.json 의 properties 필드를 확인할 것.
const instance = figma.selectedInstance

const label = instance.getString('Label')
const type = instance.getEnum('type', {
  primary: '.primary',
  secondary: '.secondary',
  'outlined-1': '.outlined',
  'outlined-2': '.outlinedSubtle',
})
const disabled = instance.getEnum('state', {
  normal: false,
  pressed: false,
  disabled: true,
})

export default {
  example: figma.code`
BCPButton(${label}, size: .large, type: ${type}) {
    // action
}
.disabled(${disabled})
`,
  imports: ['import BCPDesignSystem'],
  id: 'bcp-button-large',
}
