import CoreText
import Foundation
import SwiftUI

/// 번들에 담긴 폰트를 앱 프로세스에 등록한다.
///
/// 디자인 시스템 모듈은 `Font.custom("Pretendard", …)` 로 **이름만 부른다** — 실제 폰트는
/// 쓰는 쪽이 등록해 두어야 찾아진다. 등록이 없으면 SwiftUI 가 조용히 시스템 폰트로
/// 폴백하고 경고도 내지 않는다. 갤러리는 디자인과 대조하는 곳이므로 실제 앱과 같은
/// 폰트를 등록해 둔다.
enum FontRegistration {
    static func register() {
        let names = [
            "Pretendard-Regular", "Pretendard-Bold",
            "GmarketSansTTFMedium", "GmarketSansTTFBold",
        ]
        for name in names {
            guard let url = Bundle.module.url(forResource: name, withExtension: "otf")
                ?? Bundle.module.url(forResource: name, withExtension: "ttf") else {
                print("⚠️ 폰트 파일을 번들에서 찾지 못함: \(name)")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                print("⚠️ 폰트 등록 실패: \(name) — \(error?.takeUnretainedValue().localizedDescription ?? "?")")
            }
        }
        report()
    }

    /// 토큰이 부르는 이름으로 실제 폰트를 찾을 수 있는지 확인한다.
    ///
    /// 이름이 한 글자만 달라도 폴백되므로, 등록했다는 사실만으로는 안심할 수 없다.
    /// 실측: Gmarket Sans 는 파일의 family 가 "Gmarket Sans TTF" 라 토큰 이름과 다르다.
    static func report() {
        for family in ["Pretendard", "Gmarket Sans"] {
            let found = UIFont(name: family, size: 17) != nil
            let installed = UIFont.familyNames.filter { $0.localizedCaseInsensitiveContains(family.prefix(8)) }
            print(found
                  ? "✅ '\(family)' 사용 가능"
                  : "❌ '\(family)' 를 찾을 수 없다 → 시스템 폰트로 폴백. 설치된 비슷한 이름: \(installed)")
        }
    }
}
