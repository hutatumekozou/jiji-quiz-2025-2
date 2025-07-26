import UIKit
import GoogleMobileAds          // 依存はそのまま

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Google Mobile Ads SDK を初期化
        MobileAds.shared.start { status in          // ← ここがポイント
            // 開発中はログで初期化完了を確認
            print("✅ AdMob init: \(status.adapterStatusesByClassName)")
        }

        return true
    }
}

