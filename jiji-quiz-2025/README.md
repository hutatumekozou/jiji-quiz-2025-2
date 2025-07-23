# 2025時事クイズアプリ

2025年の最新ニュースに関する時事問題を出題するクイズアプリです。React Native/Expo版とWeb版の両方が含まれています。

## 🎯 主要機能

- **10問の時事クイズ**: 2025年の重要なニュースから出題
- **4択問題形式**: 直感的で使いやすいインターフェース
- **詳細な解説**: 各問題の答えと背景情報を表示
- **スコア表示**: 正答数と正答率を表示
- **AdMobテスト広告**: インタースティシャル広告の統合（React Native版）
- **レスポンシブデザイン**: スマートフォンからデスクトップまで対応

## 📱 画面構成

1. **起動画面**: アプリタイトルとスタートボタン
2. **クイズ画面**: 問題文、4択選択肢、解説表示
3. **結果画面**: 最終スコア表示と再スタート機能

## 🚀 使用技術

### React Native版
- **Expo Router**: ナビゲーション
- **React Native**: モバイルアプリ開発
- **TypeScript**: 型安全性
- **AdMob**: テスト広告表示

### Web版
- **HTML/CSS/JavaScript**: 純粋なWeb技術
- **レスポンシブデザイン**: モバイル対応
- **広告シミュレーション**: AdMobのような表示

## 🛠️ セットアップ

### React Native版

```bash
# 依存関係のインストール
npm install

# iOS開発
npx expo run:ios

# Android開発
npx expo run:android

# Web開発
npx expo start --web
```

### Web版のみ

```bash
# HTTPサーバーを起動
cd web
python3 -m http.server 8000

# ブラウザで開く
open http://localhost:8000
```

## 📊 クイズ内容

以下の2025年時事問題を含みます：

- 大阪・関西万博
- 政治・選挙
- 少子高齢化
- 環境問題・カーボンニュートラル
- デジタル化・DX
- 働き方改革
- 教育政策・GIGAスクール
- 宇宙開発
- 医療・AI技術
- その他の重要な時事問題

## 🎪 テスト広告

### React Native版
- **AdMob SDK**: 実際のテスト広告を表示
- **テスト広告ユニットID**: `ca-app-pub-3940256099942544/1033173712`
- **表示タイミング**: 結果画面で「最初に戻る」ボタンを押した時

### Web版
- **シミュレーション**: HTML/CSS/JSで実装
- **視覚的効果**: フェードイン・アニメーション
- **自動閉じ**: 5秒後に自動で広告を閉じる

## 📱 動作確認

### iOS Simulator
1. iOS Simulatorを起動
2. Safariで `http://localhost:8000` にアクセス
3. クイズアプリを体験

### モバイルデバイス
1. Expo Goアプリをインストール
2. QRコードをスキャン
3. アプリを起動

## 🗂️ ファイル構成

```
jiji-quiz-2025/
├── app/                 # Expo Router画面
│   ├── _layout.tsx     # ルートレイアウト
│   ├── index.tsx       # 起動画面
│   ├── quiz.tsx        # クイズ画面
│   └── result.tsx      # 結果画面
├── data/               # クイズデータ
│   └── questions.json  # 問題データ
├── utils/              # ユーティリティ
│   └── AdMobConfig.ts  # AdMob設定
├── web/                # Web版
│   └── index.html      # 単一HTMLファイル
├── ios-native/         # iOS SwiftUI版
│   └── ContentView.swift
└── README-build.md     # ビルド手順
```

## 🔧 開発者向け情報

### 依存関係
- `expo`: ~53.0.4
- `expo-router`: ~5.0.7
- `react-native`: ~0.76.1
- `react-native-google-mobile-ads`: 最新版

### 広告設定
- **iOS App ID**: `ca-app-pub-3940256099942544~1458002511`
- **Android App ID**: `ca-app-pub-3940256099942544~3347511713`
- **インタースティシャル**: `ca-app-pub-3940256099942544/1033173712`

## 🤝 貢献

プルリクエストや Issue の作成を歓迎します。

## 📄 ライセンス

MIT License

---

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
