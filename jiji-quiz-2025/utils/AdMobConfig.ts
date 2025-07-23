import { InterstitialAd, AdEventType, TestIds } from 'react-native-google-mobile-ads';

// プロジェクトアウトラインで指定されたテスト広告ユニットID
const adUnitId = TestIds.INTERSTITIAL;

// インタースティシャル広告のインスタンス
const interstitial = InterstitialAd.createForAdUnitId(adUnitId, {
  requestNonPersonalizedAdsOnly: true,
});

export class AdMobManager {
  private static loaded = false;
  private static loading = false;

  // 広告を読み込む
  static async loadAd(): Promise<void> {
    if (this.loaded || this.loading) {
      return;
    }

    this.loading = true;

    return new Promise((resolve, reject) => {
      const unsubscribe = interstitial.addAdEventListener(AdEventType.LOADED, () => {
        this.loaded = true;
        this.loading = false;
        unsubscribe();
        resolve();
      });

      const unsubscribeError = interstitial.addAdEventListener(AdEventType.ERROR, (error) => {
        this.loading = false;
        unsubscribeError();
        reject(error);
      });

      interstitial.load();
    });
  }

  // 広告を表示する
  static async showAd(): Promise<void> {
    if (!this.loaded) {
      await this.loadAd();
    }

    return new Promise((resolve, reject) => {
      const unsubscribe = interstitial.addAdEventListener(AdEventType.CLOSED, () => {
        this.loaded = false;
        unsubscribe();
        // 次回用の広告を事前に読み込む
        this.loadAd().catch(console.error);
        resolve();
      });

      const unsubscribeError = interstitial.addAdEventListener(AdEventType.ERROR, (error) => {
        this.loaded = false;
        unsubscribeError();
        reject(error);
      });

      interstitial.show();
    });
  }

  // 広告が読み込まれているかチェック
  static isLoaded(): boolean {
    return this.loaded;
  }

  // 初期化（アプリ起動時に呼び出す）
  static async initialize(): Promise<void> {
    try {
      await this.loadAd();
    } catch (error) {
      console.error('AdMob initialization failed:', error);
    }
  }
}