# Laras v0.7.0

**Laras** adalah project offline-first music player: Flutter app bisa dipakai sebagai local player tanpa login, sedangkan backend Go Fiber menjadi fitur tambahan untuk upload/stream/sync musik pribadi.

Tagline: **Your personal music library, your way.**

## Isi Project

```txt
laras_v0_7_0/
├── services/api      # Go Fiber backend
├── apps/mobile       # Flutter source app
├── docs              # Catatan Android
├── scripts           # Helper bootstrap Flutter
├── docker-compose.yml
└── .env.example
```

## Fitur yang Disediakan

Backend:

- Register/login JWT
- Upload lagu
- List/search lagu
- Stream lagu dengan HTTP Range request
- Delete lagu
- Favorite toggle
- Playlist CRUD
- Playlist item add/remove
- Stats total lagu dan storage
- PostgreSQL + Docker Compose
- Auto migration dengan GORM

Flutter:

- Welcome screen: Continue Offline / Login / Register
- Local Mode tanpa login
- Scan lagu lokal Android dengan `on_audio_query`
- Play musik lokal
- Mini player
- Play/pause/next/previous
- Search local songs
- Favorite lokal tersimpan di device
- Playlist lokal tersimpan di device
- Server Mode wajib login
- Server music library
- Upload audio dari app
- Play streaming dari backend
- Theme light/dark

## Menjalankan Backend

```bash
cd laras_v0_7_0
cp .env.example .env
docker compose up --build
```

Cek health:

```bash
curl http://localhost:8080/health
```

Register user:

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"name":"Sarikhin","email":"demo@laras.local","password":"password"}'
```

Login:

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"demo@laras.local","password":"password"}'
```

Upload lagu:

```bash
TOKEN="paste-token-di-sini"
curl -X POST http://localhost:8080/api/v1/songs/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@/path/lagu.mp3" \
  -F "title=Judul Lagu" \
  -F "artist=Artist" \
  -F "album=Album"
```

List lagu:

```bash
curl http://localhost:8080/api/v1/songs \
  -H "Authorization: Bearer $TOKEN"
```

## Menjalankan Flutter

Environment pembuat ZIP ini tidak memiliki Flutter SDK, jadi platform Android/iOS/web tidak digenerate di sini. Source Flutter sudah tersedia.

Di mesin kamu:

```bash
cd laras_v0_7_0
./scripts/bootstrap_flutter.sh
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Saat app terbuka pertama kali:

```txt
[Continue Offline]      -> masuk Local Mode tanpa akun
[Login to Laras Server] -> Server Mode untuk upload/stream/sync
[Register]              -> buat akun server
```

Untuk HP fisik, ganti `10.0.2.2` dengan IP laptop/server, contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Lihat juga `docs/ANDROID_NOTES.md` untuk permission Android.

## Catatan Penting

Ini adalah starter project v0.7.0 yang bisa kamu kembangkan, bukan Spotify clone final production. Prioritasnya offline-first: local player tidak bergantung ke backend. Backend dibuat runnable dengan Docker. Flutter source dibuat lengkap, tetapi perlu bootstrap platform via Flutter SDK di mesin lokal.

Roadmap pengembangan lanjutan:

- Metadata extractor asli untuk MP3/FLAC
- Album art server
- Lyrics `.lrc`
- Equalizer native Android
- Offline download server songs
- Sync conflict handler
- Web player + admin dashboard terpisah
- Role admin/user
- MinIO/S3 storage adapter
- Refresh token
- Rate limit upload
- Tests backend dan Flutter
