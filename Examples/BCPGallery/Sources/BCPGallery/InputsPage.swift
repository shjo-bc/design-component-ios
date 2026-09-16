import SwiftUI
import BCPDesignSystem

struct InputsPage: View {
    @State private var basic = ""
    @State private var amount = ""
    @State private var multiline = ""
    @State private var card = ""
    @State private var num = ""
    @State private var amountLarge = ""
    @State private var dropdown = ""
    @State private var date = ""
    @State private var line = ""
    @State private var lineDropdown = ""
    @State private var search1 = ""
    @State private var search2 = ""
    @State private var lineFocus = false

    var body: some View {
        Page {
            Section("box — basic / amount / multiline",
                    note: "탭해서 포커스하면 테두리가 2pt 로 두꺼워져야 한다") {
                VStack(spacing: 14) {
                    BCPBoxTextField(text: $basic, type: .basic, placeholder: "Text", helperText: "도움말")
                    BCPBoxTextField(text: $amount, type: .amount, placeholder: "금액 입력", unit: "원")
                    BCPBoxTextField(text: $multiline, type: .multiline, placeholder: "내용", maxLength: 1000)
                }
            }

            Section("box — validation",
                    note: "오류 상태에서 탭해도 테두리가 두꺼워지는지 확인 (0.1.7 에서 고친 부분)") {
                VStack(spacing: 14) {
                    BCPBoxTextField(text: $basic, placeholder: "이메일",
                                    helperText: "형식이 올바르지 않습니다", validation: .invalid)
                    BCPBoxTextField(text: $basic, placeholder: "이메일",
                                    helperText: "사용 가능합니다", validation: .valid)
                    BCPBoxTextField(text: $basic, placeholder: "비활성").disabled(true)
                }
            }

            Section("box — 금융 입력",
                    note: "카드번호는 4자리마다 끊긴다. 숫자 키패드가 안 뜨는 것은 알려진 한계다") {
                VStack(spacing: 14) {
                    BCPBoxTextField(text: $card, type: .cardNumber, placeholder: "카드번호", helperText: "16자리")
                    BCPBoxTextField(text: $num, type: .number, placeholder: "인증번호",
                                    helperText: "6자리", buttonTitle: "확인", onButtonTap: {})
                    BCPBoxTextField(text: $amountLarge, type: .amountLarge, placeholder: "금액 입력", unit: "원")
                }
            }

            Section("box — 선택형", note: "텍스트 필드가 아니라 버튼으로 읽혀야 한다") {
                VStack(spacing: 14) {
                    BCPBoxTextField(text: $dropdown, type: .dropdown, placeholder: "선택하세요",
                                    onTap: { dropdown = dropdown.isEmpty ? "신용카드" : "" })
                    BCPBoxTextField(text: $date, type: .date, placeholder: "날짜 선택",
                                    onTap: { date = date.isEmpty ? "2026.09.16" : "" })
                }
            }

            Section("line", note: "밑줄 색이 포커스에 따라 바뀌는지 본다. 값이 있으면 지우기 버튼이 나온다") {
                VStack(spacing: 20) {
                    BCPLineTextField(text: $line, focus: $lineFocus, label: "이메일",
                                     placeholder: "Text", helperText: "도움말")
                    BCPLineTextField(text: $line, label: "오류", placeholder: "Text",
                                     helperText: "형식이 올바르지 않습니다", validation: .invalid)
                    BCPLineTextField(text: $lineDropdown, type: .dropdown, label: "카드사",
                                     placeholder: "선택하세요",
                                     onTap: { lineDropdown = lineDropdown.isEmpty ? "BC카드" : "" })
                    BCPLineTextField(text: $line, label: "비활성", placeholder: "Text").disabled(true)
                }
            }

            Section("search", note: "두 스타일의 차이는 표면 색뿐이다") {
                VStack(spacing: 14) {
                    BCPSearchBar(text: $search1, style: .style1, placeholder: "가맹점 검색")
                    BCPSearchBar(text: $search2, style: .style2, placeholder: "가맹점 검색") { search2 = "" }
                }
                .padding(12)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(8)
            }
        }
    }
}

#if DEBUG
struct InputsPage_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            InputsPage()
                .bcpTheme()
                .preferredColorScheme(scheme)
                .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
