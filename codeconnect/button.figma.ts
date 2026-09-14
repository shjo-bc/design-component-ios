// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=2046-6159&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Button/BCPButton.swift
// component=BCPButton
import figma from 'figma'

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
