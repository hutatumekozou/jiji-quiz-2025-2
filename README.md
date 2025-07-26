# 2025年時事クイズ 📰

2025年の最新ニュースに関する時事問題クイズアプリです。政治、経済、環境、技術など幅広いトピックから出題されます。

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/your-username/jiji-quiz-2025)

## 🎯 特徴

- **📱 レスポンシブデザイン** - スマートフォン、タブレット、PCに対応
- **🎯 10問の時事問題** - 2025年の重要なニュースから厳選
- **💡 詳しい解説付き** - 各問題に分かりやすい解説を用意
- **📊 結果表示機能** - スコアと正答率をグラフィカルに表示
- **🎨 モダンなUI/UX** - 美しいグラデーションとアニメーション
- **🚀 高速ロード** - 静的サイトによる高速表示

## 🚀 クイックスタート

### Vercelでのデプロイ

1. このリポジトリをGitHubにプッシュ
2. [Vercel](https://vercel.com)でGitHubアカウントでログイン
3. "New Project" → リポジトリを選択 → Deploy

### ローカル開発

```bash
# リポジトリをクローン
git clone <your-repo-url>
cd jiji-quiz-2025

# 静的サーバーで実行
npx serve .
# または
python -m http.server 8000
```

ブラウザで `http://localhost:3000` (または `http://localhost:8000`) を開いてください。

## 📁 プロジェクト構成

```
├── index.html              # メインのWebアプリ
├── monthly-quiz/           # 月別クイズ版
│   ├── index.html
│   └── vercel.json
├── JijiQuiz2025/          # iOS SwiftUI版
│   ├── ContentView.swift
│   ├── QuizViewModel.swift
│   └── ...
├── jiji-quiz-2025/        # React Native版
│   ├── app/
│   └── ...
├── vercel.json            # Vercel設定
├── package.json           # npm設定
└── README.md             # このファイル
```

## 🛠 技術スタック

### Web版 (メイン)
- **HTML5** - セマンティックマークアップ
- **CSS3** - Flexbox、Grid、アニメーション
- **Vanilla JavaScript** - ES6+の最新機能
- **レスポンシブデザイン** - モバイルファースト

### iOS版
- **SwiftUI** - 宣言的UI
- **MVVM** - アーキテクチャパターン
- **AdMob** - 広告統合

### React Native版
- **Expo Router** - ナビゲーション
- **TypeScript** - 型安全性

## 🎮 使い方

1. **スタート画面** - 「スタート」ボタンをタップ
2. **クイズ画面** - 4択から正解を選択
3. **解説表示** - 正解・不正解と詳しい解説を確認
4. **結果画面** - 最終スコアと評価を表示
5. **再チャレンジ** - 「最初に戻る」で新しいクイズに挑戦

## 📊 問題内容

- 大阪・関西万博2025
- 参議院議員選挙
- 少子高齢化問題
- カーボンニュートラル
- DX推進政策
- リモートワーク定着
- GIGAスクール構想
- 月面探査計画
- AI診断・遠隔医療
- その他2025年の重要トピック

## 🌟 今後の拡張予定

- [ ] サーバー連携による日替わり問題
- [ ] ランキング機能
- [ ] SNSシェア機能
- [ ] ダークモード対応
- [ ] 多言語対応
- [ ] PWA対応

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) ファイルをご覧ください。

## 🤝 コントリビューション

プルリクエストや issue の作成を歓迎します！

---

**Made with ❤️ by Claude Code**