import SwiftUI
import BCPDesignSystem

struct ButtonsPage: View {
    private let types: [(String, BCPButtonType)] = [
        ("primary", .primary), ("secondary", .secondary),
        ("outlined", .outlined), ("outlinedSubtle", .outlinedSubtle),
        ("isp", .isp), ("openApp", .openApp), ("chip", .chip),
    ]
    private let sizes: [(String, BCPButtonSize)] = [
        ("xsmall", .xsmall), ("small", .small), ("medium", .medium),
        ("large", .large), ("xlarge", .xlarge), ("xxlarge", .xxlarge),
    ]

    var body: some View {
        Page {
            Section("BCPButton — 타입", note: "size 는 large 고정") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(types, id: \.0) { name, type in
                        HStack(spacing: 12) {
                            Text(name).font(.caption).frame(width: 96, alignment: .leading)
                            BCPButton("확인", type: type, size: .large) {}
                        }
                    }
                }
            }

            Section("BCPButton — 크기", note: "type 은 primary 고정. 높이가 토큰대로 나오는지 본다") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(sizes, id: \.0) { name, size in
                        HStack(spacing: 12) {
                            Text(name).font(.caption).frame(width: 96, alignment: .leading)
                            BCPButton("확인", type: .primary, size: size) {}
                        }
                    }
                }
            }

            Section("BCPButton — 폭", note: "hug 는 내용만큼, fill 은 가로를 채운다") {
                VStack(alignment: .leading, spacing: 10) {
                    BCPButton("hug", type: .primary, size: .large, width: .hug) {}
                    BCPButton("fill", type: .primary, size: .large, width: .fill) {}
                }
            }

            Section("BCPButton — 비활성", note: ".disabled(true) 로 주입한다") {
                HStack(spacing: 12) {
                    BCPButton("활성", type: .primary, size: .large) {}
                    BCPButton("비활성", type: .primary, size: .large) {}.disabled(true)
                }
            }

            Section("BCPArrowButton") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach([("lightGray", BCPArrowButtonColor.lightGray), ("darkGray", .darkGray), ("blue", .blue)], id: \.0) { name, color in
                        HStack(spacing: 12) {
                            Text(name).font(.caption).frame(width: 96, alignment: .leading)
                            BCPArrowButton("더보기", color: color, size: .large, direction: .right) {}
                            BCPArrowButton("접기", color: color, size: .small, direction: .up) {}
                        }
                    }
                }
            }

            Section("BCPUnderlineButton") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach([("lightGray", BCPUnderlineButtonColor.lightGray), ("darkGray", .darkGray), ("blue", .blue)], id: \.0) { name, color in
                        HStack(spacing: 12) {
                            Text(name).font(.caption).frame(width: 96, alignment: .leading)
                            BCPUnderlineButton("자세히", color: color, size: .large) {}
                            BCPUnderlineButton("자세히", color: color, size: .small) {}
                        }
                    }
                }
            }

            Section("BCPScrollToTopButton", note: "아이콘 전용 — VoiceOver 는 \"맨 위로\" 라고 읽어야 한다") {
                BCPScrollToTopButton {}
            }

            Section("폰트 확인", note: "토큰이 부르는 이름으로 실제 폰트를 찾는지 본다. 시스템 폰트로 폴백되면 글자 폭이 달라진다") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(["Pretendard", "Gmarket Sans"], id: \.self) { family in
                        let resolved = BCPFont.resolvedFamily(family)
                        let ok = UIFont(name: resolved, size: 17) != nil
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(ok ? "✅" : "❌") \(family)").font(.caption)
                            if resolved != family {
                                Text("   → 실제 이름 \"\(resolved)\" 로 해석됨").font(.caption2).foregroundColor(.secondary)
                            }
                            Text("다람쥐 헌 쳇바퀴에 타고파 123")
                                .font(.custom(resolved, size: 17))
                        }
                    }
                    Text("아래는 비교용 시스템 폰트").font(.caption2).foregroundColor(.secondary)
                    Text("다람쥐 헌 쳇바퀴에 타고파 123").font(.system(size: 17))
                }
            }
            .id("font")
        }
    }
}

#if DEBUG
struct ButtonsPage_Previews: PreviewProvider {
    static var previews: some View {
        ForEach([ColorScheme.light, .dark], id: \.self) { scheme in
            ButtonsPage()
                .bcpTheme()
                .preferredColorScheme(scheme)
                .previewDisplayName(scheme == .light ? "Light" : "Dark")
        }
    }
}
#endif
