# Android Notes

Setelah menjalankan `scripts/bootstrap_flutter.sh`, tambahkan permission berikut di `apps/mobile/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

Untuk emulator Android, gunakan API URL:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Untuk HP fisik, gunakan IP laptop/server, contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```
