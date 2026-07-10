# Laras

[Indonesia](./README.id.md) | [English](./README.en.md) | [日本語](./README.ja.md)

## Apa itu Laras?

**Laras** adalah pemutar musik personal yang **offline-first**, bisa dipakai tanpa login, dan memberi kamu kontrol penuh atas koleksi musikmu sendiri.

Laras dibuat untuk orang yang:

- punya koleksi musik sendiri;
- ingin memutar musik tanpa iklan dan tanpa algoritma;
- ingin playlist dan favorite tetap lokal;
- mungkin ingin menambahkan server pribadi, tapi tidak mau dipaksa bergantung ke server.

> **Local dulu. Server kalau perlu.**

## Fitur Utama

- Local Mode tanpa login
- Scan lagu lokal dari perangkat Android
- Search, folder browsing, playlist, dan favorite lokal
- Mini player dan now playing
- Sleep timer
- Theme dan app icon custom
- Server Mode opsional untuk upload, stream, dan pengembangan self-hosted

## Arsitektur Project

```txt
laras/
├── apps/
│   └── mobile/          # Flutter Android app
├── services/
│   └── api/             # Go Fiber backend
├── docs/                # Dokumentasi
├── infra/               # Deployment / docker config
└── README.md
```

## Tech Stack

- Mobile: Flutter, Dart, local storage, Android media APIs
- Backend: Go, Fiber, PostgreSQL, GORM, JWT, Docker Compose

## Menjalankan Mobile App

```bash
cd apps/mobile
flutter pub get
flutter run
```

Android emulator dengan backend lokal:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Device fisik:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

## Menjalankan Backend

```bash
cp .env.example .env
docker compose up --build
```

Contoh endpoint:

```txt
POST   /api/v1/auth/register
POST   /api/v1/auth/login
GET    /api/v1/songs
POST   /api/v1/songs/upload
GET    /api/v1/songs/:id/stream
```

## Filosofi

```txt
Local-first
Privacy-friendly
Offline-first
Self-hostable
Open-source
User-controlled
```

Laras tidak mencoba menjadi Spotify.  
Laras mencoba menjadi music player yang memberi ruang untuk koleksi musikmu sendiri.

## Kontribusi

Kontribusi sangat terbuka, terutama untuk:

- bugfix;
- fitur player;
- UI/UX;
- testing di berbagai device Android;
- lyrics, backend streaming, dan self-hosted workflow.

Mulai kontribusi:

```bash
git clone https://github.com/IKHINtech/laras.git
cd laras
git checkout -b feature/nama-fitur
```

## Download APK

```txt
https://github.com/IKHINtech/laras/releases/latest
```
