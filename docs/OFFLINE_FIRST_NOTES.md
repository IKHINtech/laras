# Laras Offline-first Notes

Laras sekarang memakai dua mode:

## Local Mode

Tidak membutuhkan login dan menjadi tujuan utama aplikasi.

Fitur saat ini:

- Scan lagu lokal Android.
- Play musik lokal.
- Search lagu lokal.
- Favorite lokal.
- Playlist lokal.
- Mini player.
- Play/pause/next/previous.

Data lokal disimpan memakai `shared_preferences` untuk starter version:

- `laras.local.favorite_song_ids`
- `laras.local.playlists`

Untuk versi produksi, local playlist/favorite sebaiknya dipindahkan ke SQLite/Drift agar lebih kuat untuk ribuan lagu.

## Server Mode

Wajib login karena fitur server membutuhkan identitas user.

Fitur server:

- Register/login.
- Upload lagu.
- Streaming lagu.
- Favorite server.
- Playlist server.
- Sync favorite/playlist.
- Offline download dari server.

## First Launch Flow

```txt
[Continue Offline]
[Login to Laras Server]
[Register]
```

## Rekomendasi berikutnya

- Pindahkan local storage dari SharedPreferences ke Drift/SQLite.
- Buat local playlist detail screen untuk melihat isi playlist dan reorder lagu.
- Tambahkan local album/artist/folder browsing.
- Tambahkan offline download manager untuk lagu server.
- Tambahkan sync queue: local changes -> server saat login dan online.
