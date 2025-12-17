# Prompt Mixer - 仕様書

## 📖 概要

**Prompt Mixer**は、WebページやSNS投稿のURLとシステムプロンプトテンプレートを組み合わせて、AIツール（ChatGPT、Claude、Geminiなど）に送信するためのWebアプリケーションです。

- **公開URL**: https://prompt-mixer.pages.dev/
- **プラットフォーム**: Web（iPhone、Android、PC対応）
- **バックエンド**: Firebase（Authentication + Cloud Firestore）
- **ホスティング**: Cloudflare Pages

---

## 🎯 主な機能

### 1. **Googleログイン認証**
- Firebase Authenticationを使用したGoogleアカウントでのログイン
- ログイン状態に応じた画面の自動切り替え
- セキュアなユーザー認証

### 2. **テンプレート管理**
- **作成**: 新しいプロンプトテンプレートを作成
- **編集**: 既存のテンプレートを編集
- **削除**: 不要なテンプレートを削除
- **お気に入り**: よく使うテンプレートをお気に入り登録

### 3. **URL入力とプロンプト生成**
- URLを入力（手動入力 or クリップボードから貼り付け）
- テンプレートを選択
- `{{URL}}`プレースホルダーが自動的にURLに置き換えられる
- リアルタイムプレビュー表示

### 4. **共有機能**
- **iPhone/iPad**: iOSの標準共有シートを開く
- **Android**: Android標準の共有メニューを開く
- **PC**: クリップボードにコピー
- Web Share API対応

### 5. **クラウド同期**
- Cloud Firestoreによるデータ保存
- すべてのデバイスで自動同期
- ユーザーごとに独立したデータ管理

### 6. **カテゴリ分類**
- テンプレートをカテゴリ別に整理
- カテゴリフィルター機能
- カテゴリ一覧の自動生成

### 7. **初回ログイン特典**
- 初回ログイン時に5つのサンプルテンプレートを自動生成
  - 記事要約
  - X投稿の分析
  - 技術記事の解説
  - お気に入り引用
  - ニュース要点整理

---

## 🏗️ アーキテクチャ

### **フロントエンド**
- **フレームワーク**: Flutter 3.35.4
- **言語**: Dart 3.9.2
- **UI**: Material Design 3（ダークテーマ）
- **状態管理**: Provider
- **ローカルストレージ**: Hive（オフライン時のフォールバック用）

### **バックエンド**
- **認証**: Firebase Authentication
  - Google Sign-In
- **データベース**: Cloud Firestore
  - ユーザーごとのテンプレート保存
  - リアルタイム同期

### **ホスティング**
- **Cloudflare Pages**
  - GitHub連携による自動デプロイ
  - グローバルCDN配信
  - HTTPS自動適用

---

## 📊 データ構造

### **Firestore コレクション構造**

```
users (collection)
└── {userId} (document)
    └── templates (collection)
        └── {templateId} (document)
            ├── title: String
            ├── content: String
            ├── description: String?
            ├── category: String?
            ├── isFavorite: Boolean
            ├── createdAt: Timestamp
            └── updatedAt: Timestamp
```

### **PromptTemplate モデル**

```dart
class PromptTemplate {
  final String id;              // UUID
  final String title;           // テンプレート名
  final String content;         // プロンプト内容（{{URL}}プレースホルダー含む）
  final String? description;    // 説明（任意）
  final DateTime createdAt;     // 作成日時
  final DateTime updatedAt;     // 更新日時
  final bool isFavorite;        // お気に入りフラグ
  final String? category;       // カテゴリ（任意）
}
```

---

## 🔐 セキュリティ

