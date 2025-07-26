import SwiftUI
import GoogleMobileAds          // AdMob 用モジュール

@main
struct JijiQuiz2025App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate   // AppDelegate と橋渡し

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

