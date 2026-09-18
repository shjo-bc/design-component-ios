// url=https://www.figma.com/design/3ar2ONJR9DA46bKMhVQ6ZW/?node-id=49409-14313&m=dev
// source=platforms/ios/Sources/BCPDesignSystem/Component/Badge/BCPSmallBadge.swift
// component=BCPSmallBadge

// ⚠ 수동 작성이다. 부모 저장소(design-component)의 tools/scripts/gen-*.mjs 산출물이 아니다.
// Figma 세트 'badge-small' (49409:14313) · variant 8개
import figma from 'figma'

const instance = figma.selectedInstance

// 문구(NEW·ON·OFF)는 컴포넌트가 갖는다 — 텍스트를 넘기지 않는다.
const rawType = instance.getEnum('type', {
    "new": "new",
    "on": "on",
    "off": "off",
  })

// Figma 의 color 축은 두 가지를 섞어 담고 있다.
//   1 / 2          → 강조 정도 (옅은 바탕 / 꽉 찬 바탕)
//   light-mode / dark-mode → 디자이너가 모드를 손으로 바꿔 보려고 둔 축
const rawColor = instance.getEnum('color', {
    "1": "1",
    "2": "2",
    "light-mode": "mode",
    "dark-mode": "mode",
  })

// ⚠ OFF 배지는 네 variant 로 흩어져 있고 이름이 실제 모양과 어긋난다.
// 실측 fill (surface / text):
//
//   type=off                    #b2b7c2 / #ffffff → strong
//   type=off, color=dark-mode   #4b515d / #000000 → strong 의 다크 짝
//   type=new, color=light-mode  #e7e9ef / #969dab → subtle   ← 이름은 new 지만 글자는 "OFF"
//   type=new, color=dark-mode   #22252a / #626a7a → subtle 의 다크 짝
//
// mode 축이 붙었다고 전부 옅은 회색인 것이 아니다 — type 을 함께 봐야 한다.
// color 로만 가르면 type=off 쌍까지 subtle 로 빨려 들어가 strong OFF 가 한 번도 나오지 않는다.
const isMode = rawColor === 'mode'
const type = rawType === 'off' || isMode ? '.off' : { "new": ".new", "on": ".on" }[rawType]
const style =
  rawType === 'off' ? '.strong'                  // type=off 쌍은 color 와 무관하게 꽉 찬 바탕
  : isMode ? '.subtle'                           // 이름만 new 인 옅은 회색 OFF
  : rawColor === '2' ? '.strong' : '.subtle'

// style 을 생략하면 Figma 기본값을 따른다 — NEW·ON 은 subtle, OFF 는 strong 이다.
// 기본값과 같은 조합이면 인자를 붙이지 않는다.
const isDefaultStyle = type === '.off' ? style === '.strong' : style === '.subtle'

const example = isDefaultStyle
  ? figma.code`
BCPSmallBadge(${type})
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
