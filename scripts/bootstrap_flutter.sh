#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../apps/mobile"
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK belum terinstall. Install Flutter dulu lalu jalankan script ini lagi."
  exit 1
fi
flutter create . --project-name laras_mobile --org id.my.sarikhin --platforms=android,ios,web
flutter pub get
echo "Flutter platform files selesai dibuat. Jalankan: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080"