### **Firestore Security Rules**

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザーごとのテンプレートコレクション
    match /users/{userId}/templates/{templateId} {
      // 認証済みユーザーは自分のテンプレートのみ読み書き可能
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // その他のドキュメントはすべて拒否
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### **認証済みドメイン（Firebase）**
- `localhost`（開発用）
- `prompt-mixer.pages.dev`（本番環境）

---

## 🎨 UI/UX デザイン

### **カラーテーマ**
- **背景**: ダーク (#121212)
- **カード**: ダークグレー (#1E1E1E)
- **プライマリ**: パープル (#9C6ADE)
- **アクセント**: ライトパープル (#B794F6)
- **テキスト**: ホワイト/グレー

### **主要画面**

#### **1. ログイン画面**
- アプリロゴ
- アプリ名とキャッチコピー
- 機能紹介（3項目）
- Googleログインボタン

#### **2. ホーム画面**
- URL入力カード
  - テキスト入力フィールド
  - ペーストボタン
  - クリアボタン
- テンプレート選択エリア
  - 横スクロールカード表示
  - お気に入り表示
- 出力プレビューエリア
  - 生成されたプロンプトのプレビュー
  - 文字数表示
- 共有ボタン
  - iOS/Android: 共有シート
  - PC: クリップボードコピー

#### **3. テンプレート管理画面**
- カテゴリフィルター（横スクロールチップ）
- テンプレートリスト
  - タイトル
  - カテゴリバッジ
  - お気に入りアイコン
  - 説明文
- 新規作成FAB（Floating Action Button）

#### **4. テンプレート編集画面**
- タイトル入力
- カテゴリ入力（ドロップダウン候補）
- 説明入力（任意）
- プロンプト内容入力（複数行）
- {{URL}}挿入ボタン
- お気に入りトグル
- 保存ボタン

---

## 🔄 ユーザーフロー

### **初回利用フロー**
```
1. アプリ起動
   ↓
2. ログイン画面表示
   ↓
3. 「Googleでログイン」をタップ
   ↓
4. Googleアカウント選択
   ↓
5. 初回ログイン処理
   - サンプルテンプレート5個を自動生成
   ↓
6. ホーム画面表示（サンプルテンプレート表示）
```

### **通常利用フロー**
```
1. ホーム画面表示
   ↓
2. URL入力（手動 or ペースト）
   ↓
3. テンプレート選択
   ↓
4. プレビュー確認
   ↓
5. 共有ボタンタップ
   ↓
6. iOS/Android: 共有シート → AIアプリ選択
   PC: クリップボードコピー → AIツールに貼り付け
```

### **テンプレート管理フロー**
```
1. 「テンプレート」タブをタップ
   ↓
2. オプション:
   a. 新規作成: FABタップ → 編集画面 → 保存
   b. 編集: テンプレートタップ → 編集画面 → 保存
   c. 削除: スワイプ or 長押し → 削除確認 → 削除
   d. お気に入り: ★アイコンタップ
```

---

## 🛠️ 技術仕様

### **依存パッケージ（主要）**

```yaml
dependencies:
  flutter: sdk: flutter
  
  # Firebase
  firebase_core: 3.6.0
  firebase_auth: 5.3.1
  cloud_firestore: 5.4.3
  google_sign_in: 6.2.2
  
  # 状態管理
  provider: 6.1.5+1
  
  # ローカルストレージ
  hive: 2.2.3
  hive_flutter: 1.1.0
  
  # ユーティリティ
  uuid: ^4.5.1
  web: ^1.1.0
```

### **ビルド設定**

#### **Web ビルド**
```bash
flutter build web --release
```

#### **出力ディレクトリ**
```
build/web/
├── index.html
├── main.dart.js
├── flutter.js
├── manifest.json
├── assets/
└── icons/
```

---

## 🚀 デプロイ手順

### **自動デプロイフロー（現在の設定）**

```
1. コード修正
   ↓
2. Git commit & push to main branch
   ↓
3. Cloudflare Pages が自動検知
   ↓
4. ビルド実行（build/web を使用）
   ↓
5. デプロイ完了（1〜3分）
   ↓
6. https://prompt-mixer.pages.dev/ に反映
```

### **Cloudflare Pages 設定**
- **プロダクションブランチ**: `main`
- **ビルドコマンド**: （空）
- **ビルド出力ディレクトリ**: `build/web`
- **環境変数**: 不要

---

## 📱 対応プラットフォーム

| プラットフォーム | 対応状況 | 共有機能 |
|-----------------|---------|---------|
| **iPhone (Safari)** | ✅ 完全対応 | iOS共有シート |
| **iPad (Safari)** | ✅ 完全対応 | iOS共有シート |
| **Android (Chrome)** | ✅ 完全対応 | Android共有メニュー |
| **Windows (Chrome)** | ✅ 完全対応 | クリップボードコピー |
| **macOS (Safari)** | ✅ 完全対応 | クリップボードコピー |

### **推奨ブラウザ**
- iOS/iPadOS: Safari
- Android: Chrome
- PC: Chrome, Firefox, Safari, Edge

---

## 🔧 メンテナンス

### **データベースバックアップ**
Firebase Consoleから手動エクスポート可能:
```
Firestore Database → データ → エクスポート
```

### **ユーザーデータ削除**
```
Firebase Console 
→ Authentication 
→ ユーザー選択 
→ 削除
```
（Firestoreのデータは自動削除されないため、別途削除が必要）

### **セキュリティルール更新**
```
Firebase Console 
→ Firestore Database 
→ Rules 
→ 編集 
→ 公開
```

---

## 📊 使用制限（Firebase 無料プラン）

### **Firebase Spark Plan（無料）**

| サービス | 無料枠 | 超過時の課金 |
|---------|-------|-------------|
| **Authentication** | 無制限 | 無料 |
| **Firestore ストレージ** | 1GB | $0.18/GB/月 |
| **Firestore 読み取り** | 50,000回/日 | $0.06/10万回 |
| **Firestore 書き込み** | 20,000回/日 | $0.18/10万回 |

### **想定ユーザー数での試算**

#### **1,000人/月の場合**
- ストレージ: 1MB × 1,000人 = 1GB（無料枠内）
- 読み取り: 100回/日/人 × 1,000人 = 100,000回/日
  - 超過分: 50,000回 × 30日 = 1,500,000回
  - 課金: $0.90/月（約130円）
- 書き込み: 10回/日/人 × 1,000人 = 10,000回/日（無料枠内）

**合計: 約130円/月**

---

## 🎓 用語集

| 用語 | 説明 |
|------|------|
| **プロンプト** | AIツールに送信する指示文 |
| **テンプレート** | プロンプトのひな型（{{URL}}プレースホルダー含む） |
| **{{URL}}** | URLに置き換えられるプレースホルダー |
| **共有シート** | iOS/Androidの標準共有機能 |
| **Firestore** | Googleのクラウドデータベース |
| **Cloud Sync** | クラウド同期機能 |

---

## 🐛 トラブルシューティング

### **問題: ログインできない**
**原因**: Firebase の認証済みドメインに登録されていない

**解決方法**:
1. Firebase Console → Authentication → Settings
2. Authorized domains に `prompt-mixer.pages.dev` を追加

---

### **問題: テンプレートが保存されない**
**原因**: Firestore Security Rules が正しく設定されていない

**解決方法**:
1. Firebase Console → Firestore Database → Rules
2. セキュリティルールを確認・更新
3. 「公開」ボタンをクリック

---

### **問題: デバイス間で同期されない**
**原因**: 異なるGoogleアカウントでログインしている

**解決方法**:
- すべてのデバイスで同じGoogleアカウントでログインする

---

### **問題: 共有シートが開かない（PC）**
**原因**: Web Share API非対応ブラウザ

**解決方法**:
- PCでは自動的にクリップボードコピーにフォールバック
- 「クリップボードにコピーしました」メッセージを確認

---

## 📞 サポート情報

### **GitHubリポジトリ**
https://github.com/hrtaym1114-github/prompt_mixer

### **公開URL**
https://prompt-mixer.pages.dev/

### **Firebase プロジェクト**
- プロジェクトID: `prompt-mixer-b4fb5`
- リージョン: `asia-northeast1`

---

## 📝 更新履歴

### **v1.0.0** (2025-01-XX)
- 初回リリース
- Googleログイン機能実装
- テンプレート管理機能実装
- URL入力とプロンプト生成機能実装
- 共有機能実装（Web Share API）
- Cloud Firestore統合
- Cloudflare Pagesデプロイ

---

## 🎯 今後の拡張案

### **機能追加候補**
- [ ] テンプレートのインポート/エクスポート
- [ ] テンプレートの共有（URLで共有）
- [ ] 履歴機能（過去に生成したプロンプトの保存）
- [ ] ショートカット機能（よく使うAIツールへのクイックアクセス）
- [ ] カスタムカテゴリアイコン
- [ ] ダークモード/ライトモードの切り替え
- [ ] 多言語対応（英語、日本語）

### **技術的改善候補**
- [ ] オフライン対応の強化
- [ ] PWA対応（ホーム画面への追加）
- [ ] Android/iOSネイティブアプリ化
- [ ] Firestoreインデックスの最適化
- [ ] テンプレート検索機能

---

**作成日**: 2025年
**バージョン**: 1.0.0
**管理者**: @hrtaym1114-github
