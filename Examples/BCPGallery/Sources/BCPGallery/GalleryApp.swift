import SwiftUI
import BCPDesignSystem

/// 디자인 시스템 컴포넌트를 눈으로 확인하고 손으로 만져보기 위한 앱.
///
/// 스니펫 컴파일과 Code Connect 검증은 "코드가 말이 되는가" 만 확인한다.
/// 실제로 어떻게 그려지는지, 포커스·입력·토글이 어떻게 반응하는지는 여기서만 드러난다.
@main
struct GalleryApp: App {
    init() { FontRegistration.register() }

    var body: some Scene {
        WindowGroup {
            GalleryRoot()
        }
    }
}

/// 라이트/다크를 한 화면에서 바꿔가며 볼 수 있어야 한다 —
/// 토큰이 모드별로 다르게 해석되므로 한쪽만 보면 절반만 확인하는 셈이다.
struct GalleryRoot: View {
    @State private var scheme: ColorScheme
    @State private var tab: Int

    /// 실행 인자로 초기 탭과 모드를 정할 수 있다 — `simctl launch` 로 화면을 찍을 때
    /// 손으로 탭을 옮기지 않고 원하는 페이지를 바로 띄우기 위한 것이다.
    ///
    ///     xcrun simctl launch <dev> <bundleId> --args --tab=inputs --dark
    init() {
        let args = ProcessInfo.processInfo.arguments
        _tab = State(initialValue: args.contains("--tab=controls") ? 1
                                 : args.contains("--tab=inputs") ? 2 : 0)
        _scheme = State(initialValue: args.contains("--dark") ? .dark : .light)
    }

    var body: some View {
        NavigationView {
            TabView(selection: $tab) {
                ButtonsPage().tabItem { Label("Buttons", systemImage: "rectangle.and.hand.point.up.left") }.tag(0)
                ControlsPage().tabItem { Label("Controls", systemImage: "switch.2") }.tag(1)
                InputsPage().tabItem { Label("Inputs", systemImage: "character.cursor.ibeam") }.tag(2)
            }
            .navigationTitle("BCP Design System")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(scheme == .light ? "다크" : "라이트") {
                        scheme = scheme == .light ? .dark : .light
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(scheme)
        // 실제 앱과 같은 방식으로 테마를 주입한다 — 이것을 빼먹으면 어떻게 보이는지도
        // 확인할 수 있어야 해서 루트 한 곳에서만 붙인다.
        .bcpTheme()
    }
}

/// 한 컴포넌트의 변형들을 제목과 함께 묶는다. 페이지마다 같은 리듬으로 읽히게 한다.
struct Section<Content: View>: View {
    let title: String
    let note: String?
    @ViewBuilder let content: () -> Content

    init(_ title: String, note: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.note = note
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            if let note {
                Text(note).font(.caption).foregroundColor(.secondary)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
}

/// 세로로 길어지는 페이지의 공통 껍데기.
struct Page<Content: View>: View {
    @ViewBuilder let content: () -> Content

    /// `--scroll=<id>` 로 특정 섹션까지 내려간 상태로 띄운다.
    /// 화면을 손으로 스크롤하지 않고 원하는 부분을 찍기 위한 것이다.
    private var anchor: String? {
        ProcessInfo.processInfo.arguments
            .first { $0.hasPrefix("--scroll=") }?
            .replacingOccurrences(of: "--scroll=", with: "")
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    content()
                }
                .padding(16)
                // 탭 바가 마지막 항목을 가리지 않도록 아래를 넉넉히 비운다.
                .padding(.bottom, 80)
            }
            .onAppear {
                guard let anchor else { return }
                // 레이아웃이 잡힌 뒤에 옮겨야 정확한 위치로 간다.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    proxy.scrollTo(anchor, anchor: .top)
                }
            }
        }
    }
}

#if DEBUG
struct GalleryRoot_Previews: PreviewProvider {
    static var previews: some View {
        GalleryRoot()
    }
}
#endif
