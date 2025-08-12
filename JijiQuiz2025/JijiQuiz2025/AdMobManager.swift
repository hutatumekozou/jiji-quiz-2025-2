import Foundation
import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds

class AdMobManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var isAdLoaded = false
    @Published var isShowingAd = false
    
    private var interstitialAd: GADInterstitialAd?
    
    // テスト広告ユニットID（本番では実際のIDに変更）
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"
    
    override init() {
        super.init()
        loadInterstitialAd()
    }
    
    func loadInterstitialAd() {
        let request = GADRequest()
        
        GADInterstitialAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
                    self?.isAdLoaded = false
                    return
                }
                
                self?.interstitialAd = ad
                self?.interstitialAd?.fullScreenContentDelegate = self
                self?.isAdLoaded = true
                print("✅ Interstitial ad loaded successfully")
            }
        }
    }
    
    func showInterstitialAd(completion: @escaping () -> Void) {
        guard let interstitialAd = interstitialAd,
              let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("⚠️ Interstitial ad not ready or no root view controller")
            completion()
            return
        }
        
        isShowingAd = true
        
        // 広告終了後のコールバックを保存
        self.adDismissalCompletion = completion
        
        interstitialAd.present(from: rootViewController)
    }
    
    private var adDismissalCompletion: (() -> Void)?
    
    // MARK: - GADFullScreenContentDelegate
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("📊 Ad did record impression")
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("👆 Ad did record click")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Ad failed to present: \(error.localizedDescription)")
        isShowingAd = false
        adDismissalCompletion?()
        adDismissalCompletion = nil
        loadInterstitialAd() // 次の広告をロード
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📱 Ad will present full screen content")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("✅ Ad did dismiss full screen content")
        isShowingAd = false
        adDismissalCompletion?()
        adDismissalCompletion = nil
        loadInterstitialAd() // 次の広告をロード
    }
}

#else
// GoogleMobileAds が無い場合のスタブクラス
class AdMobManager: NSObject, ObservableObject {
    @Published var isAdLoaded = false
    @Published var isShowingAd = false
    
    override init() {
        super.init()
        print("🚫 AdMob not available - using stub implementation")
    }
    
    func loadInterstitialAd() {
        print("🚫 AdMob stub: loadInterstitialAd called")
    }
    
    func showInterstitialAd(completion: @escaping () -> Void) {
        print("🚫 AdMob stub: showInterstitialAd called - executing completion immediately")
        completion()
    }
}
#endif