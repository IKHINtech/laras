<p align="center">
  <img src="docs/assets/laras-logo.png" width="120" alt="Laras Logo" />
</p>

<h1 align="center">Laras</h1>

<p align="center"><strong>Musikmu, aturanmu.</strong></p>

<p align="center">
  Pemutar musik personal yang <strong>offline-first</strong>, bisa dipakai tanpa login,
  dan memberi kamu kontrol penuh atas koleksi musikmu sendiri.
</p>

<p align="center">
  <a href="https://github.com/IKHINtech/laras/releases/latest">
    <img src="https://img.shields.io/badge/Download-APK-F59E0B?style=for-the-badge" alt="Download APK" />
  </a>
  <a href="https://github.com/IKHINtech/laras">
    <img src="https://img.shields.io/badge/Open%20Source-GitHub-8B5CF6?style=for-the-badge" alt="GitHub" />
  </a>
  <a href="https://laras.sarikhin.my.id">
    <img src="https://img.shields.io/badge/Website-laras.sarikhin.my.id-FB7185?style=for-the-badge" alt="Website" />
  </a>
</p>

---

## Apa itu Laras?

**Laras** adalah music player untuk orang yang ingin menikmati musik dengan cara sendiri.

Bukan streaming app yang memaksa kamu login.  
Bukan aplikasi yang penuh iklan.  
Bukan player yang mengatur selera musikmu lewat algoritma.

Laras dibuat untuk kamu yang punya koleksi musik sendiri dan ingin memutarnya dengan nyaman, cepat, dan tetap privat.

> **Local dulu. Server kalau perlu.**

Mode utama Laras adalah **Local Mode**: scan lagu dari perangkat Android dan langsung putar tanpa akun.  
Jika kamu ingin fitur tambahan seperti upload, streaming dari server pribadi, atau sinkronisasi antar device, Laras juga menyediakan **Server Mode** yang bisa kamu host sendiri.

---

## Kenapa Laras?

Banyak music player terlalu sederhana. Banyak streaming app terlalu membatasi. Laras mengambil jalan tengah:

- **Bisa langsung dipakai tanpa login**
- **Tetap berjalan tanpa internet**
- **Koleksi musik tetap milikmu**
- **Playlist dan favorite tersimpan lokal**
- **Server pribadi hanya opsional**
- **Cocok untuk pengguna biasa dan developer**
- **Open-source dan bisa dikembangkan sendiri**

Laras cocok untuk kamu yang ingin:

- punya music player pribadi;
- mengelola file musik lokal;
- tidak bergantung pada platform streaming;
- tetap bisa self-host server musik sendiri;
- belajar Flutter, Go Fiber, dan arsitektur offline-first dari project nyata.

---

## Fitur Utama

### Local Mode — Tanpa Login

Gunakan Laras langsung dari perangkat Android.

- Scan lagu lokal
- Putar musik tanpa akun
- Search lagu
- Browse berdasarkan folder
- Playlist lokal
- Favorite lokal
- Mini player
- Now playing
- Play / pause / next / previous
- Sleep timer
- Theme dan app icon custom

Local Mode adalah inti dari Laras.

```txt
Install app
→ Continue Offline
→ Scan lagu lokal
→ Putar musikmu
```

---

### Offline-first

Laras tidak menganggap internet sebagai syarat utama.

Pada Local Mode:

- tidak perlu login;
- tidak perlu server;
- tidak perlu koneksi internet;
- data musik tetap berada di perangkat;
- playlist dan favorite tetap bisa digunakan.

Ini membuat Laras cocok sebagai music player harian.

---

### Playlist & Favorite Lokal

Kelola koleksi musikmu sendiri dengan lebih rapi.

- Buat playlist
- Tambahkan lagu ke playlist
- Hapus lagu dari playlist
- Tandai lagu favorit
- Akses koleksi favorite kapan saja
- Data tersimpan di perangkat

---

### Folder Browsing

Tidak semua koleksi musik rapi berdasarkan metadata. Karena itu Laras mendukung browsing berdasarkan folder.

Cocok untuk struktur seperti:

```txt
Music/
├── Payung Teduh/
├── Sheila On 7/
├── OST Anime/
├── Lagu Lama/
└── Random Collection/
```

---

### Server Mode — Opsional

Server Mode dibuat untuk pengguna yang ingin lebih dari local player.

Dengan Server Mode, kamu bisa:

- login ke server pribadi;
- upload lagu;
- stream lagu dari backend sendiri;
- menyiapkan sinkronisasi playlist dan favorite;
- mengembangkan Laras menjadi self-hosted music platform.

