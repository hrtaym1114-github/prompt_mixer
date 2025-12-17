# Prompt Mixer

> URLとプロンプトテンプレートを組み合わせて、AIツールへ簡単送信

[![Live Demo](https://img.shields.io/badge/Live%20Demo-prompt--mixer.pages.dev-9C6ADE?style=for-the-badge)](https://prompt-mixer.pages.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)

## 🎯 これは何？

**Prompt Mixer**は、WebページやX(Twitter)の投稿URLとシステムプロンプトを組み合わせて、AIツール（ChatGPT、Claude、Geminiなど）に送信するためのWebアプリです。

### 💡 使用例

1. **気になる記事を要約したい**
   - 記事のURLをコピー
   - 「記事要約」テンプレートを選択
   - 共有ボタンでChatGPTに送信

2. **X(Twitter)の投稿を分析したい**
   - 投稿のURLをコピー
   - 「X投稿の分析」テンプレートを選択
   - 共有ボタンでClaudeに送信

3. **技術記事を初心者向けに解説してほしい**
   - 技術記事のURLをコピー
   - 「技術記事の解説」テンプレートを選択
   - 共有ボタンでGeminiに送信

---

## ✨ 主な機能

### 🔐 **Googleログイン**
- 安全なGoogle認証
- すべてのデバイスでデータを同期

### 📝 **テンプレート管理**
- プロンプトテンプレートを作成・編集・削除
- お気に入り機能でよく使うテンプレートを管理
- カテゴリ別に整理

### 🔗 **URL入力 & プロンプト生成**
- URLを入力（または貼り付け）
- テンプレートを選択
- `{{URL}}`が自動的にURLに置き換わる
- リアルタイムプレビュー

### 📤 **共有機能**
- **iPhone/iPad**: iOS標準共有シート
- **Android**: Android標準共有メニュー
- **PC**: クリップボードにコピー

### ☁️ **クラウド同期**
- すべてのデバイスで自動同期
- オフライン時も使用可能

---

## 🚀 使い方

### **1. アプリにアクセス**
https://prompt-mixer.pages.dev/

### **2. Googleでログイン**
初回ログイン時に、5つのサンプルテンプレートが自動生成されます。

### **3. URLを入力**
- 気になるWebページやX投稿のURLを入力
- または「ペースト」ボタンでクリップボードから貼り付け

### **4. テンプレートを選択**
横スクロールでテンプレートを選択

### **5. プレビュー確認**
生成されたプロンプトをプレビューで確認

### **6. 共有ボタンをタップ**
- **iPhone/iPad**: ChatGPT、Claudeなどのアプリを選択
- **Android**: インストール済みのAIアプリを選択
- **PC**: 自動的にクリップボードにコピー

### **7. AIツールで貼り付け**
お使いのAIツールにペーストして送信！

---

## 📱 対応プラットフォーム

| プラットフォーム | 対応状況 | 共有方法 |
|-----------------|---------|---------|
| iPhone (Safari) | ✅ | iOS共有シート |
| iPad (Safari) | ✅ | iOS共有シート |
| Android (Chrome) | ✅ | Android共有メニュー |
| Windows | ✅ | クリップボード |
| macOS | ✅ | クリップボード |

---

## 🎨 スクリーンショット

### ホーム画面
- URL入力エリア
- テンプレート選択
- プロンプトプレビュー
- 共有ボタン

### テンプレート管理画面
- カテゴリフィルター
- テンプレート一覧
- お気に入り管理
- 新規作成

### テンプレート編集画面
- タイトル、カテゴリ、説明
- プロンプト内容編集
- {{URL}}プレースホルダー挿入

---

## 🛠️ 技術スタック

- **フロントエンド**: Flutter 3.35.4 (Web)
- **言語**: Dart 3.9.2
- **認証**: Firebase Authentication (Google Sign-In)
- **データベース**: Cloud Firestore
- **ホスティング**: Cloudflare Pages
- **状態管理**: Provider
- **ローカルストレージ**: Hive

---

## 📦 初回ログイン特典

初回ログイン時に、以下の5つのサンプルテンプレートが自動生成されます:

1. **記事要約** - Webページの内容を簡潔に要約
2. **X投稿の分析** - X(Twitter)投稿を分析
3. **技術記事の解説** - 技術的な内容をわかりやすく解説
4. **お気に入り引用** - お気に入りコンテンツの引用と説明
5. **ニュース要点整理** - ニュース記事を5W1Hで整理

---

## 🎓 カスタムテンプレートの作成

### **基本構文**
```
あなたの指示文

{{URL}}
```

### **例1: 記事要約**
```
以下のURLの記事を読んで、主要なポイントを3つに絞って日本語で要約してください。

{{URL}}
```

### **例2: 技術記事の解説**
```
以下の技術記事を読んで、初心者にもわかりやすく解説してください。
専門用語があれば簡単な説明を加えてください。

{{URL}}
```

### **例3: SNS投稿の分析**
```
以下のX(Twitter)投稿を分析し、投稿者の意図、感情、主張のポイントを解説してください。

{{URL}}
```

---

## 💰 料金

### **アプリ利用**
**完全無料**

### **Firebase 無料枠（Spark Plan）**
- 認証: 無制限
- Firestoreストレージ: 1GB
- Firestore読み取り: 50,000回/日
- Firestore書き込み: 20,000回/日

個人利用なら無料枠で十分です！

---

## 🔒 プライバシー & セキュリティ

- **認証**: Firebase Authenticationによる安全なGoogle認証
- **データ保存**: ユーザーごとに独立したFirestoreコレクション
- **アクセス制限**: 認証済みユーザーのみ自分のデータにアクセス可能
- **HTTPS**: すべての通信はHTTPSで暗号化

---

## 🐛 トラブルシューティング

### **ログインできない**
→ ブラウザのキャッシュをクリアしてもう一度試してください

### **テンプレートが保存されない**
→ インターネット接続を確認してください

### **共有シートが開かない（PC）**
→ PCでは自動的にクリップボードにコピーされます

---

## 📞 サポート

問題や質問がある場合:
- GitHubリポジトリ: https://github.com/hrtaym1114-github/prompt_mixer
- Issues: https://github.com/hrtaym1114-github/prompt_mixer/issues

---

## 🎉 今後の予定

- [ ] テンプレートのインポート/エクスポート
- [ ] 履歴機能
- [ ] テンプレートの共有
- [ ] PWA対応
- [ ] ダークモード/ライトモードの切り替え

---

## 📄 ライセンス

MIT License

---

## 👤 作成者

[@hrtaym1114-github](https://github.com/hrtaym1114-github)

---

## 🌟 スター & フォローをお願いします！

このプロジェクトが役に立ったら、GitHubでスター⭐をお願いします！

[![GitHub stars](https://img.shields.io/github/stars/hrtaym1114-github/prompt_mixer?style=social)](https://github.com/hrtaym1114-github/prompt_mixer)
