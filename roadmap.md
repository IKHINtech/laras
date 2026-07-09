# Roadmap

Roadmap ini fokus pada **offline-first Android release** Laras.

Backend, sync, dan mode online dianggap **bukan prioritas utama** sampai fondasi local player benar-benar stabil.

## Prinsip

- Local mode harus bisa dipakai tanpa login.
- Playback harus stabil di device Android nyata.
- Data utama local mode harus tersimpan lokal dan tahan restart app.
- UI boleh berkembang bertahap, tetapi playback, library, dan persistence harus lebih dulu matang.

## Target Utama

Target berikutnya adalah **offline release yang layak dipakai harian**:

- scan library lokal stabil;
- playback background stabil;
- notification, lock screen, dan headset controls konsisten;
- queue, playlist, favorite, dan history persisten;
- lyrics, artwork, dan browse library terasa matang;
- widget Android usable dan tidak merusak state player.

## Prioritas Tinggi

### 1. Playback Restore Penuh

Saat app dibuka ulang, state player harus pulih dengan benar:

- queue terakhir;
- current index;
- current position;
- shuffle / repeat mode;
- status play / pause bila aman untuk direstore;
- source halaman terakhir yang relevan.

Status:

- sebagian sudah ada;
- masih perlu dipastikan utuh pada cold start, deep link widget, dan process death.

### 2. Android Background Hardening

Fokus pada kestabilan di device nyata:

- headset single-click / double-click / media button;
- lock screen controls;
- notification controls;
- app dibunuh system lalu dibuka lagi;
- audio interruption: call, Bluetooth disconnect, noisy output;
- sleep timer expiration saat screen off;
- deep link dari widget / notification tidak merusak state app.

### 3. Scan Engine dan Library Reliability

Local scan perlu lebih matang:

- incremental rescan;
- deteksi file baru, berubah, atau terhapus;
- hindari duplicate;
- performa lebih baik untuk folder besar;
- fallback metadata yang konsisten;
- pemetaan artist / album / folder yang lebih rapi.

### 4. Queue Persistence

Queue tidak boleh dianggap state sementara.

- queue tersimpan lokal;
- urutan queue dan current song tetap sama setelah restart;
- aksi next / previous / skip tetap sinkron dengan widget, notification, dan now playing.

### 5. Error Handling File Lokal

Kasus file rusak atau hilang harus aman:

- skip lagu yang path-nya invalid;
- tampilkan feedback yang jelas;
- lanjut ke item berikutnya tanpa crash;
- bersihkan cache / session bila item sudah tidak valid.

## Fitur User-Facing Bernilai Tinggi

### Recently Played dan Most Played

Yang sudah ada bisa dilanjutkan menjadi pengalaman penuh:

- halaman dedicated;
- filter timeframe;
- clear history;
- sort dan grouping yang lebih berguna.

### Smart Playlist Lokal

Tambahkan playlist otomatis:

- Recently Added;
- Recently Played;
- Most Played;
- Favorites;
- Last 30 days.

### Multi-select Action di Library

Untuk mempercepat pengelolaan koleksi:

- tambah ke playlist;
- queue next;
- favorite;
- hapus dari playlist;
- share file atau metadata jika relevan.

### Folder Pinning

User bisa pin folder favorit ke halaman local:

- pinned folders;
- quick access di home local;
- cocok untuk user yang koleksinya lebih folder-based daripada metadata-based.

### Lyrics Tooling

Lyrics sudah berjalan, next step:

- manual reload source;
- manual offset;
- pilih source default per lagu;
- prefer `.lrc` atau metadata;
- edit kecil untuk sinkronisasi timing.

## Audio Feature Lanjutan

### Crossfade

Layak ditambahkan setelah playback core stabil:

- configurable duration;
- disable otomatis untuk file tertentu bila perlu;
- uji gapless + crossfade interaction.

### ReplayGain / Loudness Control

Jika feasible:

- normalize volume antarlagu;
- simpan preference user;
- jangan merusak playback stability.

### EQ Preset Management

Equalizer sudah ada secara dasar, next:

- preset save/load;
- preset per user;
- reset default.

### Per-song Volume Offset

Bagus untuk koleksi campuran:

- simpan offset per lagu;
- dipakai saat load playback.

## Data dan Persistence

### Migrasi Cache ke SQLite

Arah yang perlu dijaga:

- local library cache;
- playlist;
- favorite;
- playback history;
- sleep timer;
- lyrics index;
- playback session / queue snapshot.

### Artwork Cache Policy

Supaya storage tetap sehat:

- ukuran cache maksimum;
- cleanup berkala;
- invalidasi bila file sumber berubah;
- reuse cache untuk widget, notification, dan now playing.

### Playback Event Log

Sudah bergerak ke event-based history, next:

- skip rate;
- completion rate;
- session length;
- song completion heuristics.

## UI dan Product Polish

### Local Home yang Lebih Kaya

Halaman local sebaiknya jadi dashboard koleksi:

- Recently Played preview;
- Most Played preview;
- pinned folders;
- smart playlist entry points;
- Shuffle All tetap jadi CTA utama.

### Widget Android yang Lebih Matang

Lanjutkan widget sampai benar-benar release-ready:

- compact vs expanded behavior;
- resize awareness;
- artwork fallback yang bagus;
- launch command yang tidak merusak player state;
- bisa dibedakan 4x1, 4x2, dan ukuran lebih besar.

### Share Card dan Branding

Fitur share sudah berkembang, next polish:

- simpan preferensi terakhir;
- preset share favorite user;
- crop guide untuk Story;
- export cepat dari selected lyrics.

### Theme System

Sekarang sudah cukup kaya, next:

- preset theme yang lebih konsisten;
- import / export custom color;
- per-surface tuning;
- theme preview yang lebih baik.

## Urutan Eksekusi yang Disarankan

### Milestone 1 — Playback Core Stabil

- playback restore penuh;
- widget deep link stabil;
- queue persistence;
- error handling file lokal;
- Android background hardening tahap 1.

### Milestone 2 — Library Core Stabil

- incremental scan;
- deleted file handling;
- duplicate handling;
- artist / album / folder cleanup;
- artwork cache policy dasar.

### Milestone 3 — Listening Experience

- Recently Played page;
- Most Played page;
- smart playlists;
- lyrics tooling lanjutan;
- widget polish lanjutan.

### Milestone 4 — Advanced Audio

- crossfade;
- EQ preset management;
- loudness / ReplayGain exploration;
- per-song volume offset jika masih relevan.

## Sprint Berikutnya yang Paling Disarankan

Kalau hanya memilih beberapa item paling bernilai untuk langsung dikerjakan:

1. playback/session restore full;
2. widget + notification + cold-start command hardening;
3. incremental scan + deleted file handling;
4. smart playlist lokal;
5. crossfade setelah playback core benar-benar stabil.
