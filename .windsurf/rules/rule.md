---
trigger: always_on
---

# TypeScript・React Native・Expo モバイル UI 開発ガイドライン（v2025-06）

> **対象 SDK**: Expo SDK 50 (React Native 0.75)  
> **更新日**: 2025-06-10

---

## 1. コードスタイルと構造
1. **TypeScript 完全対応**：`strictNullChecks` / `exactOptionalPropertyTypes` を必須。  
   `extends: "@react-native/tsconfig/tsconfig.json"` を推奨。
2. **関数型 + Hooks**：クラスは使用せず、宣言的・再利用可能なコンポーネントを作成。
3. **ファイルレイアウト**：
   - `components/`  再利用 UI
   - `hooks/`       カスタム Hooks
   - `store/`       状態管理（Zustand/Jotai）
   - `api/`         リクエストラッパー（ky + React Query）
   - `app/`         `expo-router v3` ルーティング
4. **命名規則**：ディレクトリは kebab-case、コンポーネントは PascalCase。

---

## 2. 開発環境
```bash
npx create-expo-app@latest --template
pnpm add -D typescript @react-native/tsconfig zod vitest @testing-library/react-native detox expo-router @tanstack/react-query ky zustand
```

`tsconfig.json`
```jsonc
{
  "extends": "@react-native/tsconfig/tsconfig.json",
  "compilerOptions": {
    "strictNullChecks": true,
    "exactOptionalPropertyTypes": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

---

## 3. ルーティング（expo-router v3）
1. ファイルベースルーティング：`app/(tabs)/index.tsx` など。
2. `Stack`, `Tabs`, `Modal` レイアウトを `app/_layout.tsx` 内で宣言。
3. Deep Linking と Universal Links は `expo-linking` で設定。

---

## 4. 状態管理 & データ取得
| 用途 | 推奨ライブラリ |
| ---- | -------------- |
| リモートデータ | `@tanstack/react-query v6` |
| グローバル状態 | `zustand` or `jotai` |
| バリデーション | `zod` (`z.infer` で型共有) |
| HTTP クライアント | `ky` (`ky.extend({...})`) |

```ts
// store/auth.ts
import { create } from 'zustand'
interface AuthState {
  token?: string
  setToken: (t?: string) => void
}
export const useAuth = create<AuthState>(set => ({
  token: undefined,
  setToken: token => set({ token }),
}))
```

---

## 5. UI / スタイリング
1. Expo の公式 UI (`expo-router` と組み合わせ) + `react-native-paper` or `tamagui`。
2. ダークモード：`useColorScheme` + `tailwindcss-react-native` or `styled-components`。
3. セーフエリア：`expo-safe-area` (`SafeAreaProvider`, `SafeAreaView`)。
4. 画像：`expo-image` (自動プレースホルダ & キャッシュ)。

---

## 6. パフォーマンス最適化
- Hermes JIT デフォルト有効化 (`expo prebuild` で自動)。
- `react-native-reanimated v3` と `react-native-gesture-handler v3`。
- リソースプリロード：`expo-asset` + `expo-router` の `preloadResourcesAsync()`。
- 重量級 UI：`react-native-skia` でネイティブ描画。
- OTA 配信は `runtimeVersion` を用い `eas update` チャンネル管理。

---

## 7. テスト
| 種類 | ライブラリ | 設定ポイント |
| ---- | ---------- | ------------- |
| 単体 & Hooks | `vitest` + `@testing-library/react-native` | `vitest.config.ts` で `setupFiles` に `expo-router/entry` |
| E2E | `Detox 20` | `detox.config.ts` で `expo-provider` を使用 |

Jest は非推奨。新規プロジェクトは Vitest へ移行。

---

## 8. セキュリティ
1. Expo Permissions v2 API (`import { Camera } from 'expo-camera/next'`).
2. セキュアストレージ：`expo-secure-store`, アクセス制御は `keychainAccessible: WHEN_UNLOCKED_THIS_DEVICE_ONLY`。
3. Sentry SDK でクラッシュ収集 (`expo install sentry-expo`).

---

## 9. CI / CD（EAS）
1. `eas build --profile preview --platform ios,android`。
2. `eas submit` で TestFlight / Play Console へ自動。
3. GitHub Actions 例：
```yaml
- uses: expo/expo-github-action@v9
  with:
    eas-version: latest
    expo-version: 7
    token: ${{ secrets.EXPO_TOKEN }}
```

---

## 10. 参考リンク
- Expo Docs: <https://docs.expo.dev/>
- React Native TypeScript: <https://reactnative.dev/docs/typescript>
- React Query: <https://tanstack.com/query/latest>
- Detox: <https://wix.github.io/Detox/>
- EAS Build / Update: <https://docs.expo.dev/eas/>

---

### CHANGELOG
- **2025-06-10**: Expo SDK 50 対応, React Query v6, Vitest 移行, expo-router v3 追加。
