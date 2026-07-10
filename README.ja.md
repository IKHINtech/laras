# Laras

[Indonesia](./README.id.md) | [English](./README.en.md) | [日本語](./README.ja.md)

## Laras とは？

**Laras** は **オフラインファースト** の個人向け音楽プレーヤーです。ログインなしで使え、自分の音楽コレクションを自分のやり方で管理できます。

Laras は次のような人のために作られています。

- 自分の音楽ファイルを持っている
- 広告や推薦アルゴリズムなしで音楽を聴きたい
- プレイリストやお気に入りをローカルに保存したい
- 必要なら個人サーバーも使いたいが、常に依存したくはない

> **まずはローカル。必要ならサーバー。**

## 主な機能

- ログイン不要の Local Mode
- Android 端末内のローカル楽曲をスキャン
- 検索、フォルダ閲覧、ローカルプレイリスト、お気に入り
- ミニプレーヤーと再生中画面
- スリープタイマー
- テーマとアプリアイコンのカスタマイズ
- アップロード、ストリーミング、自前運用を可能にする任意の Server Mode

## プロジェクト構成

```txt
laras/
├── apps/
│   └── mobile/          # Flutter Android app
├── services/
│   └── api/             # Go Fiber backend
├── docs/                # ドキュメント
├── infra/               # デプロイ / docker 設定
└── README.md
```

## 技術スタック

- モバイル: Flutter, Dart, local storage, Android media APIs
- バックエンド: Go, Fiber, PostgreSQL, GORM, JWT, Docker Compose

## モバイルアプリの起動

```bash
cd apps/mobile
flutter pub get
flutter run
```

Android エミュレータでローカルバックエンドを使う場合:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

実機の場合:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

## バックエンドの起動

```bash
cp .env.example .env
docker compose up --build
```

エンドポイント例:

```txt
POST   /api/v1/auth/register
POST   /api/v1/auth/login
GET    /api/v1/songs
POST   /api/v1/songs/upload
GET    /api/v1/songs/:id/stream
```

## 設計思想

```txt
Local-first
Privacy-friendly
Offline-first
Self-hostable
Open-source
User-controlled
```

Laras は Spotify を目指していません。  
あなた自身の音楽コレクションを大切にするプレーヤーを目指しています。

## コントリビュート

以下のような貢献を歓迎します。

- バグ修正
- プレーヤー機能の追加
- UI/UX 改善
- Android 実機での検証
- 歌詞、バックエンド配信、自前運用まわりの改善

開始手順:

```bash
git clone https://github.com/IKHINtech/laras.git
cd laras
git checkout -b feature/your-feature
```

## APK ダウンロード

```txt
https://github.com/IKHINtech/laras/releases/latest
```