Server Mode **bukan syarat utama**. Kamu tetap bisa memakai Laras sebagai local player tanpa server.

---

## Arsitektur Project

Laras menggunakan struktur monorepo:

```txt
laras/
├── apps/
│   └── mobile/          # Flutter Android app
├── services/
│   └── api/             # Go Fiber backend
├── docs/                # Dokumentasi
├── infra/               # Konfigurasi deployment / docker
└── README.md
```

---

## Tech Stack

### Mobile App

- Flutter
- Dart
- BLoC / Cubit
- Local storage
- Android media permission
- Audio playback

### Backend

- Go
- Fiber
- PostgreSQL
- GORM
- JWT authentication
- HTTP range streaming
- Docker Compose

### Landing Page

- Next.js
- Tailwind CSS
- Dark modern UI
- Warm Purple + Amber palette

---

## Cara Menjalankan Mobile App

Masuk ke folder mobile:

```bash
cd apps/mobile
flutter pub get
flutter run
```

Untuk Android emulator, jika memakai backend lokal, gunakan:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Untuk device fisik, gunakan IP komputer/server kamu:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

---

## Cara Menjalankan Backend

Jalankan dari root project:

```bash
cp .env.example .env
docker compose up --build
```

Contoh endpoint awal:

```txt
POST   /api/v1/auth/register
POST   /api/v1/auth/login
GET    /api/v1/songs
POST   /api/v1/songs/upload
GET    /api/v1/songs/:id/stream
```

---

## Download APK

APK terbaru tersedia di halaman GitHub Releases:

```txt
https://github.com/IKHINtech/laras/releases/latest
```

Atau klik badge **Download APK** di bagian atas README ini.

---

## Roadmap

### v0.1 — Local Player Core

- Scan lagu lokal
- Play / pause / next / previous
- Mini player
- Now playing
- Queue sederhana

### v0.2 — Library Management

- Playlist
- Favorite
- Search
- Album art
- Sort by artist / album / folder

### v0.3 — Native Listening Experience

- Background playback
- Notification controls
- Lock screen controls
- Sleep timer

### v0.4 — Personal Listening

- Lyrics `.lrc`
- Embedded lyrics
- Equalizer
- Theme custom

### v0.5 — Self-hosted Backend

- Backend Go Fiber
- Upload lagu
- Stream lagu dari server pribadi

### v0.6 — Sync & Offline Server Music

- Sync playlist
- Sync favorite
- Offline download dari server pribadi

### v0.7 — Web & Dashboard

- Web player
- Admin dashboard
- Storage management

---

## Filosofi Laras

Laras dibangun dengan prinsip:

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

---

## Kontribusi

Kontribusi sangat terbuka.

Kamu bisa membantu dengan:

- memperbaiki bug;
- menambah fitur player;
- meningkatkan UI/UX;
- membuat dokumentasi;
- menguji di berbagai device Android;
- menambahkan dukungan lyrics;
- meningkatkan backend streaming;
- membuat issue atau ide fitur baru.

Langkah kontribusi:

```bash
git clone https://github.com/IKHINtech/laras.git
cd laras
git checkout -b feature/nama-fitur
```

Setelah selesai:

```bash
git commit -m "feat: add nama fitur"
git push origin feature/nama-fitur
```

Lalu buat Pull Request.

---

## Ide Kontribusi yang Menarik

- Lyrics `.lrc` parser
- Embedded lyrics reader
- Equalizer
- Better Android notification icon
- Audio metadata editor
- Offline download manager
- Playlist reorder
- Mini player animation
- Web player
- Admin dashboard
- Docker production setup

---

## Screenshot

<p align="center">
  <img src="docs/assets/screenshoot-home.jpeg" width="200" />
  <img src="docs/assets/screenshoot-playlist.jpeg" width="200" />
  <img src="docs/assets/screenshoot-settings.jpeg" width="200" />
  <img src="docs/assets/screenshoot-now-playing.jpeg" width="200" />
  <img src="docs/assets/screenshoot-lirik.jpeg" width="200" />
</p>

---

## Lisensi

Project ini dirilis sebagai open-source.

Silakan cek file `LICENSE` untuk detail lisensi.

---

## Author

Dibuat dan dikembangkan oleh **IKHINtech**.

- GitHub: [@IKHINtech](https://github.com/IKHINtech)
- Website: [laras.sarikhin.my.id](https://laras.sarikhin.my.id)

---

<p align="center">
  <strong>Laras — Musikmu, aturanmu.</strong>
</p>

