# Laras

[Indonesia](./README.id.md) | [English](./README.en.md) | [日本語](./README.ja.md)

## What is Laras?

**Laras** is a personal music player built with an **offline-first** approach. You can use it without logging in, keep your music collection private, and stay in control of how you listen.

Laras is for people who:

- already own their music files;
- want a player without ads and recommendation algorithms;
- prefer local playlists and favorites;
- may want a personal server later, but do not want the app to depend on it.

> **Local first. Server when needed.**

## Key Features

- Local Mode with no login required
- Scan local songs from an Android device
- Search, folder browsing, local playlists, and local favorites
- Mini player and now playing
- Sleep timer
- Custom theme and app icon
- Optional Server Mode for upload, streaming, and self-hosted expansion

## Project Structure

```txt
laras/
├── apps/
│   └── mobile/          # Flutter Android app
├── services/
│   └── api/             # Go Fiber backend
├── docs/                # Documentation
├── infra/               # Deployment / docker config
└── README.md
```

## Tech Stack

- Mobile: Flutter, Dart, local storage, Android media APIs
- Backend: Go, Fiber, PostgreSQL, GORM, JWT, Docker Compose

## Run the Mobile App

```bash
cd apps/mobile
flutter pub get
flutter run
```

For an Android emulator with a local backend:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

For a physical device:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

## Run the Backend

```bash
cp .env.example .env
docker compose up --build
```

Example endpoints:

```txt
POST   /api/v1/auth/register
POST   /api/v1/auth/login
GET    /api/v1/songs
POST   /api/v1/songs/upload
GET    /api/v1/songs/:id/stream
```

## Philosophy

```txt
Local-first
Privacy-friendly
Offline-first
Self-hostable
Open-source
User-controlled
```

Laras is not trying to become Spotify.  
It is trying to become a music player that respects your own collection.

## Contributing

Contributions are welcome, especially for:

- bug fixes;
- player features;
- UI/UX improvements;
- Android device testing;
- lyrics, backend streaming, and self-hosted workflows.

Start contributing:

```bash
git clone https://github.com/IKHINtech/laras.git
cd laras
git checkout -b feature/your-feature
```

## Download APK

```txt
https://github.com/IKHINtech/laras/releases/latest
```
