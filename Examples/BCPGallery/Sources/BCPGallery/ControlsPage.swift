import SwiftUI
import BCPDesignSystem

struct ControlsPage: View {
    @State private var checkedM = true
    @State private var checkedS = false
    @State private var radio = 0
    @State private var toggleOn = true

    var body: some View {
        Page {
            Section("BCPCheckbox", note: "이름은 호출부가 붙인다 — VoiceOver 로 라벨이 읽히는지 확인할 것") {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        BCPCheckbox(checked: checkedM) { checkedM = $0 }
                            .accessibilityLabel("이용약관 동의")
                        Text("medium · \(checkedM ? "선택됨" : "선택 안 함")").font(.caption)
                    }
                    HStack(spacing: 12) {
                        BCPCheckbox(checked: checkedS, size: .small) { checkedS = $0 }
                            .accessibilityLabel("마케팅 수신 동의")
                        Text("small · \(checkedS ? "선택됨" : "선택 안 함")").font(.caption)
                    }
                    HStack(spacing: 12) {
                        BCPCheckbox(checked: true) { _ in }.disabled(true)
                        BCPCheckbox(checked: false) { _ in }.disabled(true)
                        Text("비활성").font(.caption)
                    }
                }
            }

            Section("BCPRadioButton", note: "그룹 동작은 호출부가 만든다 — 하나만 선택되는지 확인") {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(0..<3, id: \.self) { i in
                        HStack(spacing: 12) {
                            BCPRadioButton(selected: radio == i) { radio = i }
                                .accessibilityLabel("결제수단 \(i + 1)")
                            Text("옵션 \(i + 1)").font(.caption)
                        }
                    }
                    HStack(spacing: 12) {
                        BCPRadioButton(selected: true) {}.disabled(true)
                        Text("비활성").font(.caption)
                    }
                }
            }

            Section("BCPToggle", note: "VoiceOver 로터에 \"켜기/끄기\" 동작이 보여야 한다") {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        BCPToggle(isOn: toggleOn) { toggleOn = $0 }
                            .accessibilityLabel("푸시 알림")
                        Text(toggleOn ? "켜짐" : "꺼짐").font(.caption)
                    }
                    HStack(spacing: 12) {
                        BCPToggle(isOn: true) { _ in }.disabled(true)
                        BCPToggle(isOn: false) { _ in }.disabled(true)
                        Text("비활성").font(.caption)
                    }
                }
            }

            Section("터치 타깃 확인", note: "회색 사각형이 Apple 권장 44×44pt. 컨트롤이 그보다 작으면 탭하기 어렵다") {
                HStack(spacing: 20) {
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.25)).frame(width: 44, height: 44)
                        BCPCheckbox(checked: checkedM) { checkedM = $0 }
                    }
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.25)).frame(width: 44, height: 44)
                        BCPRadioButton(selected: true) {}
                    }
                    ZStack {
                        Rectangle().fill(Color.gray.opacity(0.25)).frame(width: 48, height: 44)
                        BCPToggle(isOn: toggleOn) { toggleOn = $0 }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct ControlsPage_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            ControlsPage()
                .bcpTheme()
                .preferredColorScheme(scheme)
                .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
