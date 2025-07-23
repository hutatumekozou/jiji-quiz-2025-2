# iOS アプリのビルド・実行手順

## 方法1: Expoを使用したビルド

### 準備
1. プロジェクトディレクトリに移動
```bash
cd "/Users/kukkiiboy/Desktop/Claude code/7:16日2025年時事クイズ/jiji-quiz-2025"
```

2. Expo CLIをローカルでインストール
```bash
npm install @expo/cli@latest
```

3. iOS開発用のセットアップ
```bash
npx expo install --ios
```

4. iOSビルドの実行
```bash
npx expo run:ios
```

## 方法2: 手動でXcodeを使用

### 手順
1. Xcodeを起動
2. "Create a new Xcode project" を選択
3. "iOS" → "App" を選択
4. プロジェクト名: "JijiQuiz2025"
5. Bundle Identifier: "com.jiji.quiz2025"
6. Language: Swift
7. Interface: SwiftUI

### テスト用のSwiftUIコード
```swift
// ContentView.swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("2025時事クイズ")
                .font(.largeTitle)
                .padding()
            
            Button("スタート") {
                // TODO: クイズ開始処理
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
```

## 方法3: 現在のプロジェクトでのトラブルシューティング

### 問題の解決
現在のExpo CLIに問題があるため、以下を実行：

```bash
# 1. 現在のExpo CLIをアンインストール
npm uninstall -g @expo/cli

# 2. 古いバージョンのExpo CLIを使用
npm install -g expo-cli@6.3.10

# 3. プロジェクトディレクトリで実行
expo run:ios
```

## AdMobテスト広告の確認方法

1. アプリを起動
2. クイズを完了
3. 結果画面で「最初に戻る」ボタンを押す
4. インタースティシャル広告が表示される（テスト広告）
5. 広告を閉じるとホーム画面に戻る

### テスト広告ユニットID
- インタースティシャル: `ca-app-pub-3940256099942544/1033173712`
- App ID (iOS): `ca-app-pub-3940256099942544~1458002511`

## 注意事項
- テスト広告は実際の広告収益を発生させません
- プロダクション環境では実際のAdMobアカウントのIDに変更が必要
- iOS実機での確認には開発者アカウントが必要